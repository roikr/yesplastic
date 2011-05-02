//
//  MainViewController.mm
//  YesPlastic
//
//  Created by Roee Kremer on 2/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "SoloViewController.h"

#include "Constants.h"
#include "testApp.h"

#import "MilgromInterfaceAppDelegate.h"
#import "TouchView.h"
#import "SlidesManager.h"
#import "MilgromMacros.h"
#import "Song.h"
#import "CustomImageView.h"
#import "ShareManager.h"
#import "MilgromUtils.h"




//#import "Trigger.h"

@interface MainViewController() 

- (void) fadeOutRecordButton;
- (void) fadeInRecordButton;
@end

@implementation MainViewController

@synthesize stateButton;
@synthesize playButton;
@synthesize stopButton;
@synthesize recordButton;
@synthesize menuButton;
@synthesize saveButton;
@synthesize shareButton;
@synthesize infoButton;
@synthesize bandLoopsView;
@synthesize loopsImagesView;

@synthesize bandHelp;
@synthesize bShowHelp;

@synthesize interactionView;
@synthesize slides;

@synthesize shareProgressView;



/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
		
	
	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
	OFSAptr = appDelegate.OFSAptr;
	
	//[(TouchView*)self.view  setViewController:self];
	bShowHelp = NO;
	bInteractiveHelp = NO;
	bAnimatingRecord = NO;
	
	self.shareProgressView.image =  [UIImage imageNamed:@"SHARE_B.png"];
	
	for (int i=0;i<[loopsImagesView.subviews count];i++) {
		UIImageView *imageView = (UIImageView*)[loopsImagesView.subviews objectAtIndex:i];
		imageView.hidden = YES;
	}
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return interfaceOrientation == UIInterfaceOrientationLandscapeRight || interfaceOrientation==UIInterfaceOrientationLandscapeLeft;
}


/*

- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration completion:(void (^)(void))completionHandler {
	NSLog(@"rotateToInterfaceOrientation %u",toInterfaceOrientation );
	
	
	[UIView animateWithDuration:duration delay:0 options: UIViewAnimationOptionTransitionNone | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction// UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse |
					 animations:^{
						 //self.view.frame = CGRectMake(0.0, 0.0, 320.0, 480.0);
						 self.view.transform = CGAffineTransformIdentity;
						 
						 switch (toInterfaceOrientation) {
							 case UIInterfaceOrientationPortrait: 
								 self.view.transform = CGAffineTransformMakeRotation(-0.5*M_PI);
								 break;
							 case UIInterfaceOrientationLandscapeRight: 
								 self.view.transform = CGAffineTransformMakeRotation(0);
								 break;
							 
						 }
						 
						 switch (toInterfaceOrientation) {
							 case UIInterfaceOrientationPortrait: 
							 case UIInterfaceOrientationPortraitUpsideDown: 
								 self.view.bounds = CGRectMake(0.0f, 0.0f, 320.0f, 480.0f);
								 break;
							 case UIInterfaceOrientationLandscapeRight: 
							 case UIInterfaceOrientationLandscapeLeft: 
								 self.view.bounds = CGRectMake(0.0f, 0.0f, 480.0f, 320.0f);
								 break;
						 }
						 
						 self.view.center = CGPointMake(240.0f, 160.0f);
						 
						 
						 
					 } 
					 completion:^(BOOL finished) {
						 if (completionHandler) {
							 completionHandler();
						 }
						 
					 }
	 ];
	
	
	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate.eAGLView setInterfaceOrientation:toInterfaceOrientation duration:duration];
}

*/

- (void)updateViews {
	
	
	
	stateButton.hidden = YES;
	playButton.hidden = YES;
	recordButton.hidden = YES;
	stopButton.hidden = YES;
	menuButton.hidden = YES;
	saveButton.hidden = YES;
	bandLoopsView.hidden = YES;
	loopsImagesView.hidden = YES;
	recordButton.selected = OFSAptr->getSongState() == SONG_TRIGGER_RECORD || OFSAptr->getSongState() == SONG_RECORD;
	shareButton.hidden = YES;
	infoButton.hidden = YES;
	shareProgressView.hidden = YES;	
	
	self.interactionView.userInteractionEnabled = !bShowHelp;
	if (bShowHelp) {
		
		if (![self.view.subviews containsObject:bandHelp]) {
			[self.view addSubview:bandHelp];
			//[self.view bringSubviewToFront:bandHelp];
		}
		
	} else {
		
		if ([self.view.subviews containsObject:bandHelp]) {
			[bandHelp removeFromSuperview];
		}
	}

	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate];
	
		
		
		
	if (![[appDelegate shareManager] isUploading]) {
		[self setShareProgress:1.0f];
	}
	
	
	if (!OFSAptr->isInTransition()  ) {
		switch (OFSAptr->getSongState()) {
			case SONG_IDLE:
			case SONG_RECORD:
			case SONG_TRIGGER_RECORD: {
				
				playButton.hidden = appDelegate.slidesManager.currentTutorialSlide < MILGROM_TUTORIAL_RECORD_PLAY;
				
				
				menuButton.hidden = OFSAptr->getSongState() != SONG_IDLE || appDelegate.slidesManager.currentTutorialSlide < MILGROM_TUTORIAL_MENU;
				bandLoopsView.hidden = NO;
				for (int i=0;i<[bandLoopsView.subviews count];i++) {
					UIButton *button = (UIButton*)[bandLoopsView.subviews objectAtIndex:i];
					//MilgromLog(@"button: %i, tag: %i, mode: %i",i, button.tag,OFSAptr->getMode(button.tag));
					//button.selected = ;
					button.hidden = OFSAptr->getMode(button.tag) == MANUAL_MODE;
				}
				
				loopsImagesView.hidden = NO;
				for (int i=0;i<[loopsImagesView.subviews count];i++) {
					UIImageView *imageView = (UIImageView*)[loopsImagesView.subviews objectAtIndex:i];
					//MilgromLog(@"button: %i, tag: %i, mode: %i",i, button.tag,OFSAptr->getMode(button.tag));
					//button.selected = ;
					NSString *loopName = [NSString stringWithFormat:@"%@_LOOP_%i.png",[NSString stringWithCString:OFSAptr->getPlayerName(i).c_str() encoding:NSASCIIStringEncoding],OFSAptr->getCurrentLoop(i)+1];
					[imageView setImage:[UIImage imageNamed:loopName]];
					
					if (OFSAptr->getMode(imageView.tag) == LOOP_MODE) {
						if (imageView.hidden) {
							imageView.hidden = NO;	
							imageView.alpha = 1.0;
							[UIView animateWithDuration:0.1 delay:0.5
												options: UIViewAnimationOptionTransitionNone | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction// UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse |
											 animations:^{imageView.alpha = 0.0;} 
											 completion:NULL];
						}
					} else {
						imageView.hidden = YES;
					}
						
				}

				
				
								
			} break;	
				
			case SONG_PLAY:
				
				stopButton.hidden = NO;
				
			default:
				break;
		
		}
		
		
		
		
		
		saveButton.hidden = OFSAptr->getSongVersion() == appDelegate.lastSavedVersion;
		
					
		BOOL shareEnabled =  [appDelegate.currentSong.bDemo boolValue] ? OFSAptr->getSongVersion() != appDelegate.lastSavedVersion : 
		OFSAptr->getSongVersion();  //  not a demo
		BOOL isUploading = [appDelegate.shareManager isUploading];
		
		shareButton.userInteractionEnabled = shareEnabled || isUploading; // && !isUploading - to disable when uploading
		shareButton.hidden = shareProgressView.hidden = !isUploading && !shareEnabled;
		
		
		
		
		stateButton.hidden = appDelegate.slidesManager.currentTutorialSlide != MILGROM_TUTORIAL_ROTATE && appDelegate.slidesManager.currentTutorialSlide < MILGROM_TUTORIAL_RECORD_PLAY;
		recordButton.hidden =  appDelegate.slidesManager.currentTutorialSlide < MILGROM_TUTORIAL_RECORD_PLAY;
		infoButton.hidden = appDelegate.slidesManager.currentTutorialSlide < MILGROM_TUTORIAL_RECORD_PLAY; // OFSAptr->getSongState() != SONG_IDLE;
		
		if (!bAnimatingRecord && OFSAptr->getSongState() == SONG_RECORD) {
			bAnimatingRecord = YES;
			[self fadeOutRecordButton];
		}
		
	}
	
	if (!appDelegate.slidesManager.currentView) {
		if (appDelegate.slidesManager.currentTutorialSlide == MILGROM_TUTORIAL_CHANGE_LOOP) {
			for (int i=0; i<3; i++) {
				if (OFSAptr->getMode(i) == LOOP_MODE) {
					[appDelegate.slidesManager updateViews];
					break;
				}
			}
		}
		
		if (appDelegate.slidesManager.currentTutorialSlide == MILGROM_TUTORIAL_SHARE) {
			if (self.shareButton.hidden==NO) {
				[appDelegate.slidesManager updateViews];
			}
		}
	}
	
		
}




- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	MilgromLog(@"MainViewController::viewWillAppear");
	MilgromInterfaceAppDelegate * appDelegate = (MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate.slidesManager setTargetView:self.view withSlides:self.slides];
	[self updateViews];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	MilgromLog(@"MainViewController::viewDidAppear");
    [self.view becomeFirstResponder]; // this is for the shake detection
	self.view.hidden = NO;
}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	MilgromLog(@"MainViewController::viewWillDisappear");
	 [self.view resignFirstResponder]; // this is for the shake detection
	self.view.hidden = YES;
	
}


- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	MilgromLog(@"MainViewController::viewDidDisappear");	
}

#pragma mark Buttons

- (void) toggle:(id)sender {
	
	MilgromInterfaceAppDelegate * appDelegate = (MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate.slidesManager doneSlide:MILGROM_TUTORIAL_ROTATE];
	[appDelegate toggle:UIInterfaceOrientationPortrait];
}


- (void) menu:(id)sender {
	
	
	
	if (OFSAptr->getSongState()==SONG_RECORD ) {
		OFSAptr->setSongState(SONG_IDLE);
	}
	
	
	MilgromInterfaceAppDelegate * appDelegate = (MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	[appDelegate.slidesManager doneSlide:MILGROM_TUTORIAL_MENU];
	OFSAptr->stopLoops();
	[self.navigationController popViewControllerAnimated:YES]; 
		
	
	
	
}



- (void) play:(id)sender {
	
		
	if (recordButton.selected) {
		[self stop:nil];
	}
		
	if (OFSAptr->getSongVersion()) {
		OFSAptr->setSongState(SONG_PLAY);
	} else {
		MilgromAlert(@"Can't  play", @"go record something first");
	}

	
	
	
}

- (void) stop:(id)sender {
	
	OFSAptr->setSongState(SONG_IDLE);
}

- (void) record:(id)sender {
	
	
	if (playButton.hidden) {
		MilgromAlert(@"Sorry",@"can't record while a track is being played");
		return;
	}
	
	if (recordButton.selected) {
		[self stop:nil];
	}
	else {
		OFSAptr->setSongState(SONG_TRIGGER_RECORD);
		
	}
}

- (void) fadeOutRecordButton {
	if (OFSAptr->getSongState() == SONG_RECORD) {
		//[UIView animateWithDuration:0.2 animations:^{recordButton.alpha = 0.0;} completion:^(BOOL finished){ [self fadeInRecordButton]; }];
		[UIView animateWithDuration:0.1 delay:0.5 
							options: UIViewAnimationOptionTransitionNone | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction// UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse |
						 animations:^{recordButton.imageView.alpha = 0.0;} 
						 completion:^(BOOL finished){ [self fadeInRecordButton]; }];
		
		
	} else {
		bAnimatingRecord = NO;
	}

	
}

- (void) fadeInRecordButton {
	if (OFSAptr->getSongState() != SONG_RECORD) {
		recordButton.imageView.alpha = 1.0;
		bAnimatingRecord = NO;
	} else {
		[UIView animateWithDuration:0.1 delay:0.5 
						options: UIViewAnimationOptionTransitionNone | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction// UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse |
					 animations:^{recordButton.imageView.alpha = 1.0;} 
					 completion:^(BOOL finished){ [self fadeOutRecordButton]; }];
	}
}

- (void) save:(id)sender {
	
	[(MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate] save];
	
}



- (void) nextLoop:(id)sender {
	
	UIButton *button = (UIButton*)sender;
	for (int i=0;i<[loopsImagesView.subviews count];i++) {
		UIImageView *imageView = (UIImageView*)[loopsImagesView.subviews objectAtIndex:i];
		if (imageView.tag == button.tag) {
			imageView.hidden = YES; // this flag will allow updateView to animate the loop image in band mode
			break;
		}
	}
	
	OFSAptr->nextLoop(button.tag);
	
}

- (void) prevLoop:(id)sender {
	
	UIButton *button = (UIButton*)sender;
	for (int i=0;i<[loopsImagesView.subviews count];i++) {
		UIImageView *imageView = (UIImageView*)[loopsImagesView.subviews objectAtIndex:i];
		if (imageView.tag == button.tag) {
			imageView.hidden = YES; // this flag will allow updateView to animate the loop image in band mode
			break;
		}
	}
	OFSAptr->prevLoop(button.tag);
}

- (void) closeTutorial:(id)sender {
	
}

- (void) showHelp:(id)sender {
	
	bShowHelp = YES;
	[self updateViews];
	
	
}


- (void)hideHelp {
	
	bShowHelp = NO;
	[self updateViews];
}

- (void) moreHelp:(id)sender {
	[self hideHelp];
	[((MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate]) helpWithTransition:UIModalTransitionStyleCoverVertical];
}

- (void) replayTutorial:(id)sender {
	[self hideHelp];
	MilgromInterfaceAppDelegate * appDelegate = (MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	[appDelegate.slidesManager start];
	[self updateViews];
	[appDelegate.slidesManager updateViews];
	
	
	
}

- (void)dealloc {
    [super dealloc];
}






#pragma mark Share

- (void) setShareProgress:(float) progress {
	[shareProgressView setRect:CGRectMake(0, 1.0-progress, 1.0f,progress)];
}

- (void)share:(id)sender {
	[(MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate] share];	
}

- (void)applicationDidEnterBackground {
	
	
	//[tutorialView removeViews];
}
				   

@end
