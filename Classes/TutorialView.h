//
//  MilgromTutorial.h
//  Milgrom
//
//  Created by Roee Kremer on 2/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "ofxInteractiveTutorial.h"
#include "ofxInteractiveSlides.h"

enum  {
	MILGROM_TUTORIAL_INTRODUCTION,
	MILGROM_TUTORIAL_PUSH_PLAYER,
	MILGROM_TUTORIAL_CHANGE_LOOP,
	MILGROM_TUTORIAL_ROTATE,
	MILGROM_TUTORIAL_SLIDE,
	MILGROM_TUTORIAL_CONTROLS,
	MILGROM_TUTORIAL_RECORD_PLAY,
	
};

enum  {
	
	MILGROM_SLIDE_MENU,
	MILGROM_SLIDE_SOLO_MENU,
	MILGROM_SLIDE_SHARE
};



@interface TutorialView : UIView {	

	UIView *currentView;
	UIButton *currentButton;
	ofxInteractiveTutorial tutorial;
	ofxInteractiveSlides slides;
	BOOL bStartSlides;
	BOOL bFirstSlide;
}

@property (nonatomic, retain) UIView *currentView;
@property (nonatomic, retain) UIButton *currentButton;
@property (readonly) BOOL isTutorialActive;
@property (readonly) NSUInteger currentTutorialSlide;


- (void)update;
- (void)updateViews;
- (void)removeViews;

- (void)start;
- (void)test;

- (void)doneSlide:(int)slideNum;
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (void)willRotate;
@end


