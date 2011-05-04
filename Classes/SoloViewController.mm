//
//  SoloViewController.mm
//  YesPlastic
//
//  Created by Roee Kremer on 5/01/11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SoloViewController.h"
#import "MainViewController.h"
#import "SaveViewController.h"

#include "Constants.h"
#include "testApp.h"

#import "MilgromInterfaceAppDelegate.h"
#include "PlayerMenu.h"
#import "TouchView.h"
#import "MilgromMacros.h"
#import "Song.h"
#import "CustomImageView.h"
#import "ShareManager.h"
#import "SlidesManager.h"
#import "MilgromUtils.h"

#ifdef _FLURRY
#import "FlurryAPI.h"
#endif


//#import "Trigger.h"

@interface SoloViewController() 

- (void) fadeOutRecordButton;
- (void) fadeInRecordButton;
@end

@implementation SoloViewController

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

@synthesize soloHelp;
@synthesize bShowHelp;

@synthesize playerControllers;

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
	
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return interfaceOrientation == UIInterfaceOrientationPortrait ;
}



- (void)updateViews {
	
		
	stateButton.hidden = YES;
	playButton.hidden = YES;
	recordButton.hidden = YES;
	stopButton.hidden = YES;
	menuButton.hidden = YES;
	setMenuButton.hidden = YES;
	saveButton.hidden = YES;
	loopsView.hidden = YES;
	triggersView.hidden = YES;
	recordButton.selected = OFSAptr->getSongState() == SONG_TRIGGER_RECORD || OFSAptr->getSongState() == SONG_RECORD;
	shareButton.hidden = YES;
	infoButton.hidden = YES;
	shareProgressView.hidden = YES;	
	//[self updateHelp];
	
	
	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	
	self.interactionView.userInteractionEnabled = !bShowHelp;
	if (bShowHelp) {
		if (![self.view.subviews containsObject:soloHelp]) {
			[self.view addSubview:soloHelp];
		}
	} else {
		if ([self.view.subviews containsObject:soloHelp]) {
			[soloHelp removeFromSuperview];
		}
	}
	
	
	if (![[appDelegate shareManager] isUploading]) {
		[self setShareProgress:1.0f];
	}
	
			
	if (!OFSAptr->isInTransition()  ) {
		switch (OFSAptr->getSongState()) {
			case SONG_IDLE:
			case SONG_RECORD:
			case SONG_TRIGGER_RECORD: {
				
				playButton.hidden = appDelegate.slidesManager.currentTutorialSlide < MILGROM_TUTORIAL_RECORD_PLAY;
				
				setMenuButton.hidden = OFSAptr->getSongState() != SONG_IDLE || appDelegate.slidesManager.currentTutorialSlide < MILGROM_TUTORIAL_SOLO_MENU;
				
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
								
			} break;	
				
			case SONG_PLAY:
				
				stopButton.hidden = NO;
				
			default:
				break;
		
		}
		
		
		
		saveButton.hidden = OFSAptr->getSongVersion() == appDelegate.lastSavedVersion || appDelegate.slidesManager.currentTutorialSlide < MILGROM_TUTORIAL_SHARE;
		
		BOOL shareEnabled =  [appDelegate.currentSong.bDemo boolValue] ? OFSAptr->getSongVersion() != appDelegate.lastSavedVersion : 
		OFSAptr->getSongVersion();  //  not a demo
		BOOL isUploading = [appDelegate.shareManager isUploading];
		
		shareButton.userInteractionEnabled = shareEnabled || isUploading; // && !isUploading - to disable when uploading
		shareButton.hidden = shareProgressView.hidden = (!isUploading && !shareEnabled) || appDelegate.slidesManager.currentTutorialSlide < MILGROM_TUTORIAL_SHARE;
		
		stateButton.hidden = appDelegate.slidesManager.currentTutorialSlide != MILGROM_TUTORIAL_ROTATE && appDelegate.slidesManager.currentTutorialSlide < MILGROM_TUTORIAL_RECORD_PLAY;
		recordButton.hidden =  appDelegate.slidesManager.currentTutorialSlide < MILGROM_TUTORIAL_RECORD_PLAY;
		infoButton.hidden = appDelegate.slidesManager.currentTutorialSlide < MILGROM_TUTORIAL_SHARE; // OFSAptr->getSongState() != SONG_IDLE;
		
		if (!bAnimatingRecord && OFSAptr->getSongState() == SONG_RECORD) {
			bAnimatingRecord = YES;
			[self fadeOutRecordButton];
		}
		
	}
	
	if (!appDelegate.slidesManager.currentView && appDelegate.slidesManager.targetView == self.view) {
		[appDelegate.slidesManager addViews];
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
	MilgromLog(@"SoloViewControlloer::viewWillAppear");
	
	MilgromInterfaceAppDelegate * appDelegate = (MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate.slidesManager setTargetView:self.view withSlides:self.slides];
	bShowHelp = NO;
	[self updateViews];
#ifdef _FLURRY
	[FlurryAPI logEvent:@"SOLO"];
#endif
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	MilgromLog(@"SoloViewControlloer::viewDidAppear");
    [self.view becomeFirstResponder]; // this is for the shake detection
	
	self.view.hidden = NO;
}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	MilgromLog(@"SoloViewControlloer::viewWillDisappear");
	[self.view resignFirstResponder]; // this is for the shake detection
	self.view.hidden = YES;
	
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	MilgromLog(@"SoloViewControlloer::viewDidDisappear");	
}

#pragma mark Buttons

- (void) toggle:(id)sender {
	[(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] toggle:UIInterfaceOrientationLandscapeRight animated:YES];
}


- (void) menu:(id)sender {
	
	
	MilgromInterfaceAppDelegate *appDelegate =  (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if (OFSAptr->getSongState()==SONG_RECORD ) {
		OFSAptr->setSongState(SONG_IDLE);
	}
	
	
	
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
	// ((MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate])
	[self presentModalViewController:controller animated:YES];
	
	[appDelegate.slidesManager doneSlide:MILGROM_TUTORIAL_SOLO_MENU]; // to avoid slide in mainViewController
	
}



- (void) play:(id)sender {
	
	MilgromInterfaceAppDelegate *appDelegate =  (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.slidesManager doneSlide:MILGROM_TUTORIAL_RECORD_PLAY]; 
	
		
	if (recordButton.selected) {
		[self stop:nil];
	}
		
	if (OFSAptr->getSongVersion()) {
		OFSAptr->setSongState(SONG_PLAY);
#ifdef _FLURRY
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
	
	OFSAptr->setSongState(SONG_IDLE);
#ifdef _FLURRY
	[FlurryAPI logEvent:@"STOP"];
#endif
}

- (void) record:(id)sender {
	
	[((MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate]).slidesManager doneSlide:MILGROM_TUTORIAL_RECORD_PLAY]; 
	
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
	
#ifdef _FLURRY
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%u", button.tag],@"SAMPLE",
								[NSString stringWithCString:OFSAptr->getPlayerName(OFSAptr->controller).c_str() encoding:NSASCIIStringEncoding],@"PLAYER", nil];
	[FlurryAPI logEvent:@"TRIGGER" withParameters:dictionary];
#endif	
	
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
	
#ifdef _FLURRY
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%u", button.tag],@"SAMPLE",
								[NSString stringWithCString:OFSAptr->getPlayerName(OFSAptr->controller).c_str() encoding:NSASCIIStringEncoding],@"PLAYER", nil];
	[FlurryAPI logEvent:@"LOOP" withParameters:dictionary];
#endif
	
//	if (button.tag == 7) {
//		triggersView.hidden = NO;
//		loopsView.hidden = YES;
//	}
	
}


- (void) closeTutorial:(id)sender {
	
}

- (void) showHelp:(id)sender {
	
	
	bShowHelp = YES;
	[self updateViews];
#ifdef _FLURRY
	[FlurryAPI logEvent:@"SOLO_HELP"];
#endif	
	
}


- (void)hideHelp {
	
	bShowHelp = NO;
	[self updateViews];
}

- (void) replayTutorial:(id)sender {
	[self hideHelp];
	MilgromInterfaceAppDelegate * appDelegate = (MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate.slidesManager start];
	[appDelegate toggle:UIInterfaceOrientationLandscapeRight animated:YES];
#ifdef _FLURRY
	[FlurryAPI logEvent:@"REPLAY_TUTORIAL"];
#endif
}



- (void)dealloc {
    [super dealloc];
}


- (BOOL)canBecomeFirstResponder {
	return YES;
}


#pragma mark Share

- (void) setShareProgress:(float) progress {
	[shareProgressView setRect:CGRectMake(0, 1.0-progress, 1.0f,progress)];
}

- (void)share:(id)sender {
	[(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] shareWithin:self];	
}

				   

@end
