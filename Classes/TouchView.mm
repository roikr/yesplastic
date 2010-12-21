//
//  TouchView.m
//  Milgrom
//
//  Created by Roee Kremer on 8/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TouchView.h"
#import "MilgromInterfaceAppDelegate.h"
#import "testApp.h"
#import "Constants.h"
#import "MainViewController.h"
#import "MilgromMacros.h"

@implementation TouchView

@synthesize viewController;
@synthesize renderTouch;


- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder: decoder])
    {
        bzero(activeTouches, sizeof(activeTouches));

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

/******************* TOUCH EVENTS ********************/
//------------------------------------------------------
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	
	//	NSLog(@"touchesBegan: %i %i %i", [touches count],  [[event touchesForView:self] count], multitouchData.numTouches);
	
	
	
//	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
//	if (appDelegate.OFSAptr->getSongState() == SONG_PLAY) {
//		return;
//	}
	
	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if (!renderTouch && appDelegate.OFSAptr->getSongState()==SONG_RENDER_VIDEO) {
		renderTouch = YES;
		[appDelegate.mainViewController updateViews];
	}
	
	
	if (appDelegate.mainViewController.bShowHelp) {
		return;
	}

	
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
		
		if([touch tapCount] == 2) {
			appDelegate.OFSAptr->touchDoubleTap(touchPoint.x, touchPoint.y, touchIndex);// send doubletap
		}
		
		//if([touch tapCount] >= 1) {
			
		appDelegate.OFSAptr->touchDown(touchPoint.x, touchPoint.y, touchIndex);
		//}
		
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
	
	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (appDelegate.mainViewController.bShowHelp) {
		return;
	}

	
	for(UITouch *touch in touches) {
		int touchIndex = 0;
		while(touchIndex < OF_MAX_TOUCHES && (activeTouches[touchIndex] != touch)) touchIndex++;
		if(touchIndex==OF_MAX_TOUCHES) {
			NSLog(@"touchesMoved - weird!");
			continue;	
		}
		
		CGPoint touchPoint = [touch locationInView:self];
		
		appDelegate.OFSAptr->touchMoved(touchPoint.x, touchPoint.y, touchIndex);
	}
}

//------------------------------------------------------
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	//[timer invalidate];
	//self.timer = nil;
	
	//	NSLog(@"touchesEnded: %i %i %i", [touches count],  [[event touchesForView:self] count], multitouchData.numTouches);
	
	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (appDelegate.mainViewController.bShowHelp) {
		[appDelegate.mainViewController hideHelp];
		return;
	}
	
	
	for(UITouch *touch in touches) {
		int touchIndex = 0;
		while(touchIndex < OF_MAX_TOUCHES && (activeTouches[touchIndex] != touch)) touchIndex++;
		if(touchIndex==OF_MAX_TOUCHES) {
			NSLog(@"touchesEnded - weird!");
			continue;	
		}
		
		activeTouches[touchIndex] = 0;
		
		CGPoint touchPoint = [touch locationInView:self];
	
//		int mode = appDelegate.OFSAptr->getMode(appDelegate.OFSAptr->controller);
		MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
		appDelegate.OFSAptr->touchUp(touchPoint.x, touchPoint.y, touchIndex);
		
//		if (mode!=appDelegate.OFSAptr->getMode(appDelegate.OFSAptr->controller)) {
//			[viewController updateViews];
//		}
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
			
			MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
			
			appDelegate.OFSAptr->touchUp(touchPoint.x, touchPoint.y, i);
		}
	}
}





- (void)dealloc {
	[viewController release];
    [super dealloc];
}


@end
