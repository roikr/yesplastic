//
//  MilgromViewController.m
//  Milgrom
//
//  Created by Roee Kremer on 8/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "MilgromViewController.h"
#import "EAGLView.h"
#import "MilgromInterfaceAppDelegate.h"
#include "testApp.h"
#import "BandMenu.h"
#import "PlayerMenu.h"
#import "MainViewController.h"
#import "HelpViewController.h"
#import "Constants.h"
#import "MilgromMacros.h"
#import "OpenGLTOMovie.h"
#import "AVPlayerDemoPlaybackViewController.h"
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>


@interface MilgromViewController ()
@property (nonatomic, retain) EAGLContext *context;
- (void) play;
- (void) export;
@end

@implementation MilgromViewController

@synthesize viewController;
@synthesize eAGLView;
@synthesize animating, context;

- (void)viewDidLoad {
    [super viewDidLoad];

    EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    
   
    if (!aContext)
        NSLog(@"Failed to create ES context");
    else if (![EAGLContext setCurrentContext:aContext])
        NSLog(@"Failed to set ES context current");
    
	self.context = aContext;
	[aContext release];
	
    [self.eAGLView setContext:context];
    [self.eAGLView setFramebuffer];
    
       
    animating = FALSE;
    displayLinkSupported = FALSE;
    animationFrameInterval = 1;
    displayLink = nil;
    animationTimer = nil;
    
    // Use of CADisplayLink requires iOS version 3.1 or greater.
	// The NSTimer object is used as fallback when it isn't available.
    NSString *reqSysVer = @"3.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
        displayLinkSupported = TRUE;
	
	[self.view addSubview:viewController.view];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	if ([self.viewController.visibleViewController isKindOfClass:[BandMenu self]]) {
		return interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight;
	} else if ([self.viewController.visibleViewController isKindOfClass:[PlayerMenu self]]) {
		return interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown;
	} else if ([self.viewController.visibleViewController isKindOfClass:[HelpViewController self]]) {
		return NO;
	}
   
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[self.viewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	[self.viewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
														  
	
	
}


- (void)dealloc
{
    
    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
    
    [context release];
	[viewController release];
    [eAGLView release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self startAnimation];
    
    [super viewWillAppear:animated];
	
	MilgromLog(@"MilgromViewController::viewWillAppear");
	[viewController viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopAnimation];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	

    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
	self.context = nil;	
}

- (NSInteger)animationFrameInterval
{
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
    /*
	 Frame interval defines how many display frames must pass between each time the display link fires.
	 The display link will only fire 30 times a second when the frame internal is two on a display that refreshes 60 times a second. The default frame interval setting of one will fire 60 times a second when the display refreshes at 60 times a second. A frame interval setting of less than one results in undefined behavior.
	 */
    if (frameInterval >= 1)
    {
        animationFrameInterval = frameInterval;
        
        if (animating)
        {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation
{
    if (!animating)
    {
        if (displayLinkSupported)
        {
            /*
			 CADisplayLink is API new in iOS 3.1. Compiling against earlier versions will result in a warning, but can be dismissed if the system version runtime check for CADisplayLink exists in -awakeFromNib. The runtime check ensures this code will not be called in system versions earlier than 3.1.
            */
            displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawFrame)];
            [displayLink setFrameInterval:animationFrameInterval];
            
            // The run loop will retain the display link on add.
            [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        }
        else
            animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationFrameInterval) target:self selector:@selector(drawFrame) userInfo:nil repeats:TRUE];
        
		startTime = CACurrentMediaTime();
		MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
		appDelegate.OFSAptr->lastFrame = -1;
        animating = TRUE;
    }
}

- (void)stopAnimation
{
    if (animating)
    {
        if (displayLinkSupported)
        {
            [displayLink invalidate];
            displayLink = nil;
        }
        else
        {
            [animationTimer invalidate];
            animationTimer = nil;
        }
        
        animating = FALSE;
    }
}

- (void)drawFrame
{
    [self.eAGLView setFramebuffer];
    
	
	if ([viewController.viewControllers count] > 1) {
		MainViewController *mainViewController = (MainViewController *)[viewController.viewControllers objectAtIndex:1];
		[mainViewController updateViews];
	}
	
	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (animating) {
		int frame = (int)(([displayLink timestamp]-startTime) * 1000 / 40);
		if (frame>appDelegate.OFSAptr->lastFrame) {
			appDelegate.OFSAptr->lastFrame = frame;
			appDelegate.OFSAptr->update();
		}
		glLoadIdentity();
		glScalef(1.0, -1.0,1.0);
		glTranslatef(0, -self.eAGLView.framebufferHeight, 0);
	} else {
		glLoadIdentity();
		appDelegate.OFSAptr->update();
	}

		
	
	
	
	appDelegate.OFSAptr->draw();
	
	//glPushMatrix();
	//glScalef(1.0, -1.0,1.0);
	//glTranslatef(0, framebufferHeight, 0);
    if (animating) {
		[self.eAGLView presentFramebuffer];
	}
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	MilgromLog(@"MilgromViewController::viewDidAppear");
	[viewController viewDidAppear:animated];
}

- (void)renderAnimation {
	[self stopAnimation];
	
	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	testApp *OFSAptr = [appDelegate OFSAptr];
	
	
	
	dispatch_queue_t myCustomQueue;
	myCustomQueue = dispatch_queue_create("renderQueue", NULL);
	
	dispatch_async(myCustomQueue, ^{
		OFSAptr->soundStreamStop();
		OFSAptr->renderAudio();
		OFSAptr->setSongState(SONG_RENDER_VIDEO);
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *videoPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"temp.mov"];
		
		
		
		[OpenGLTOMovie writeToVideoURL:[NSURL fileURLWithPath:videoPath] WithSize:CGSizeMake(480, 320) 
		 
						 withDrawFrame:^(int frameNum) {
							 //NSLog(@"rendering frame: %i",frameNum);
							 [self drawFrame];
							 
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
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *exportPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"video.mov"];
	
	NSError *error;
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath]) {
		if (![[NSFileManager defaultManager] removeItemAtPath:exportPath error:&error]) {
			NSLog(@"removeItemAtPath error: %@",[error description]);
		}
	}
	
	
	[OpenGLTOMovie exportToURL:[NSURL fileURLWithPath:exportPath]
				  withVideoURL:[NSURL fileURLWithPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"temp.mov"]] 
				  withAudioURL: [NSURL fileURLWithPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"temp.wav"]] //[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"temp" ofType:@"wav"]]
	 
		   withProgressHandler:^(float progress) {NSLog(@"progress: %f",progress);}
		 withCompletionHandler:^ {
			 NSLog(@"export completed");
			 dispatch_async(dispatch_get_main_queue(),
				^{
					MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
					appDelegate.OFSAptr->soundStreamStart();
					appDelegate.OFSAptr->setSongState(SONG_IDLE);
					[self startAnimation];
					[self play];
				});
			 
			
		 }
	 ];
	
	NSLog(@"export end");
	
}


-(void) play {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	
	
	AVPlayerDemoPlaybackViewController * mPlaybackViewController = [[AVPlayerDemoPlaybackViewController allocWithZone:[self zone]] init];
	
	[mPlaybackViewController setURL:[NSURL fileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"video.mov"]]]; 
	[[mPlaybackViewController player] seekToTime:CMTimeMakeWithSeconds(0.0, NSEC_PER_SEC) toleranceBefore:CMTimeMake(1, 2 * NSEC_PER_SEC) toleranceAfter:CMTimeMake(1, 2 * NSEC_PER_SEC)];
	
	[self.viewController pushViewController:mPlaybackViewController animated:NO];
	
}



@end
