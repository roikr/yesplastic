//
//  TriggersView.m
//  Milgrom
//
//  Created by Roee Kremer on 12/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TriggersView.h"
#import "MilgromInterfaceAppDelegate.h"
#import "testApp.h"


@implementation TriggersView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
    [super dealloc];
}


/******************* TOUCH EVENTS ********************/
//------------------------------------------------------
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	
	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
//	
//	
//	if (appDelegate.mainViewController.bShowHelp) {
//		return;
//	}
	
	
	
	for(UITouch *touch in touches) {
		int touchIndex = 0;
		while(touchIndex < OF_MAX_TOUCHES && activeTouches[touchIndex] != 0) touchIndex++;
		if(touchIndex==OF_MAX_TOUCHES) {
			NSLog(@"touchesBegan - weird!");
			touchIndex=0;	
		}
		
		activeTouches[touchIndex] = touch;
		
		CGPoint touchPoint = [touch locationInView:self];
		
		NSLog(@"TriggersView::touchesBegan %f %f %i",touchPoint.x, touchPoint.y, touchIndex);
	
		myTouches[touchIndex].button =(int) MIN(1,touchPoint.y/60)*4+(int)MIN(3,touchPoint.x/80);
		myTouches[touchIndex].movedOut = false;
		//appDelegate.OFSAptr->buttonPressed(button);
		NSLog(@"TriggersView::buttonPressed: %i",myTouches[touchIndex].button);
//		frame.origin.x = (i % 4)*80+5;
//		frame.origin.y = (int)(i/4) * 60;
//		frame.size.width = 70;
//		frame.size.height = 60;
		
	}
}

//------------------------------------------------------
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	for(UITouch *touch in touches) {
		int touchIndex = 0;
		while(touchIndex < OF_MAX_TOUCHES && (activeTouches[touchIndex] != touch)) touchIndex++;
		if(touchIndex==OF_MAX_TOUCHES) {
			NSLog(@"touchesMoved - weird!");
			continue;	
		}
		
		CGPoint touchPoint = [touch locationInView:self];
		
		NSLog(@"TriggersView::touchesMoved %f %f %i",touchPoint.x, touchPoint.y, touchIndex);
	}
	
	
}

//------------------------------------------------------
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	for(UITouch *touch in touches) {
		int touchIndex = 0;
		while(touchIndex < OF_MAX_TOUCHES && (activeTouches[touchIndex] != touch)) touchIndex++;
		if(touchIndex==OF_MAX_TOUCHES) {
			NSLog(@"touchesEnded - weird!");
			continue;	
		}
		
		activeTouches[touchIndex] = 0;
		
		CGPoint touchPoint = [touch locationInView:self];
		
		
		//NSLog(@"TriggersView::touchesEnded %f %f %i",touchPoint.x, touchPoint.y, touchIndex);
		
		
	}
}

//------------------------------------------------------
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
	for(int i=0; i<OF_MAX_TOUCHES; i++){
		if(activeTouches[i]){
			
			CGPoint touchPoint = [activeTouches[i] locationInView:self];
			activeTouches[i] = 0;
			
			//NSLog(@"TriggersView::touchesCancelled %i",i);
			
			
		}
	}
}




@end
