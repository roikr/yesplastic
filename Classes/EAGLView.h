//
//  EAGLView.h
//  YepPlastic
//
//  Created by Roee Kremer on 1/9/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "ESRenderer.h"

#define	OF_MAX_TOUCHES			5		// iphone has max 5 finger support


// This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
// The view content is basically an EAGL surface you render your OpenGL scene into.
// Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
class testApp;
@class MainViewController;
@interface EAGLView : UIView
{    
@private
	id <ESRenderer> renderer;
	
	BOOL animating;
	
	NSInteger animationFrameInterval;
	// Use of the CADisplayLink class is the preferred method for controlling your animation timing.
	// CADisplayLink will link to the main display and fire every vsync when added to a given run-loop.
	// The NSTimer class is used only as fallback when running on a pre 3.1 device where CADisplayLink
	// isn't available.
	id displayLink;
    NSTimer *audioTimer;
	NSTimer * timer;
		
	UILabel *label;
	CFTimeInterval startTime;
	
	
	
	UITouch					*activeTouches[OF_MAX_TOUCHES];
	
	MainViewController *controller;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;
@property (nonatomic,retain) IBOutlet UILabel *label;
@property UIInterfaceOrientation interfaceOrientation;
@property (nonatomic,retain) NSTimer *timer;
@property (nonatomic,retain) MainViewController *controller;




- (void) startAnimation;
- (void) stopAnimation;
- (void) drawView:(id)sender;



@end
