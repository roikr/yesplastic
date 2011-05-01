//
//  MilgromTutorial.m
//  Milgrom
//
//  Created by Roee Kremer on 2/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TutorialView.h"
#include "ofxInteractiveTutorial.h"
#include "MilgromInterfaceAppDelegate.h"
#include "MainViewController.h"

#include "Constants.h"
#include "testApp.h"

@interface TutorialView() 

- (void)updateWithTag:(int) currentTag;

- (void) skip:(id)sender;

@end




@implementation TutorialView

@synthesize currentView,currentButton;

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder: decoder])
    {
       
		tutorial.loadFile("tutorial.xml");
		slides.loadFile("slides.xml");
		
		bStartSlides = NO;
		
}
    return self;
}



- (void)start {
	if (!tutorial.getTimesCompleted()) {
		tutorial.start();
	}
	
	if (slides.getState()!=SLIDE_DONE) {
		bStartSlides = YES;
		slides.reset(); // move to idle if we exit app with slide on
		bFirstSlide = YES;
	}
}
	
	

- (void)test {
	tutorial.start();
	
	bStartSlides = YES;
	slides.restart();
	slides.reset(); // move to idle if we exit app with slide on
	bFirstSlide = YES;
}

- (void)update {
	
	
	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
	MainViewController * mainViewController = appDelegate.mainViewController;
	testApp * OFSAptr = appDelegate.OFSAptr;
	
	if (tutorial.getState() != TUTORIAL_IDLE ) {
				
		if (tutorial.getState() == TUTORIAL_READY ) {
			if (tutorial.getCurrentSlideNumber() == MILGROM_TUTORIAL_ROTATE) {
	
				if (mainViewController.stateButton.selected) { // TODO: fix here
					tutorial.skip();
				}
					
			}
		}
		
		tutorial.update();
	} else if (slides.getState() != SLIDE_DONE && bStartSlides) {
		
		if (bFirstSlide) {
			slides.reset();
			bFirstSlide = NO;
		} 
		
		if (slides.getState() == SLIDE_IDLE) {
			if ( OFSAptr->getSongState() == SONG_IDLE  && !OFSAptr->isInTransition()) {
				switch (mainViewController.interfaceOrientation) {
					case UIInterfaceOrientationLandscapeLeft:
					case UIInterfaceOrientationLandscapeRight:
						if (!slides.getIsDone(MILGROM_SLIDE_SHARE) && mainViewController.shareButton.hidden==NO) {
							slides.start(MILGROM_SLIDE_SHARE);
						} else if (!slides.getIsDone(MILGROM_SLIDE_MENU)) {
							slides.start(MILGROM_SLIDE_MENU);
						}
						break;
					case UIInterfaceOrientationPortrait:
					case UIInterfaceOrientationPortraitUpsideDown:
					
						if (!slides.getIsDone(MILGROM_SLIDE_SOLO_MENU)) {
							slides.start(MILGROM_SLIDE_SOLO_MENU);
						}
						break;

					default:
						break;
				}
			}
		}
	
		slides.update();
		
		
	}

	if (tutorial.getIsNeedRefresh() || slides.getIsNeedRefresh() ) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[mainViewController updateViews];
			
		});
		tutorial.setRefreshed();
		slides.setRefreshed();
		
	}
	
		
	
	
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (BOOL)isTutorialRotateble {
	return (tutorial.getCurrentSlideNumber() == MILGROM_TUTORIAL_ROTATE && tutorial.getState()==TUTORIAL_READY) || 
		(tutorial.getCurrentSlideNumber() == MILGROM_TUTORIAL_RECORD_PLAY && tutorial.getState()==TUTORIAL_TIMER_STARTED);
	
}

- (BOOL) isTutorialActive {
	return tutorial.getState()!= TUTORIAL_IDLE ;
}

- (BOOL) isSlidesActive {
	return slides.getState()!=SLIDE_IDLE;
}

- (NSUInteger) currentTutorialSlide  {
	return tutorial.getCurrentSlideNumber() ;
}

- (void)removeViews {
	
	
	
	if (currentButton) {
		[currentButton removeFromSuperview];
		[currentView addSubview:currentButton];
		self.currentButton = nil;
	}
	if (currentView) {
		[currentView removeFromSuperview];
		[self addSubview:currentView];
		self.currentView = nil;
	}
}

- (void)updateWithTag:(int) currentTag {
	
	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
	MainViewController * mainViewController = appDelegate.mainViewController;
	
	for (int i=0;i<[self.subviews count];i++) {
		UIView *view = (UIView*)[self.subviews objectAtIndex:i];
		
		if (view.tag == currentTag) {
			
			
			if (currentView && view!=currentView) {
				if (currentButton) {
					[currentButton removeFromSuperview];
					[currentView addSubview:currentButton];
					self.currentButton = nil;
				}
				
				[currentView removeFromSuperview];
				[self addSubview:currentView];
				self.currentView = nil;
			}
			
			if (!currentView) {
			
				self.currentView = view;
				[mainViewController.view addSubview:currentView];
				[mainViewController.view sendSubviewToBack:currentView];
				
				for (int i=0;i<[currentView.subviews count];i++) {
					
					UIView *buttonView = (UIView*)[currentView.subviews objectAtIndex:i];
					if ([buttonView isKindOfClass:[UIButton self]]) {
						self.currentButton = (UIButton*)buttonView;
						[currentButton addTarget:self action:@selector(skip:) forControlEvents:UIControlEventTouchUpInside];
						[mainViewController.view addSubview:currentButton];
						[mainViewController.view bringSubviewToFront:currentButton];
						break;
					}
					
				}
			}	
			break;
		}
	}
	
	
	
}




- (void)updateViews {
		
	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
	MainViewController * mainViewController = appDelegate.mainViewController;
	testApp * OFSAptr = appDelegate.OFSAptr;
	
	if (tutorial.getState()!= TUTORIAL_READY && slides.getState()!=SLIDE_READY || OFSAptr->getSongState() != SONG_IDLE  || OFSAptr->isInTransition() ) { 
		[self removeViews];
		return;
	}

//	CGSize mainSize = mainViewController.view.frame.size;
//	CGSize selfSize = self.frame.size;
//	self.transform = CGAffineTransformMakeTranslation((mainSize.width-selfSize.width)/2, (mainSize.height-selfSize.height)/2);
	
	
	
//	return OFSAptr->getSongState()!=SONG_RENDER_AUDIO && OFSAptr->getSongState()!=SONG_RENDER_AUDIO_FINISHED &&
//	OFSAptr->getSongState()!=SONG_RENDER_VIDEO && OFSAptr->getSongState()!=SONG_RENDER_VIDEO_FINISHED &&
//	[tutorialView canRotateToInterfaceOrientation:interfaceOrientation];

	if (tutorial.getState()==TUTORIAL_READY) {
			
		[self updateWithTag: tutorial.getCurrentSlideTag() ];
		
		switch (tutorial.getCurrentSlideNumber()) {
			case MILGROM_TUTORIAL_CHANGE_LOOP:
				currentView.hidden = YES;
				currentButton.hidden = YES;
				int i;
				for (i=0; i<3; i++) {
					if (OFSAptr->getMode(i) == LOOP_MODE) {
						currentView.hidden = NO;
						currentButton.hidden = NO;
						break;
					}
				}
				break;

			default:
				
				break;
		}
		
	}
				
		
	if (slides.getState() == SLIDE_READY) {
		
		[self updateWithTag: slides.getCurrentSlideTag() ];
		
		switch (slides.getCurrentSlideNumber()) {
			case MILGROM_SLIDE_MENU:
			case MILGROM_SLIDE_SHARE:
				currentView.hidden = currentButton.hidden = mainViewController.interfaceOrientation == UIInterfaceOrientationPortrait || mainViewController.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown;
				break;
				
			case MILGROM_SLIDE_SOLO_MENU:
				currentView.hidden = currentButton.hidden = mainViewController.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || mainViewController.interfaceOrientation == UIInterfaceOrientationLandscapeRight;
				break;
			default:
				
				
				break;
		}
		
		currentView.hidden = currentButton.hidden = mainViewController.bShowHelp;				
		
	}
	

}

- (void) skip:(id)sender {
	if (self.isTutorialActive) {
		tutorial.skip();
	} else if (slides.getState()!=SLIDE_DONE) {
		slides.skip();
	}
}

- (void)doneSlide:(int)slideNum {
	slides.done(slideNum); // TODO: check if loaded
}



- (void)willRotate {
	if (slides.getState() != SLIDE_DONE && slides.getState() != SLIDE_IDLE ) {
		if (slides.getState() == SLIDE_READY) {
			slides.done(slides.getCurrentSlideNumber());
		}
		slides.reset();
	}
}

- (void)dealloc {
    [super dealloc];
}


@end
