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
#import "MainViewController.h"
#include "testApp.h"
#import "Constants.h"
#import "MilgromMacros.h"



@interface MilgromViewController ()
@property (nonatomic, retain) EAGLContext *secondaryContext;
@end

@implementation MilgromViewController

@synthesize viewController;
@synthesize eAGLView;
@synthesize animating, context,secondaryContext;

/*
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
				
    }
    return self;
}
 */

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
	return [self.viewController.visibleViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
	
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[self.viewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	
	MainViewController *mainViewController = [(MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate] mainViewController];
	if (self.viewController.visibleViewController != mainViewController) {
		[mainViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	}
	
	
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	[self.viewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	
	MainViewController *mainViewController = [(MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate] mainViewController];
	if (self.viewController.visibleViewController != mainViewController) {
		[mainViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	}
	
	
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
    [super viewWillAppear:animated]; // TODO: was deleted before, any bug ?
	MilgromLog(@"MilgromViewController::viewWillAppear");
	[self startAnimation];
    
    
	
	
	[viewController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	MilgromLog(@"MilgromViewController::viewDidAppear");
	[viewController viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopAnimation];
    
   // [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	

    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
	self.context = nil;	
}

- (void)setContextCurrent {
	[EAGLContext setCurrentContext:context];
}

- (void)setSecondaryContextCurrent {
	if (!secondaryContext) {
		secondaryContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1 
										 sharegroup:context.sharegroup];
		
	}
		
	if (!secondaryContext || ![EAGLContext setCurrentContext:secondaryContext]) {
		MilgromLog(@"setSecondaryContextCurrent error");
	}
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
        
		//startTime = CACurrentMediaTime();
		//currentFrame =0;
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


- (void)drawFrame // NORMAL_PLAY
{
    [self.eAGLView setFramebuffer];
    
	
	
//	int frame = (int)(([displayLink timestamp]-startTime) * 1000 / 40);
//	if (frame>currentFrame) {
//		currentFrame = frame;
//		appDelegate.OFSAptr->nextFrame();
//	}
	
	glLoadIdentity();
	glScalef(1.0, -1.0,1.0);
	glTranslatef(0, -self.eAGLView.framebufferHeight, 0);
	
	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.OFSAptr->draw();
	
	[self.eAGLView presentFramebuffer];
   
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}






@end
