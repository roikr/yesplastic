//
//  MilgromTutorial.h
//  Milgrom
//
//  Created by Roee Kremer on 2/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "ofxInteractiveTutorial.h"

enum  {
	MILGROM_TUTORIAL_INTRODUCTION,
	MILGROM_TUTORIAL_PUSH_PLAYER,
	MILGROM_TUTORIAL_CHANGE_LOOP,
	MILGROM_TUTORIAL_ROTATE,
	MILGROM_TUTORIAL_SLIDE,
	MILGROM_TUTORIAL_CONTROLS,
//	MILGROM_TUTORIAL_SHAKE,
	MILGROM_TUTORIAL_SOLO_MENU,
	MILGROM_TUTORIAL_RECORD_PLAY,
	MILGROM_TUTORIAL_LEARN_MORE
};



@interface TutorialView : UIView {	
	UIButton *skipButton;
	UIView	*textView;
	ofxInteractiveTutorial tutorial;
	int lastSlide;
}

@property (nonatomic, retain) IBOutlet UIView *textView;
@property (nonatomic, retain) IBOutlet UIButton *skipButton;
@property (readonly) BOOL isActive;
@property (readonly) NSUInteger currentSlide;

- (void)update;
- (void)updateViews;
- (void) nextSlide:(id)sender;
- (void)start;

@end


