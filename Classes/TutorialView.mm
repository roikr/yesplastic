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
@end




@implementation TutorialView

@synthesize textView;
@synthesize skipButton;

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder: decoder])
    {
       
		tutorial.loadFile("tutorial.xml");
		tutorial.start();
		lastSlide = tutorial.getCurrentNumber();
		
		//if (tutorial.getTimesCompleted()>3) {
		//	tutorial.setState(TUTORIAL_DONE);
		//}
    }
    return self;
}

- (void)update {
	
	if (tutorial.getState() == TUTORIAL_DONE) {
		return;
	}
	
	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
	MainViewController * mainViewController = appDelegate.mainViewController;
	
	tutorial.update();
	if (tutorial.getCurrentNumber() !=lastSlide) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[mainViewController updateViews];
			
		});
		lastSlide = tutorial.getCurrentNumber();
	}
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/



- (BOOL) isActive {
	return tutorial.getState()!= TUTORIAL_DONE;
}

- (NSUInteger) currentSlide  {
	return tutorial.getCurrentNumber();
}


- (void)updateViews {
		
	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
	MainViewController * mainViewController = appDelegate.mainViewController;
	
	if (tutorial.getState()== TUTORIAL_DONE) { 
		if ([mainViewController.view.subviews containsObject:self]) {
			[self removeFromSuperview];
		}
		return;
	}
		
	if (![mainViewController.view.subviews containsObject:self]) {
		[mainViewController.view addSubview:self];
		
		//[mainViewController.view bringSubviewToFront:mainViewController.interactionView];
	}

	self.hidden = YES;
	self.skipButton.hidden = NO;
	
	CGSize mainSize = mainViewController.view.frame.size;
	CGSize selfSize = self.frame.size;
	self.transform = CGAffineTransformMakeTranslation((mainSize.width-selfSize.width)/2, (mainSize.height-selfSize.height)/2);
	
	testApp * OFSAptr = appDelegate.OFSAptr;

	if ( OFSAptr->getSongState() == SONG_IDLE &&  tutorial.getState() == TUTORIAL_READY && !OFSAptr->isInTransition()) {
						
		for (int i=0;i<[self.textView.subviews count];i++) {
			UIView *view = (UIView*)[self.textView.subviews objectAtIndex:i];
			view.hidden = view.tag != tutorial.getCurrentNumber();
		}
		
		switch (tutorial.getCurrentNumber()) {
			case MILGROM_TUTORIAL_ROTATE:
				
				//self.hidden = self.OFSAptr->getState() != BAND_STATE;
				if (OFSAptr->getState() == BAND_STATE) {
					self.hidden = NO;
					self.skipButton.hidden = YES;
				} else {
					tutorial.skip();
				}
				break;
			default:
				self.hidden = NO;
							
				break;
		}
	} 

}

- (void) nextSlide:(id)sender {
	tutorial.skip();
	[self updateViews];
}

- (void)dealloc {
    [super dealloc];
}


@end
