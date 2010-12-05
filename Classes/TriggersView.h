//
//  TriggersView.h
//  Milgrom
//
//  Created by Roee Kremer on 12/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


#define	OF_MAX_TOUCHES			5		// iphone has max 5 finger support

struct touch {
	int button;
	bool movedOut;
};

@interface TriggersView : UIView {
	UITouch					*activeTouches[OF_MAX_TOUCHES];
	touch myTouches[OF_MAX_TOUCHES];
}

@end
