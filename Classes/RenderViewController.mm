//
//  RenderViewController.m
//  Milgrom
//
//  Created by Roee Kremer on 4/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RenderViewController.h"
#import "MilgromInterfaceAppDelegate.h"
#import "SoloViewController.h"
#include "testApp.h"
#include "Constants.h"
#import "OpenGLTOMovie.h"
#import "glu.h"
#import "ExportManager.h"
#import "RenderView.h"
#import "CustomImageView.h"
#import "EAGLView.h"
#import "ShareManager.h"
#import "MilgromMacros.h"

@interface RenderViewController() 

- (void)updateRenderProgress;
- (void)renderAudioDidFinish;
- (void)updateExportProgress:(ExportManager*)manager;
- (void)renderFinished;
@end


@implementation RenderViewController

@synthesize renderView;
@synthesize renderLabel;
@synthesize renderCancelButton;
@synthesize renderCameraIcon;
@synthesize renderProgressView;
@synthesize exportManager;
@synthesize renderManager;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.renderProgressView.image =  [UIImage imageNamed:@"BAR_OVERLY.png"];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	MilgromLog(@"RenderViewController::viewWillAppear");
	self.view.userInteractionEnabled = NO; // we don't need no band control - only for video
	self.renderCancelButton.hidden = YES;
	self.renderView.slideView.hidden = YES;
	
	MilgromInterfaceAppDelegate * appDelegate = (MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate];
	if (self.parentViewController == appDelegate.soloViewController) {
		[appDelegate.eAGLView setInterfaceOrientation:UIInterfaceOrientationLandscapeRight duration: 0.3];
	}
	
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	MilgromLog(@"RenderViewController::viewDidAppear");
	[self renderAudio];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return interfaceOrientation == UIInterfaceOrientationLandscapeRight || interfaceOrientation == UIInterfaceOrientationLandscapeLeft;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	// TODO: clean here
    [super dealloc];
}

-(void)setDelegate:(id<RenderViewControllerDelegate>)theDelegate {
	delegate = theDelegate;
}

/* used to be in mainViewController updateViews
 int songState =OFSAptr->getSongState();
 if (songState == SONG_RENDER_VIDEO || songState == SONG_RENDER_VIDEO_FINISHED || songState == SONG_RENDER_AUDIO || songState == SONG_CANCEL_RENDER_AUDIO || songState == SONG_RENDER_AUDIO_FINISHED || exportManager) {
 if (![self.view.subviews containsObject:renderView]) {
 [self.view addSubview:renderView];
 }
 
 
 renderView.slideView.hidden =renderCancelButton.hidden = renderCameraIcon.hidden = songState!=SONG_RENDER_VIDEO;
 
 return;
 } else if ([self.view.subviews containsObject:renderView]) {
 [renderView removeFromSuperview];
 } 
*/

- (void) setRenderProgress:(float) progress {
	[renderProgressView setRect:CGRectMake(0.0f, 0.0f,progress,1.0f)];
}

- (void)updateRenderProgress
{
	
	testApp *OFSAptr = ((MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate]).OFSAptr;
	
	if (OFSAptr->getSongState()==SONG_RENDER_AUDIO || OFSAptr->getSongState()==SONG_RENDER_VIDEO) {
		float progress = OFSAptr->getRenderProgress();
		[self setRenderProgress:progress];
		//NSLog(@"rendering, progrss: %2.2f",progress);
		
		NSArray *modes = [[[NSArray alloc] initWithObjects:NSDefaultRunLoopMode, UITrackingRunLoopMode, nil] autorelease];
		[self performSelector:@selector(updateRenderProgress) withObject:nil afterDelay:0.1 inModes:modes];
	}
}

- (void)renderAudio {
	self.renderLabel.text = @"Creating audio";
	[self setRenderProgress:0.0f];
	
	dispatch_queue_t myCustomQueue;
	myCustomQueue = dispatch_queue_create("renderAudioQueue", NULL);
	
	testApp *OFSAptr = ((MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate]).OFSAptr;
	
	OFSAptr->soundStreamStop();
	
	dispatch_async(myCustomQueue, ^{
		
		OFSAptr->renderAudio();
		
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self renderAudioDidFinish];
		});
		
		
	});
	
	dispatch_release(myCustomQueue);
	
	NSArray *modes = [[[NSArray alloc] initWithObjects:NSDefaultRunLoopMode, UITrackingRunLoopMode, nil] autorelease];
	[self performSelector:@selector(updateRenderProgress) withObject:nil afterDelay:0.1 inModes:modes];
	
}



- (void)renderAudioDidFinish {
	testApp *OFSAptr = ((MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate]).OFSAptr;

	OFSAptr->soundStreamStart();
	[delegate RenderViewControllerDelegateAudioRendered:self];
	
	
}




- (void)renderVideo {
	// [(TouchView*)self.view  setRenderTouch:NO];
	self.view.userInteractionEnabled = YES;
	self.renderCancelButton.hidden = NO;
	self.renderView.slideView.hidden = NO;
	
	self.renderLabel.text = @"Creating video";
	
	
	[self setRenderProgress:0.0f];
	
	MilgromInterfaceAppDelegate * appDelegate = (MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate];
	ShareManager *shareManager = [appDelegate shareManager];
	
	testApp *OFSAptr = appDelegate.OFSAptr;
	
	
	OFSAptr->soundStreamStop();
	OFSAptr->setSongState(SONG_RENDER_VIDEO);
	
	self.renderManager = [OpenGLTOMovie renderManager];
	
	dispatch_queue_t myCustomQueue;
	myCustomQueue = dispatch_queue_create("renderQueue", NULL);
	
	
	
	dispatch_async(myCustomQueue, ^{
		
		//OFSAptr->renderAudio();
		
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		[renderManager writeToVideoURL:[NSURL fileURLWithPath:[[shareManager getVideoPath]  stringByAppendingPathExtension:@"mov"]] withAudioURL:[NSURL fileURLWithPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"temp.caf"]] 
		 
		 
						   withContext:appDelegate.eAGLView.context
							  withSize:CGSizeMake(480, 320) 
			   withAudioAverageBitRate:[NSNumber numberWithInt: 192000 ]
			   withVideoAverageBitRate:[NSNumber numberWithDouble:VIDEO_BITRATE*1000.0] // appDelegate.videoBitrate
		 
			 withInitializationHandler:^ {
				 glMatrixMode (GL_PROJECTION);
				 glLoadIdentity ();
				 gluOrtho2D (0, 480, 0, 320);
				 
			 }
		 
						 withDrawFrame:^(int frameNum) {
							 //NSLog(@"rendering frame: %i, progress: %2.2f",frameNum,OFSAptr->getRenderProgress());
							 OFSAptr->seekFrame(frameNum+1); // roikr: for synching
							 
							 glMatrixMode(GL_MODELVIEW);
							 glLoadIdentity();
							 
							 OFSAptr->render();
							 
						 }
		 
					   withIsRendering:^ {
						   
						   return (int)(OFSAptr->getSongState()==SONG_RENDER_VIDEO);
					   }
		 
				 withCompletionHandler:^ {
					 NSLog(@"write completed");
					 
					 self.view.userInteractionEnabled = NO;
					 self.renderCancelButton.hidden = YES;
					 self.renderView.slideView.hidden = YES;
					 OFSAptr->setSongState(SONG_IDLE);
					 OFSAptr->soundStreamStart();
					 [self renderFinished];
					 [delegate RenderViewControllerDelegateVideoRendered:self];
					
					 self.renderManager = nil;
					 
				 }
		 
				withCancelationHandler:^ {
					NSLog(@"videoRender canceled");
					OFSAptr->setSongState(SONG_IDLE);
					OFSAptr->soundStreamStart();
					self.renderManager = nil;
				}
		 
				   withAbortionHandler:^ {
					   NSLog(@"videoRender aborted");
					   self.renderManager = nil;  
				   }
		 
		 ];
	});
	
	
	dispatch_release(myCustomQueue);
	
	NSArray *modes = [[[NSArray alloc] initWithObjects:NSDefaultRunLoopMode, UITrackingRunLoopMode, nil] autorelease];
	[self performSelector:@selector(updateRenderProgress) withObject:nil afterDelay:0.1 inModes:modes];
	
}


- (void)exportRingtone {
	self.renderLabel.text = @"Exporting ringtone";
	[self setRenderProgress:0.0f];
	
	
	ShareManager *shareManager = [(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] shareManager];
	testApp *OFSAptr = ((MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate]).OFSAptr;
	
	OFSAptr->soundStreamStop();
	
	//ShareManager *shareManager = [(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] shareManager];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	self.exportManager = [ExportManager  exportAudio:[NSURL fileURLWithPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"temp.caf"]]
						  
											   toURL:[NSURL fileURLWithPath:[[shareManager getVideoPath] stringByAppendingPathExtension:@"m4r"]]
						  
						  
							   withCompletionHandler:^ {
								   NSLog(@"export completed");
								   
								   OFSAptr->setSongState(SONG_IDLE);
								   OFSAptr->soundStreamStart();
								   
								   if ([exportManager didExportComplete]) {
									   [self renderFinished];
									   [delegate RenderViewControllerDelegateRingtoneExported:self];
									   
								   }
								   
								   self.exportManager = nil;
								   //[self updateViews]; // TODO: update aqui
								   
							   }];
	
	NSArray *modes = [[NSArray alloc] initWithObjects:NSDefaultRunLoopMode, UITrackingRunLoopMode, nil];
	[self performSelector:@selector(updateExportProgress:) withObject:exportManager afterDelay:0.5 inModes:modes];
	
	
}




- (void)updateExportProgress:(ExportManager*)manager
{
	
	if (!manager.didFinish) {
		//MilgromLog(@"export audio, progrss: %2.2f",manager.progress);
		[self setRenderProgress:manager.progress];
		NSArray *modes = [[[NSArray alloc] initWithObjects:NSDefaultRunLoopMode, UITrackingRunLoopMode, nil] autorelease];
		[self performSelector:@selector(updateExportProgress:) withObject:manager afterDelay:0.5 inModes:modes];
	}
}


- (void)cancelRendering:(id)sender {
	
	MilgromInterfaceAppDelegate * appDelegate = (MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate];
	testApp *OFSAptr = appDelegate.OFSAptr;
	
	switch (OFSAptr->getSongState()) {
		case SONG_RENDER_VIDEO:  
			[self.renderManager cancelRender];
			break;
		case SONG_RENDER_AUDIO:
			OFSAptr->setSongState(SONG_CANCEL_RENDER_AUDIO); // TODO: need to be checked
			break;
		default:
			break;
	}
	
	if (exportManager) {
		[exportManager cancelExport];
		self.exportManager = nil;
		OFSAptr->setSongState(SONG_IDLE);
		OFSAptr->soundStreamStart();
	}
	
	
	[delegate RenderViewControllerDelegateCanceled:self];
	[self renderFinished];
	
}

- (void)renderFinished {
	MilgromInterfaceAppDelegate * appDelegate = (MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate];
	if (self.parentViewController == appDelegate.soloViewController) {
		[appDelegate.eAGLView setInterfaceOrientation:UIInterfaceOrientationPortrait duration: 0.3];
	}
}

- (void)applicationDidEnterBackground {
	if (renderManager) {
		[self.renderManager abortRender];
	}
	
	if (exportManager) {
		[self.exportManager cancelExport];
		self.exportManager = nil;
	}
	
}

@end
