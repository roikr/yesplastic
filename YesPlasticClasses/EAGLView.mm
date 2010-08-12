//
//  EAGLView.m
//  YepPlastic
//
//  Created by Roee Kremer on 1/9/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "EAGLView.h"

#import "ES1Renderer.h"
//#import "ES2Renderer.h"

#import "testApp.h"
#import "MainViewController.h"


@interface EAGLView ()

@end

@implementation EAGLView

@synthesize animating;
@synthesize label;
@synthesize interfaceOrientation;
@synthesize controller;
//@synthesize timer;


@dynamic animationFrameInterval;

// You must implement this method
+ (Class) layerClass
{
    return [CAEAGLLayer class];
}

//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id) initWithCoder:(NSCoder*)coder
{    
    if ((self = [super initWithCoder:coder]))
	{
        
		bzero(activeTouches, sizeof(activeTouches));
		// Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
		
		//renderer = [[ES2Renderer alloc] init];
		renderer = [[ES1Renderer alloc] init];
		
		if (!renderer)
		{
			renderer = [[ES1Renderer alloc] init];
			
			if (!renderer)
			{
				[self release];
				return nil;
			}
		}
        
		animating = FALSE;
		
		animationFrameInterval = 1;
		displayLink = nil;
		//audioTimer = nil;
		
		// A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
		// class is used as fallback when it isn't available.
		NSString *reqSysVer = @"3.1";
		NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
		
		if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
			NSLog(@"displayLinkSupported");
		
    }
	
    return self;
}



- (void) drawView:(id)sender
{
    
	//label.text = [NSString stringWithFormat:@"%f",[displayLink timestamp]-startTime];
	//label.text = [NSString stringWithFormat:@"%f",OFSAptr->vx];
	
	
	
	[controller checkState:nil];
	[renderer setupView];
	
	if (!sender) {
		controller.OFSAptr->lastFrame = 0;
		controller.OFSAptr->update();
	} else {
		int frame = (int)(([displayLink timestamp]-startTime) * 1000 / 40);
		if (frame>controller.OFSAptr->lastFrame) {
			controller.OFSAptr->lastFrame = frame;
			controller.OFSAptr->update();
		}
	}

	controller.OFSAptr->draw();
	
	[renderer finishRendering];
}

- (void) layoutSubviews
{
	[renderer resizeFromLayer:(CAEAGLLayer*)self.layer];
    [self drawView:nil]; // roikr: don't use displayLink is not defined yet
}

- (NSInteger) animationFrameInterval
{
	return animationFrameInterval;
}

- (void) setAnimationFrameInterval:(NSInteger)frameInterval
{
	// Frame interval defines how many display frames must pass between each time the
	// display link fires. The display link will only fire 30 times a second when the
	// frame internal is two on a display that refreshes 60 times a second. The default
	// frame interval setting of one will fire 60 times a second when the display refreshes
	// at 60 times a second. A frame interval setting of less than one results in undefined
	// behavior.
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

- (void) startAnimation
{
	if (!animating)
	{
		
			
		// CADisplayLink is API new to iPhone SDK 3.1. Compiling against earlier versions will result in a warning, but can be dismissed
		// if the system version runtime check for CADisplayLink exists in -initWithCoder:. The runtime check ensures this code will
		// not be called in system versions earlier than 3.1.
		
		displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawView:)];
		[displayLink setFrameInterval:animationFrameInterval];
		[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
		startTime = CACurrentMediaTime();
		
		//audioTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)(1.0 / 60.0) target:self selector:@selector(updateAudio:) userInfo:nil repeats:TRUE];
		
		//frameNumber = 0;
		animating = TRUE;
	}
}

- (void)stopAnimation
{
	if (animating)
	{
		
		[displayLink invalidate];
		displayLink = nil;
		
		//[audioTimer invalidate];
		//audioTimer = nil;
		
		
		animating = FALSE;
		
		controller.OFSAptr->exit();
	}
}

- (void) dealloc
{
    
	[renderer release];
	
    [super dealloc];
}


/******************* TOUCH EVENTS ********************/
//------------------------------------------------------
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
		//	NSLog(@"touchesBegan: %i %i %i", [touches count],  [[event touchesForView:self] count], multitouchData.numTouches);
	
	
	//self.timer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)(0.5) target:controller selector:@selector(bringPlayerMenu:) userInfo:nil repeats:NO];
	
	for(UITouch *touch in touches) {
		int touchIndex = 0;
		while(touchIndex < OF_MAX_TOUCHES && activeTouches[touchIndex] != 0) touchIndex++;
		if(touchIndex==OF_MAX_TOUCHES) {
			NSLog(@"touchesBegan - weird!");
			touchIndex=0;	
		}
		
		activeTouches[touchIndex] = touch;
		
		CGPoint touchPoint = [touch locationInView:self];
		
		if([touch tapCount] >= 1)
			controller.OFSAptr->touchDown(touchPoint.x, touchPoint.y, touchIndex);
		
		/*
		if([touch tapCount] == 1) 
			controller.OFSAptr->touchDown(touchPoint.x, touchPoint.y, touchIndex);
		else 
			controller.OFSAptr->touchDoubleTap(touchPoint.x, touchPoint.y, touchIndex);
		 */
	}
}

//------------------------------------------------------
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	//	NSLog(@"touchesMoved: %i %i %i", [touches count],  [[event touchesForView:self] count], multitouchData.numTouches);
	//[timer invalidate];
	//self.timer = nil;
	
	for(UITouch *touch in touches) {
		int touchIndex = 0;
		while(touchIndex < OF_MAX_TOUCHES && (activeTouches[touchIndex] != touch)) touchIndex++;
		if(touchIndex==OF_MAX_TOUCHES) {
			NSLog(@"touchesMoved - weird!");
			continue;	
		}
		
		CGPoint touchPoint = [touch locationInView:self];
		
				
		controller.OFSAptr->touchMoved(touchPoint.x, touchPoint.y, touchIndex);
	}
}

//------------------------------------------------------
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

	//[timer invalidate];
	//self.timer = nil;
	
	//	NSLog(@"touchesEnded: %i %i %i", [touches count],  [[event touchesForView:self] count], multitouchData.numTouches);
	
	for(UITouch *touch in touches) {
		int touchIndex = 0;
		while(touchIndex < OF_MAX_TOUCHES && (activeTouches[touchIndex] != touch)) touchIndex++;
		if(touchIndex==OF_MAX_TOUCHES) {
			NSLog(@"touchesEnded - weird!");
			continue;	
		}
		
		activeTouches[touchIndex] = 0;
		
		CGPoint touchPoint = [touch locationInView:self];
		
		
		
		controller.OFSAptr->touchUp(touchPoint.x, touchPoint.y, touchIndex);
	}
}

//------------------------------------------------------
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	//[timer invalidate];
	//self.timer = nil;
	
	for(int i=0; i<OF_MAX_TOUCHES; i++){
		if(activeTouches[i]){
			
			CGPoint touchPoint = [activeTouches[i] locationInView:self];
			activeTouches[i] = 0;
			
			
			controller.OFSAptr->touchUp(touchPoint.x, touchPoint.y, i);
		}
	}
}



@end
