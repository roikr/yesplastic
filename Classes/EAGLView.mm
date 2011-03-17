//
//  EAGLView.m
//  Milgrom
//
//  Created by Roee Kremer on 8/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "EAGLView.h"
#import "glu.h"

#import "MilgromInterfaceAppDelegate.h"
#import "MilgromMacros.h"
#include "testApp.h"
#include "Constants.h"

@interface EAGLView (PrivateMethods)
- (void)createFramebuffer;
- (void)deleteFramebuffer;

@end

@implementation EAGLView

@dynamic context;
@synthesize framebufferHeight;
@synthesize animating, secondaryContext;

// You must implement this method
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

//The EAGL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:.
- (id)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
	if (self)
    {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                        nil];
		
		EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
		
		
		if (!aContext)
			NSLog(@"Failed to create ES context");
		else if (![EAGLContext setCurrentContext:aContext])
			NSLog(@"Failed to set ES context current");
		
		self.context = aContext;
		[aContext release];
		
		
		[self setContext:context];
		[self setFramebuffer];
		
		
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
		
		//[self.view addSubview:viewController.view];
		
		[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:)
													 name:UIDeviceOrientationDidChangeNotification object:nil];
		
    }
    
    return self;
}

- (void)dealloc
{
    [self deleteFramebuffer];    
	
	if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
    
	self.context = nil;	
    [context release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    [super dealloc];
}

- (EAGLContext *)context
{
    return context;
}

- (void)setContext:(EAGLContext *)newContext
{
    if (context != newContext)
    {
        [self deleteFramebuffer];
        
        [context release];
        context = [newContext retain];
        
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)createFramebuffer
{
    if (context && !defaultFramebuffer)
    {
        [EAGLContext setCurrentContext:context];
        
        // Create default framebuffer object.
        glGenFramebuffers(1, &defaultFramebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
        
        // Create color render buffer and allocate backing store.
        glGenRenderbuffers(1, &colorRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
        [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &framebufferWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &framebufferHeight);
		NSLog(@"framebuffer: width: %i, height: %i", framebufferWidth,framebufferHeight);
        
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
        
        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
            NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
		
		glViewport(0, 0, framebufferWidth, framebufferHeight);
		
		//glViewport(0, 0, backingWidth, backingHeight);
		/*
		float halfFov, theTan, screenFov, aspect;
		screenFov 		= 60.0f;
		
		eyeY 		= (float)framebufferHeight / 2.0;
		eyeX 		= (float)framebufferWidth / 2.0;
		halfFov 		= M_PI * screenFov / 360.0;
		theTan 			= tanf(halfFov);
		dist 		= eyeY / theTan;
		float nearDist 	= dist / 10.0;	// near / far clip plane
		float farDist 	= dist * 10.0;
		aspect 			= (float)framebufferWidth/(float)framebufferHeight;
		
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		gluPerspective(screenFov, aspect, nearDist, farDist);
		
		glMatrixMode(GL_MODELVIEW);
		 */
		
		glMatrixMode (GL_PROJECTION);
		glLoadIdentity ();
		gluOrtho2D (0, framebufferWidth, 0, framebufferHeight);
		glMatrixMode(GL_MODELVIEW);
		
    }
}

- (void)deleteFramebuffer
{
    if (context)
    {
        [EAGLContext setCurrentContext:context];
        
        if (defaultFramebuffer)
        {
            glDeleteFramebuffers(1, &defaultFramebuffer);
            defaultFramebuffer = 0;
        }
        
        if (colorRenderbuffer)
        {
            glDeleteRenderbuffers(1, &colorRenderbuffer);
            colorRenderbuffer = 0;
        }
    }
}

- (void)setFramebuffer
{
    if (context)
    {
        [EAGLContext setCurrentContext:context];
        
        if (!defaultFramebuffer)
            [self createFramebuffer];
        
        glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
		
		glViewport(0, 0, framebufferWidth, framebufferHeight);

        /*
		glLoadIdentity();
		gluLookAt(eyeX, eyeY, dist, eyeX, eyeY, 0.0, 0.0, 1.0, 0.0);
		*/
		//glRotatef(90, 0.0, 0.0, 1.0	);
		
		
		//glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
		//glClear(GL_COLOR_BUFFER_BIT);
		 
        		
    }
}

- (BOOL)presentFramebuffer
{
    BOOL success = FALSE;
    
    if (context)
    {
        [EAGLContext setCurrentContext:context];
        
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
        
        success = [context presentRenderbuffer:GL_RENDERBUFFER];
    }
    
    return success;
}

- (void)layoutSubviews
{
    // The framebuffer will be re-created at the beginning of the next setFramebuffer method call.
    [self deleteFramebuffer];
}


// moved from MilgromViewController

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
    
	[self setFramebuffer];
    
	
	
	//	int frame = (int)(([displayLink timestamp]-startTime) * 1000 / 40);
	//	if (frame>currentFrame) {
	//		currentFrame = frame;
	//		appDelegate.OFSAptr->nextFrame();
	//	}
	
	glLoadIdentity();
	glScalef(1.0, -1.0,1.0);
	glTranslatef(0, -self.framebufferHeight, 0);
	
	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	appDelegate.OFSAptr->draw();
	
	[self presentFramebuffer];
	
}

- (void)orientationChanged:(NSNotification *)notification
{
	UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	switch (deviceOrientation) {
		case UIDeviceOrientationPortrait:
		case UIDeviceOrientationPortraitUpsideDown:
		case UIDeviceOrientationLandscapeLeft:
		case UIDeviceOrientationLandscapeRight:
			UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation) deviceOrientation;
			if ([appDelegate.viewController.topViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation]) {
				[self setInterfaceOrientation:interfaceOrientation duration:0.3];
			}
			break;
	}
	
}

- (void)setInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	
	
	switch (toInterfaceOrientation) {
		case UIInterfaceOrientationPortrait: {
			
			appDelegate.OFSAptr->setState(SOLO_STATE);
			[UIView animateWithDuration:duration delay:0
								options: UIViewAnimationOptionTransitionNone | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction// UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse |
							 animations:^{
								 self.center = CGPointMake(240, 240);
								 self.transform = CGAffineTransformMakeRotation(0);
								 
								 
							 } 
							 completion:NULL];
		} break;
		case UIInterfaceOrientationPortraitUpsideDown: {
			
			appDelegate.OFSAptr->setState(SOLO_STATE);
			[UIView animateWithDuration:duration delay:0
								options: UIViewAnimationOptionTransitionNone | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction// UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse |
							 animations:^{
								 self.center = CGPointMake(80, 240);
								 self.transform = CGAffineTransformMakeRotation(M_PI);
								 

							 } 
							 completion:NULL];
		} break;
		case UIInterfaceOrientationLandscapeRight: {
			appDelegate.OFSAptr->setState(BAND_STATE);
			[UIView animateWithDuration:duration delay:0
								options: UIViewAnimationOptionTransitionNone | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction// UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse |
							 animations:^{
								 self.center = CGPointMake(80, 240);
								 self.transform = CGAffineTransformMakeRotation(0.5*M_PI);
							 } 
							 completion:NULL];
		} break;
		case UIInterfaceOrientationLandscapeLeft: {
			appDelegate.OFSAptr->setState(BAND_STATE);
			[UIView animateWithDuration:duration delay:0
								options: UIViewAnimationOptionTransitionNone | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction// UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse |
							 animations:^{
								 self.center = CGPointMake(240, 240);
								 self.transform = CGAffineTransformMakeRotation(1.5*M_PI);
							 } 
							 completion:NULL];
		} break;
		default:
			break;
	}
}

@end
