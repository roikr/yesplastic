//
//  MainViewController.mm
//  YesPlastic
//
//  Created by Roee Kremer on 2/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"


#include "Constants.h"
#include "testApp.h"

#import "MilgromInterfaceAppDelegate.h"
#include "PlayerMenu.h"
#import "EAGLView.h"
#import "TouchView.h"
#import "TutorialView.h"
#import "MilgromMacros.h"
#import "SaveViewController.h"
#import "Song.h"
#import "CustomImageView.h"
#import "ShareManager.h"


#import "MilgromUtils.h"
#import "HelpViewController.h"
#import "ShareViewController.h"



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
@synthesize setMenuButton;
@synthesize saveButton;
@synthesize shareButton;
@synthesize infoButton;
@synthesize triggersView;
@synthesize loopsView;
@synthesize bandLoopsView;
@synthesize loopsImagesView;

@synthesize bandHelp;
@synthesize soloHelp;
@synthesize bShowHelp;

@synthesize playerControllers;

@synthesize interactionView;
@synthesize tutorialView;



//@synthesize triggerButton;
//@synthesize loopButton;
@synthesize saveViewController;
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
	
	[(TouchView*)self.view  setViewController:self];
	bShowHelp = NO;
	bInteractiveHelp = NO;
	bAnimatingRecord = NO;
	
	self.shareProgressView.image =  [UIImage imageNamed:@"SHARE_B.png"];
	
	
	
	//[self.view addSubview:menuController.view];
	//menuController.view.hidden = YES;
	
	/*
	for (unsigned i = 0; i < 3; i++) {
		PlayerMenu *controller = [playerControllers objectAtIndex:i];
		[self.view addSubview:controller.view];
		controller.view.hidden = YES;
	} 
	 */
	 
	
	
	for (int i=0; i<8; i++) {
		//[[NSBundle mainBundle] loadNibNamed:@"LoopButton" owner:self options:nil];
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		[button addTarget:self action:@selector(loop:) forControlEvents:UIControlEventTouchDown];
		//self.loopButton = nil;
		[loopsView addSubview:button];
		
		//CGRect frame = button.frame;
		CGRect frame;
		frame.origin.x = (i % 4)*80+5;
		frame.origin.y = (int)(i/4) * 60;
		frame.size.width = 70;
		frame.size.height = 60;
		button.frame = frame;
		button.tag = i;
	}
	
	for (int i=0; i<8; i++) {
		//[[NSBundle mainBundle] loadNibNamed:@"TriggerButton" owner:self options:nil];
		//UIButton *button = triggerButton;
		//self.triggerButton = nil;
		
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		[button addTarget:self action:@selector(trigger:) forControlEvents:UIControlEventTouchDown];
		//[button addTarget:self action:@selector(triggerTest:) forControlEvents:UIControlEventTouchDragInside];
		[triggersView addSubview:button];
		
		//CGRect frame = button.frame;
		CGRect frame;
		frame.origin.x = (i % 4)*80+5;
		frame.origin.y = (int)(i/4) * 60;
		frame.size.width = 70;
		frame.size.height = 60;
		button.frame = frame;
		button.tag = i;
		//button.hidden = YES;
		//button.userInteractionEnabled = NO;
		//button.multipleTouchEnabled = YES;
	}
	
	for (int i=0;i<[loopsImagesView.subviews count];i++) {
		UIImageView *imageView = (UIImageView*)[loopsImagesView.subviews objectAtIndex:i];
		imageView.hidden = YES;
	}
	
	
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		while (1) {
			OFSAptr->update(); // also update bNeedDisplay
			[tutorialView update];
			if (OFSAptr->bNeedDisplay) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[self updateViews];
					
				});
				OFSAptr->bNeedDisplay = false; // this should stay out off the main view async call
			}
			
		}
	});
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return interfaceOrientation == UIInterfaceOrientationLandscapeRight || interfaceOrientation==UIInterfaceOrientationLandscapeLeft;
}


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



- (void)updateViews {
	
	if (self.navigationController.topViewController != self) {
		return;
	}
	
	stateButton.hidden = YES;
	playButton.hidden = YES;
	recordButton.hidden = YES;
	stopButton.hidden = YES;
	menuButton.hidden = YES;
	setMenuButton.hidden = YES;
	saveButton.hidden = YES;
	loopsView.hidden = YES;
	triggersView.hidden = YES;
	bandLoopsView.hidden = YES;
	loopsImagesView.hidden = YES;
	recordButton.selected = OFSAptr->getSongState() == SONG_TRIGGER_RECORD || OFSAptr->getSongState() == SONG_RECORD;
	shareButton.hidden = YES;
	infoButton.hidden = YES;
	shareProgressView.hidden = YES;	
	//[self updateHelp];
	
	[tutorialView updateViews];
	
	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	BOOL isBandState = !stateButton.selected;
	
	self.interactionView.userInteractionEnabled = !bShowHelp;
	if (bShowHelp) {
		if (isBandState) {
			if (![self.view.subviews containsObject:bandHelp]) {
				[self.view addSubview:bandHelp];
				//[self.view bringSubviewToFront:bandHelp];
			}
		} else {
			if (![self.view.subviews containsObject:soloHelp]) {
				[self.view addSubview:soloHelp];
			}
		}
	} else {
		if ([self.view.subviews containsObject:soloHelp]) {
			[soloHelp removeFromSuperview];
		}
		if ([self.view.subviews containsObject:bandHelp]) {
			[bandHelp removeFromSuperview];
		}
	}

	
	
	
	
	if (![[appDelegate shareManager] isUploading]) {
		[self setShareProgress:1.0f];
	}
	
	
	

	
		
	if (!OFSAptr->isInTransition()  ) {
		switch (OFSAptr->getSongState()) {
			case SONG_IDLE:
			case SONG_RECORD:
			case SONG_TRIGGER_RECORD:
				
				playButton.hidden = tutorialView.isTutorialActive && tutorialView.currentTutorialSlide < MILGROM_TUTORIAL_RECORD_PLAY;
				
				if (isBandState) {
					menuButton.hidden = OFSAptr->getSongState() != SONG_IDLE || tutorialView.isTutorialActive && tutorialView.currentTutorialSlide < MILGROM_TUTORIAL_RECORD_PLAY;
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
				} else {
					setMenuButton.hidden = OFSAptr->getSongState() != SONG_IDLE || tutorialView.isTutorialActive;//  && tutorialView.currentTutorialSlide < MILGROM_TUTORIAL_RECORD_PLAY;
					NSString *setButton = [NSString stringWithFormat:@"%@_SET_B.png",[NSString stringWithCString:OFSAptr->getPlayerName(OFSAptr->controller).c_str() encoding:NSASCIIStringEncoding]];
					[setMenuButton setImage:[UIImage imageNamed:setButton] forState:UIControlStateNormal];
					
					switch (OFSAptr->getMode(OFSAptr->controller)) {
						case LOOP_MODE: {
							loopsView.hidden = NO;
							NSString *selected = [NSString stringWithFormat:@"%@_LOOP_P.png",[NSString stringWithCString:OFSAptr->getPlayerName(OFSAptr->controller).c_str() encoding:NSASCIIStringEncoding]];
							
							UIButton *button;
							for (int i=0; i<[loopsView.subviews count]; i++) {
								button = (UIButton*)[loopsView.subviews objectAtIndex:i];
								
								NSString *normal = [NSString stringWithFormat:@"%@_LOOP_%i.png",[NSString stringWithCString:OFSAptr->getPlayerName(OFSAptr->controller).c_str() encoding:NSASCIIStringEncoding],i+1];
								[button setImage:[UIImage imageNamed:normal] forState:UIControlStateNormal];
								[button setImage:[UIImage imageNamed:selected] forState:UIControlStateSelected];
								
								button.selected = button.tag == OFSAptr->getCurrentLoop(OFSAptr->controller);
							}
							
						} break;
						case MANUAL_MODE: {
							triggersView.hidden = NO;
							
							UIButton *button;
							for (int i=0; i<[triggersView.subviews count]; i++) {
								button = (UIButton*)[triggersView.subviews objectAtIndex:i];
								
								NSString *normal = [NSString stringWithFormat:@"%@_TB_%i.png",[NSString stringWithCString:OFSAptr->getPlayerName(OFSAptr->controller).c_str() encoding:NSASCIIStringEncoding],i+1];
								[button setImage:[UIImage imageNamed:normal] forState:UIControlStateNormal];
								NSString *highlighted = [NSString stringWithFormat:@"%@_TB_%i_P.png",[NSString stringWithCString:OFSAptr->getPlayerName(OFSAptr->controller).c_str() encoding:NSASCIIStringEncoding],i+1];
								[button setImage:[UIImage imageNamed:highlighted] forState:UIControlStateHighlighted];
								
							}
						} break;
						default:
							break;
					}
				}

				
				
								
				break;	
				
			case SONG_PLAY:
				
				stopButton.hidden = NO;
				
			default:
				break;
		
		}
		
		
		
		
		
		saveButton.hidden = OFSAptr->getSongVersion() == appDelegate.lastSavedVersion;
		
		if (isBandState) {
			
			BOOL shareEnabled =  [appDelegate.currentSong.bDemo boolValue] ? OFSAptr->getSongVersion() != appDelegate.lastSavedVersion : 
			OFSAptr->getSongVersion();  //  not a demo
			BOOL isUploading = [appDelegate.shareManager isUploading];
			
			shareButton.userInteractionEnabled = shareEnabled || isUploading; // && !isUploading - to disable when uploading
			shareButton.hidden = shareProgressView.hidden = !isUploading && !shareEnabled;
			
		}
		
		
		stateButton.hidden = tutorialView.isTutorialActive && !tutorialView.isTutorialRotateble;
		recordButton.hidden = tutorialView.isTutorialActive && tutorialView.currentTutorialSlide < MILGROM_TUTORIAL_RECORD_PLAY;
		infoButton.hidden = tutorialView.isTutorialActive && tutorialView.currentTutorialSlide < MILGROM_TUTORIAL_RECORD_PLAY; // OFSAptr->getSongState() != SONG_IDLE;
		
		if (!bAnimatingRecord && OFSAptr->getSongState() == SONG_RECORD) {
			bAnimatingRecord = YES;
			[self fadeOutRecordButton];
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



- (void) toggle:(id)sender {
	
	[tutorialView doneSlide:MILGROM_TUTORIAL_ROTATE];
	
	stateButton.selected = !stateButton.selected;
	
	
	triggersView.hidden = YES;
	loopsView.hidden = YES;
	bandLoopsView.hidden = YES;
	loopsImagesView.hidden = YES;
	menuButton.hidden = YES;
	setMenuButton.hidden = YES;
	stateButton.hidden = YES;
	[tutorialView removeViews];
	[tutorialView willRotate]; // to reset slides
	
	
	if ([self.view.subviews containsObject:bandHelp]) {
		[bandHelp removeFromSuperview];
	}
	if ([self.view.subviews containsObject:soloHelp]) {
		[soloHelp removeFromSuperview];
	}
	
	//[super rotateToInterfaceOrientation:toInterfaceOrientation duration:duration ];

	
	UIInterfaceOrientation orientation = stateButton.selected ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeRight;
	
	[self rotateToInterfaceOrientation:orientation duration:0.3 completion: ^{ [self updateViews]; }];

}


- (void) menu:(id)sender {
	
	
	
	if (OFSAptr->getSongState()==SONG_RECORD ) {
		OFSAptr->setSongState(SONG_IDLE);
	}
	
	if (sender == setMenuButton) {
		
		if (self.playerControllers == nil) { // this check use in case of loading after warning message...
			NSMutableArray *controllers = [[NSMutableArray alloc] init];
			for (unsigned i = 0; i < 3; i++) {
				PlayerMenu *controller = [[PlayerMenu alloc] initWithNibName:@"PlayerMenu" bundle:nil];
				controller.playerName = [NSString stringWithCString:OFSAptr->getPlayerName(i).c_str() encoding:NSASCIIStringEncoding];
				
				//PlayerViewContorller *controller = [[PlayerViewContorller alloc] init];
				//controller.mainController = self;
				[controllers addObject:controller];
				[controller release];
			}
			self.playerControllers = [NSArray arrayWithArray:controllers];
			[controllers release];
		}
		
		
		PlayerMenu *controller = [playerControllers objectAtIndex:OFSAptr->controller];
		
		[((MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate]).navigationController presentModalViewController:controller animated:YES];
		
		
		
	}
	
	if (sender == menuButton) {
		[tutorialView doneSlide:MILGROM_SLIDE_MENU];
		OFSAptr->stopLoops();
		[self.navigationController popViewControllerAnimated:YES]; 
		
	}
	
	
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
	
	OFSAptr->setSongState(SONG_IDLE);
	
	
	if (self.saveViewController == nil) {
		self.saveViewController = [[SaveViewController alloc] initWithNibName:@"SaveViewController" bundle:nil];
		//saveViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	}
	
	[((MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate]).navigationController presentModalViewController:self.saveViewController animated:YES];
	
}



	




		
/*
- (void) updateTables {
	//[menuController.tableView reloadData]; // TODO:  what is this ? uncomment !
	
	for (unsigned i = 0; i < 3; i++) {
		PlayerMenu *controller = [PlayerMenu objectAtIndex:i];
		[controller.tableView reloadData];
	}
	
}
*/

- (void) trigger:(id)sender {
	
	UIButton *button = (UIButton*)sender;
	OFSAptr->buttonPressed(button.tag);
	
	
	
//	if (button.tag == 7) {
//		triggersView.hidden = YES;
//		loopsView.hidden = NO;
//	}
		
}


//- (void) triggerTest:(id)sender {
//	NSLog(@"triggerTest: %i",((UIButton*)sender).tag);
//}


- (void) loop:(id)sender {
	UIButton *button;
//	for (int i=0; i<[loopsView.subviews count]; i++) {
//		button = (UIButton*)[loopsView.subviews objectAtIndex:i];
//		button.selected = NO;
//	}
	button = (UIButton*)sender;
	OFSAptr->buttonPressed(button.tag);
	
//	if (button.tag == 7) {
//		triggersView.hidden = NO;
//		loopsView.hidden = YES;
//	}
	
}

//- (void)updateLoops:(id)sender {
//	UIButton *button = (UIButton*)sender;
//	
//	button.selected = YES;
//}

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
	
	HelpViewController *helpView = [[HelpViewController alloc] initWithNibName:@"HelpViewController" bundle:nil];
	helpView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		
	[((MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate]).navigationController presentModalViewController:helpView animated:YES];
}

- (void) replayTutorial:(id)sender {
	[self hideHelp];
	[self.tutorialView test];
}

- (void)dealloc {
	[saveViewController release];
    [super dealloc];
}






- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	MilgromLog(@"MainViewController::viewWillAppear");
	MilgromInterfaceAppDelegate * appDelegate = (MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate.eAGLView startAnimation];
	appDelegate.eAGLView.hidden = NO;
	
	UIInterfaceOrientation orientation = stateButton.selected ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeRight;
	
	[self rotateToInterfaceOrientation:orientation duration:0 completion: NULL];
	
	
	//self.view.userInteractionEnabled = YES; // was disabled after video export
	
	[tutorialView start];
	
	[self updateViews];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	MilgromLog(@"MainViewController::viewDidAppear");
    [self becomeFirstResponder]; // ROIKR: why is that ?
	
	self.view.hidden = NO;
}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	MilgromLog(@"MainViewController::viewWillDisappear");
	self.view.hidden = YES;
	
}


- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	MilgromLog(@"MainViewController::viewDidDisappear");	
}

- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	MilgromLog(@"shake began");
	shakeStartTime = [NSDate timeIntervalSinceReferenceDate];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
	NSTimeInterval diff = [NSDate timeIntervalSinceReferenceDate]-shakeStartTime;
	MilgromLog(@"shake ended: %2.2f",diff);
	if ( !tutorialView.isTutorialActive && diff > 0.1 && diff < 1.0 && (OFSAptr->getSongState()==SONG_IDLE || OFSAptr->getSongState()==SONG_RECORD || OFSAptr->getSongState()==SONG_TRIGGER_RECORD)) {
		OFSAptr->playRandomLoop();
	}
}

#pragma mark Share

- (void) setShareProgress:(float) progress {
	[shareProgressView setRect:CGRectMake(0, 1.0-progress, 1.0f,progress)];
}

- (void)share:(id)sender {
	
	[tutorialView doneSlide:MILGROM_SLIDE_SHARE];
	ShareManager *shareManager = [(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] shareManager];
	//self.view.userInteractionEnabled = NO; // disabled to avoid loop activation

	if ([shareManager isUploading]) {
		MilgromAlert(@"Uploading", @"wait a second, your video upload is in progress");
	} else {
		
		//[[(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] shareManager] prepare];
		OFSAptr->setSongState(SONG_IDLE);
		
		ShareViewController *share = [[ShareViewController alloc] initWithNibName:@"ShareViewController" bundle:nil];
		share.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		
		[((MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate]).navigationController presentModalViewController:share animated:YES];
		//[self updateViews];
		//[shareManager menuWithView:self.view];
	}
	// BUG FIX: this is very important: don't present from milgromViewController as it will result in crash when returning to BandView after share
	
}





- (void)applicationDidEnterBackground {
	
	
	[tutorialView removeViews];
}
				   

@end
