//
//  SlidesManager.h
//  Milgrom
//
//  Created by Roee Kremer on 5/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum  {
	MILGROM_TUTORIAL_INTRODUCTION,
	MILGROM_TUTORIAL_PUSH_PLAYER,
	MILGROM_TUTORIAL_CHANGE_LOOP,
	MILGROM_TUTORIAL_ROTATE,
	MILGROM_TUTORIAL_SLIDE,
	MILGROM_TUTORIAL_CONTROLS,
	MILGROM_TUTORIAL_RECORD_PLAY,
	MILGROM_TUTORIAL_SHARE,
	MILGROM_TUTORIAL_DONE
};

@interface SlidesManager : NSObject {
	UIView *currentView;
	UIButton *currentButton;
	NSUInteger currentTutorialSlide;
	
	UIView *targetView;
	UIView *targetSlides;
}

@property (nonatomic, retain) UIView *currentView;
@property (nonatomic, retain) UIButton *currentButton;
@property NSUInteger currentTutorialSlide;
@property (nonatomic, retain) UIView *targetView;
@property (nonatomic, retain) UIView *targetSlides;

+ (SlidesManager*) slidesManager;
- (void)start;
- (void)setTargetView:(UIView *)view withSlides:(UIView *)slides;
- (void)addViews;
- (void)doneSlide:(NSUInteger)slide;
- (void)removeViews;
@end
