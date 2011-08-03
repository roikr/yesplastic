//
//  SlidesManager.m
//  Milgrom
//
//  Created by Roee Kremer on 5/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SlidesManager.h"
#import "MilgromInterfaceAppDelegate.h"
#import "MainViewController.h"
#import "SoloViewController.h"
#import "ShareViewController.h"

#ifdef _FLURRY
#import "FlurryAPI.h"
#endif

@interface SlidesManager() 
- (void) next:(id)sender;

@end

@implementation SlidesManager

@synthesize currentView;
@synthesize currentButton;
@synthesize currentTutorialSlide;
@synthesize targetView;
@synthesize targetSlides;


+ (SlidesManager*) slidesManager {
	
	return [[[SlidesManager alloc] init] autorelease];
}


- (void)start {
	currentTutorialSlide = MILGROM_TUTORIAL_INTRODUCTION;
}

- (void)setTargetView:(UIView *)view withSlides:(UIView *)slides {
	self.targetView = view;
	self.targetSlides = slides;
}

- (void)removeViews {
	
	
	
	if (currentButton) {
		[currentButton removeFromSuperview];
		[currentView addSubview:currentButton];
		self.currentButton = nil;
	}
	if (currentView) {
		[currentView removeFromSuperview];
		[targetSlides addSubview:currentView];
		self.currentView = nil;
	}
}

- (void)addViews {
	
	if (currentTutorialSlide >= MILGROM_TUTORIAL_DONE || currentView) {
		return;
	}
	
	
	for (int i=0;i<[targetSlides.subviews count];i++) {
		UIView *view = (UIView*)[targetSlides.subviews objectAtIndex:i];
		
		if (view.tag == currentTutorialSlide) {
			
			self.currentView = view;
			[targetView addSubview:currentView];
			[targetView sendSubviewToBack:currentView];
			
			for (int i=0;i<[currentView.subviews count];i++) {
				
				UIView *buttonView = (UIView*)[currentView.subviews objectAtIndex:i];
				if ([buttonView isKindOfClass:[UIButton self]]) {
					self.currentButton = (UIButton*)buttonView;
					[currentButton addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
					[targetView addSubview:currentButton];
					[targetView bringSubviewToFront:currentButton];
					break;
				}
				
			}
			
#ifdef _FLURRY
			[FlurryAPI logEvent:@"SLIDE" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%i",currentTutorialSlide],@"NUMBER",nil]];
			[FlurryAPI logEvent:[NSString stringWithFormat:@"SLIDE_%i",currentTutorialSlide] timed:YES];
#endif
			
				
			break;
		}
	}
}


	
- (void) next:(id)sender {
	[self removeViews];
	
	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	if (currentTutorialSlide==MILGROM_TUTORIAL_SHARE) {
		[appDelegate.shareViewController tutorialShare];
	}
	
#ifdef _FLURRY
	[FlurryAPI endTimedEvent:[NSString stringWithFormat:@"SLIDE_%i",currentTutorialSlide] withParameters:nil];
#endif
	
	
	currentTutorialSlide++;
	
	[appDelegate.mainViewController updateViews];
	[appDelegate.soloViewController updateViews];
	
	
//	if (currentTutorialSlide == MILGROM_TUTORIAL_CHANGE_LOOP || currentTutorialSlide == MILGROM_TUTORIAL_SHARE) {
//		[appDelegate.mainViewController updateViews];
//		return ;
//	}
//	
//		
//	[self updateViews];
//	
//	if (currentTutorialSlide == MILGROM_TUTORIAL_ROTATE || currentTutorialSlide == MILGROM_TUTORIAL_MENU) {
//		[appDelegate.mainViewController updateViews];
//	}
//	
//	if (currentTutorialSlide == MILGROM_TUTORIAL_RECORD_PLAY || currentTutorialSlide == MILGROM_TUTORIAL_SOLO_MENU) {
//		[appDelegate.soloViewController updateViews];
//	}


}

- (void)doneSlide:(NSUInteger)slide {
	if (slide==currentTutorialSlide && self.currentView) {
		[self next:NULL];
	}
}


@end
