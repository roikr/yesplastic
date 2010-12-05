//
//  Trigger.m
//  Milgrom
//
//  Created by Roee Kremer on 12/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Trigger.h"


@implementation Trigger


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
	[super sendAction:action to:target forEvent:event];
	
	for(UITouch *touch in [event allTouches]) {
		
		
		CGPoint touchPoint = [touch locationInView:self];
		
		NSLog(@"sendAction: %f %f %i %i",touchPoint.x, touchPoint.y,touch.phase,touch.tapCount);
	}
	
	
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


@end
