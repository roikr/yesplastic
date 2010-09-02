//
//  ShareViewController.mm
//  Milgrom
//
//  Created by Roee Kremer on 8/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ShareViewController.h"
#import "CustomImageView.h"
#import "OpenGLTOMovie.h"
#import "testApp.h"
#import "Constants.h"
#import "MilgromInterfaceAppDelegate.h"
#import "MilgromViewController.h"
#import <AVFoundation/AVFoundation.h>


@interface ShareViewController ()
- (void) export;	
- (void)exportDidFinish;
- (void)updateExportProgress:(AVAssetExportSession *)theSession;
@end

@implementation ShareViewController

@synthesize progressView;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.progressView.image =  [UIImage imageNamed:@"CELL1_PROGRESS.png"];
	
	
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

- (NSNumber *)progress {
	return [NSNumber numberWithFloat:0];
}

- (void) setProgress:(NSNumber *)theProgress {
	[progressView setRect:CGRectMake(0, 0, [theProgress floatValue],1.0f)];
}

- (void)render {
	[self setProgress:[NSNumber numberWithFloat:0.0f]];
	
	MilgromViewController * milgromViewController = ((MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate]).milgromViewController;
	testApp *OFSAptr = ((MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate]).OFSAptr;
	
	[milgromViewController stopAnimation];
	OFSAptr->soundStreamStop();

	dispatch_queue_t myCustomQueue;
	myCustomQueue = dispatch_queue_create("renderQueue", NULL);
	
	dispatch_async(myCustomQueue, ^{
				
		OFSAptr->renderAudio();
		OFSAptr->setSongState(SONG_RENDER_VIDEO);
		
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *videoPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"temp.mov"];
		
		
		
		[OpenGLTOMovie writeToVideoURL:[NSURL fileURLWithPath:videoPath] WithSize:CGSizeMake(480, 320) 
		 
						 withDrawFrame:^(int frameNum) {
							 //NSLog(@"rendering frame: %i",frameNum);
							 [milgromViewController drawFrame];
							 [self setProgress:[NSNumber numberWithFloat:OFSAptr->getPlayhead()]];
							 // TODO: playhead is only by DRM
							 
						 }
		 
						 withDidFinish:^(int frameNum) {
							 return (int)(OFSAptr->getSongState()!=SONG_RENDER_VIDEO);
						 }
		 
				 withCompletionHandler:^ {
					 NSLog(@"write completed");
					 [self export];
					 
				 }];
	});
	
	
	dispatch_release(myCustomQueue);
	
	
}

- (void) export {
	
	self.progress = [NSNumber numberWithFloat:0.0f];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *exportPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"video.mov"];
	
	NSError *error;
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath]) {
		if (![[NSFileManager defaultManager] removeItemAtPath:exportPath error:&error]) {
			NSLog(@"removeItemAtPath error: %@",[error description]);
		}
	}
	
	AVAssetExportSession * session = [OpenGLTOMovie exportToURL:[NSURL fileURLWithPath:exportPath]
				  withVideoURL:[NSURL fileURLWithPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"temp.mov"]] 
				  withAudioURL: [NSURL fileURLWithPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"temp.wav"]] //[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"temp" ofType:@"wav"]]
	 
		   withProgressHandler:nil
	 
//			^(float progress) {
//			   dispatch_async(dispatch_get_main_queue(),^{
//				   [self setProgress:[NSNumber numberWithFloat:progress]];
//				   NSLog(@"progress: %f",progress);
//			   });
//			}
		 withCompletionHandler:^ {
			 [self exportDidFinish];
		 }
	 ];
	
	NSArray *modes = [[[NSArray alloc] initWithObjects:NSDefaultRunLoopMode, UITrackingRunLoopMode, nil] autorelease];
	[self performSelector:@selector(updateExportProgress:) withObject:session	afterDelay:0.1 inModes:modes];
	
	NSLog(@"export end");
	
}


- (void)updateExportProgress:(AVAssetExportSession *)theSession
{
	
	if ([theSession status]==AVAssetExportSessionStatusExporting) {
		
		self.progress = [NSNumber numberWithFloat:[theSession progress]];
		NSArray *modes = [[[NSArray alloc] initWithObjects:NSDefaultRunLoopMode, UITrackingRunLoopMode, nil] autorelease];
		[self performSelector:@selector(updateExportProgress:) withObject:theSession afterDelay:0.1 inModes:modes];
	} else {
		self.progress = [NSNumber numberWithFloat:1.0f];
	}
	
	
	
}

- (void)exportDidFinish {
	MilgromViewController * milgromViewController = ((MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate]).milgromViewController;
	testApp *OFSAptr = ((MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate]).OFSAptr;
	
	
	OFSAptr->soundStreamStart();
	OFSAptr->setSongState(SONG_IDLE);
	[milgromViewController startAnimation];
	
	NSLog(@"exportDidFinish");
}



- (void)done:(id)sender {
	[(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] dismissModalViewControllerAnimated:YES];
}


@end
