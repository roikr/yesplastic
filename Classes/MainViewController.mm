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

#ifdef _FLURRY
#import "FlurryAPI.h"
#endif


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
	
	
	bAnimatingRecord = NO;
	
	self.shareProgressView.image =  [UIImage imageNamed:@"SHARE_B.png"];
	
	for (int i=0;i<[loopsImagesView.subviews count];i++) {
		UIImageView *imageView = (UIImageView*)[loopsImagesView.subviews objectAtIndex:i];
		imageView.hidden = YES;
	}
	
	[(TouchView*)self.view resetCounters];
	for (int i=0; i<3; i++) {
		loopChanges[i] = 0;
	}
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return interfaceOrientation == UIInterfaceOrientationLandscapeRight ;
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
				
				
				menuButton.hidden = OFSAptr->getSongState() != SONG_IDLE || appDelegate.slidesManager.currentTutorialSlide < MILGROM_TUTORIAL_DONE;
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
		
		
		
		
		
		saveButton.hidden = OFSAptr->getSongVersion() == appDelegate.lastSavedVersion || appDelegate.slidesManager.currentTutorialSlide < MILGROM_TUTORIAL_DONE;
		
		BOOL shareEnabled =  [appDelegate.currentSong.bDemo boolValue] ? OFSAptr->getSongVersion() != appDelegate.lastSavedVersion : 
		OFSAptr->getSongVersion();  //  not a demo
		BOOL isUploading = [appDelegate.shareManager isUploading];
		
		shareButton.userInteractionEnabled = shareEnabled || isUploading; // && !isUploading - to disable when uploading
		shareButton.hidden = shareProgressView.hidden = NSClassFromString(@"AVAssetWriter")==nil || (!isUploading && !shareEnabled) || appDelegate.slidesManager.currentTutorialSlide < MILGROM_TUTORIAL_DONE;
		
		
		
		
		stateButton.hidden = appDelegate.slidesManager.currentTutorialSlide != MILGROM_TUTORIAL_ROTATE && appDelegate.slidesManager.currentTutorialSlide < MILGROM_TUTORIAL_RECORD_PLAY;
		recordButton.hidden =  appDelegate.slidesManager.currentTutorialSlide < MILGROM_TUTORIAL_RECORD_PLAY;
		infoButton.hidden = appDelegate.slidesManager.currentTutorialSlide < MILGROM_TUTORIAL_DONE; // OFSAptr->getSongState() != SONG_IDLE;
		
		if (!bAnimatingRecord && OFSAptr->getSongState() == SONG_RECORD) {
			bAnimatingRecord = YES;
			[self fadeOutRecordButton];
		}
		
	}
	
	if (!appDelegate.slidesManager.currentView && appDelegate.slidesManager.targetView == self.view) {
		switch (appDelegate.slidesManager.currentTutorialSlide) {
			case MILGROM_TUTORIAL_INTRODUCTION: {
			
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0e9 * 2.0)), dispatch_get_main_queue(),^{[appDelegate.slidesManager addViews];});
				
				//[NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)(2.0) target:appDelegate.slidesManager selector:@selector(addViews) userInfo:nil repeats:NO];
				
			}	break;
			case MILGROM_TUTORIAL_CHANGE_LOOP: 
				for (int i=0; i<3; i++) {
					if (OFSAptr->getMode(i) == LOOP_MODE) {
						[appDelegate.slidesManager addViews];
						break;
					}
				}
				break;
//			case MILGROM_TUTORIAL_SHARE:
//				if (self.shareButton.hidden==NO) {
//					[appDelegate.slidesManager addViews];
//				}
//				break;

			default:
				[appDelegate.slidesManager addViews];
				break;
		}
	}
	
//	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"replay_reminder"]) {
//		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"replay_reminder"];
//		[[NSUserDefaults standardUserDefaults] synchronize];
//		
//		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0e9 * 2.0)), dispatch_get_main_queue(),^{MilgromAlert(@"No worries", @"you can always replay tutorial from the ? slide");});
//		
//		
//		
//	} 
		
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
	bShowHelp = NO;
	
	[self updateViews];
#ifdef _FLURRY
	[FlurryAPI logEvent:@"MAIN"];
#endif
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
//	[appDelegate.slidesManager doneSlide:MILGROM_TUTORIAL_SHARE];
	[appDelegate toggle:UIInterfaceOrientationPortrait animated:YES];
}


- (void) menu:(id)sender {
	
//	[( (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate]).slidesManager doneSlide:MILGROM_TUTORIAL_SHARE];

	
	if (OFSAptr->getSongState()==SONG_RECORD ) {
		OFSAptr->setSongState(SONG_IDLE);
	}
	
	
	MilgromInterfaceAppDelegate * appDelegate = (MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	//[appDelegate.slidesManager doneSlide:MILGROM_TUTORIAL_MENU];
	OFSAptr->stopLoops();
	[appDelegate.navigationController popViewControllerAnimated:YES]; 
		
	
	
	
}



- (void) play:(id)sender {
//	[( (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate]).slidesManager doneSlide:MILGROM_TUTORIAL_SHARE];

	
		
	if (recordButton.selected) {
		[self stop:nil];
	}
		
	if (OFSAptr->getSongVersion()) {
		OFSAptr->setSongState(SONG_PLAY);
#ifdef _FLURRY
		
		MilgromInterfaceAppDelegate *appDelegate =  (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
		
				
		if ([appDelegate.currentSong.bDemo boolValue]) {
			NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:appDelegate.currentSong.songName,@"NAME", nil];
			[FlurryAPI logEvent:@"PLAY" withParameters:dictionary];
		} else {
			[FlurryAPI logEvent:@"PLAY_USER_SONG"];
		}
#endif
	} else {
		MilgromAlert(@"Can't  play", @"go record something first");
	}	
}

- (void) stop:(id)sender {
	
//	[( (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate]).slidesManager doneSlide:MILGROM_TUTORIAL_SHARE];

	
	OFSAptr->setSongState(SONG_IDLE);
#ifdef _FLURRY
	[FlurryAPI logEvent:@"STOP"];
#endif	
}

- (void) record:(id)sender {
//	[( (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate]).slidesManager doneSlide:MILGROM_TUTORIAL_SHARE];
	
	if (playButton.hidden) {
		MilgromAlert(@"Sorry",@"can't record while a track is being played");
		return;
	}
	
	if (recordButton.selected) {
		[self stop:nil];
	}
	else {
		OFSAptr->setSongState(SONG_TRIGGER_RECORD);
#ifdef _FLURRY
		[FlurryAPI logEvent:@"RECORD"];
#endif	
		
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
	
	[(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] saveWithin:self];
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
	loopChanges[button.tag]++;

	
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
	loopChanges[button.tag]++;
	
	
}


- (void) showHelp:(id)sender {
//	[( (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate]).slidesManager doneSlide:MILGROM_TUTORIAL_SHARE];

	bShowHelp = YES;
	[self updateViews];
#ifdef _FLURRY
	[FlurryAPI logEvent:@"BAND_HELP"];
#endif	
	
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
	
	if (OFSAptr->getSongState()!=SONG_IDLE ) {
		OFSAptr->setSongState(SONG_IDLE);
	}
	
	[self hideHelp];
	MilgromInterfaceAppDelegate * appDelegate = (MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	[appDelegate.slidesManager start];
	[self updateViews];
#ifdef _FLURRY
	[FlurryAPI logEvent:@"REPLAY_TUTORIAL"];
#endif	
	
}

- (void)dealloc {
    [super dealloc];
}




#pragma mark Share

- (void) setShareProgress:(float) progress {
	[shareProgressView setRect:CGRectMake(0, 1.0-progress, 1.0f,progress)];
}

- (void)share:(id)sender {

	[(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] shareWithin:self];	
}


#pragma mark Analytics

- (void) updateAnalytics {
	
	
#ifdef _FLURRY
	for (int i=0; i<3; i++) {
		NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithCString:((MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate]).OFSAptr->getPlayerName(i).c_str() encoding:NSASCIIStringEncoding],@"PLAYER", 
									@"MAIN",@"VIEW",
									nil];
		
		MilgromLog(@"view: %@, player: %@",[dictionary objectForKey:@"VIEW"],[dictionary objectForKey:@"PLAYER"]);
		
		for (int j=0; j<[(TouchView*)self.view getCounter:i]; j++) {
			[FlurryAPI logEvent:@"LOOP_TOGGLE" withParameters:dictionary];
		}
		MilgromLog(@"LOOP_TOGGLE: %i",[(TouchView*)self.view getCounter:i]);
		
		for (int j=0; j<loopChanges[i]; j++) {
			[FlurryAPI logEvent:@"LOOP_CHANGE" withParameters:dictionary];
		}
		
		
		MilgromLog(@"LOOP_CHANGE: %i",loopChanges[i]);
		
	}	
	
	
#endif
	
	
	[(TouchView*)self.view resetCounters];
	for (int i=0; i<3; i++) {
		loopChanges[i] = 0;
	}
}

@end
