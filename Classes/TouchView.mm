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
#import "SoloViewController.h"
#import "MilgromMacros.h"


@implementation TouchView

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
	if (appDelegate.mainViewController.bShowHelp || appDelegate.soloViewController.bShowHelp ) {
		return;
	}
	
//	if (!renderTouch && appDelegate.OFSAptr->getSongState()==SONG_RENDER_VIDEO) {
//		renderTouch = YES;
//		[appDelegate.mainViewController updateViews];
//	}
	
	
	
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
	if (appDelegate.mainViewController.bShowHelp || appDelegate.soloViewController.bShowHelp) {
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
	if (appDelegate.mainViewController.bShowHelp ) {
		[appDelegate.mainViewController hideHelp];
		return;
	}
	
	if (appDelegate.soloViewController.bShowHelp ) {
		[appDelegate.soloViewController hideHelp];
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
	

		testApp *OFSAptr = appDelegate.OFSAptr;
		
		int mode = OFSAptr->getMode(OFSAptr->controller);
		
		OFSAptr->touchUp(touchPoint.x, touchPoint.y, touchIndex);


		if (mode!=OFSAptr->getMode(OFSAptr->controller)) {
			
			toggle[OFSAptr->controller]++;
			
		}
		
		
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

- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	MilgromLog(@"shake began");
	shakeStartTime = [NSDate timeIntervalSinceReferenceDate];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
	NSTimeInterval diff = [NSDate timeIntervalSinceReferenceDate]-shakeStartTime;
	MilgromLog(@"shake ended: %2.2f",diff);
	testApp *OFSAptr = ((MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate]).OFSAptr;
	
	if (  diff > 0.1 && diff < 1.0 && (OFSAptr->getSongState()==SONG_IDLE || OFSAptr->getSongState()==SONG_RECORD || OFSAptr->getSongState()==SONG_TRIGGER_RECORD)) { // !tutorialView.isTutorialActive &&
		OFSAptr->playRandomLoop();
	}
}

-(int) getCounter:(int)number {
	return toggle[number];
}

-(void) resetCounters  {
	for (int i=0; i<3; i++) {
		toggle[i] = 0;
	}
}

- (void)dealloc {
    [super dealloc];
}


@end
