//
//  MilgromViewController.h
//  Milgrom
//
//  Created by Roee Kremer on 8/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <OpenGLES/EAGL.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@class EAGLView;

@interface MilgromViewController : UIViewController
{
    UINavigationController *viewController;
	EAGLView *eAGLView;
	EAGLContext *context;
	
    BOOL animating;
    BOOL displayLinkSupported;
    NSInteger animationFrameInterval;
    /*
	 Use of the CADisplayLink class is the preferred method for controlling your animation timing.
	 CADisplayLink will link to the main display and fire every vsync when added to a given run-loop.
	 The NSTimer object is used only as fallback when running on a pre-3.1 device where CADisplayLink isn't available.
	 */
    id displayLink;
    NSTimer *animationTimer;
	CFTimeInterval startTime;
	
	EAGLContext *secondaryContext;
	
	NSInteger currentFrame;
	
}

@property (nonatomic, retain) IBOutlet UINavigationController *viewController;
@property (nonatomic,retain) IBOutlet EAGLView *eAGLView;

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;


- (void)setContextCurrent;
- (void)setSecondaryContextCurrent;
- (void)startAnimation;
- (void)stopAnimation;
- (void)drawFrame;
- (void)renderFrame;


@end
