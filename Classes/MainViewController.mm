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
#include "PlayerMenu.h"

#import "MilgromInterfaceAppDelegate.h"
#import "TouchView.h"
#import "MilgromMacros.h"
#import "CustomFontTextField.h"
#import "MilgromViewController.h"
//#import "SongViewController.h"



@implementation MainViewController

@synthesize playButton;
@synthesize stopButton;
@synthesize recordButton;
@synthesize menuButton;
@synthesize setMenuButton;
@synthesize saveButton;
@synthesize triggersView;
@synthesize loopsView;
@synthesize bandLoopsView;

@synthesize playerControllers;

@synthesize triggerButton;
@synthesize loopButton;

@synthesize songName;


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
	 
	//TODO: replace with NULL as done in the page controll example
	
	if (self.playerControllers == nil) { // this check use in case of loading after warning message...
		NSMutableArray *controllers = [[NSMutableArray alloc] init];
		for (unsigned i = 0; i < 3; i++) {
			PlayerMenu *controller = [[PlayerMenu alloc] initWithNibName:@"PlayerMenu" bundle:nil];
			//PlayerViewContorller *controller = [[PlayerViewContorller alloc] init];
			//controller.mainController = self;
			[controllers addObject:controller];
			[controller release];
		}
		self.playerControllers = [NSArray arrayWithArray:controllers];
		[controllers release];
	}
	 
	
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
		[[NSBundle mainBundle] loadNibNamed:@"LoopButton" owner:self options:nil];
		UIButton *button = loopButton;
		self.loopButton = nil;
		[loopsView addSubview:button];
		
		CGRect frame = button.frame;
		frame.origin.x = (i % 4)*80+5;
		frame.origin.y = (int)(i/4) * 60;
		button.frame = frame;
		button.tag = i;
	}
	
	for (int i=0; i<8; i++) {
		[[NSBundle mainBundle] loadNibNamed:@"TriggerButton" owner:self options:nil];
		UIButton *button = triggerButton;
		self.triggerButton = nil;
		[triggersView addSubview:button];
		
		CGRect frame = button.frame;
		frame.origin.x = (i % 4)*80+5;
		frame.origin.y = (int)(i/4) * 60;
		button.frame = frame;
		button.tag = i;
	}
	
	saveButton.hidden = NO; // TODO: move this
	
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
	//!bMenuMode
	return YES;	
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	switch (toInterfaceOrientation) {
		case UIInterfaceOrientationPortrait:
		case UIInterfaceOrientationPortraitUpsideDown:
			
			OFSAptr->setState(SOLO_STATE);
			break;
		case UIInterfaceOrientationLandscapeRight:
		case UIInterfaceOrientationLandscapeLeft:
			OFSAptr->setState(BAND_STATE);
			break;
		default:
			break;
	}
	
	triggersView.hidden = YES;
	loopsView.hidden = YES;
	bandLoopsView.hidden = YES;
	menuButton.hidden = YES;
	setMenuButton.hidden = YES;
	
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	
	switch (OFSAptr->getState()) {
		case SOLO_STATE:
			setMenuButton.hidden = NO;
			switch (OFSAptr->getMode(OFSAptr->controller)) {
				case LOOP_MODE:
					loopsView.hidden = NO;
					break;
				case MANUAL_MODE:
					triggersView.hidden = NO;
					break;
				default:
					break;
			}
			break;
		case BAND_STATE:
			bandLoopsView.hidden = NO;
			menuButton.hidden = NO;
			break;
		default:
			break;
	}
}



- (void)updateViews {
	if (self.navigationController.topViewController != self) {
		return;
	}
	
	
	
	if (bModeChanged) {
		switch (OFSAptr->getMode(OFSAptr->controller)) {
			case LOOP_MODE:
				loopsView.hidden = NO;
				triggersView.hidden = YES;
				break;
			case MANUAL_MODE:
				loopsView.hidden = YES;
				triggersView.hidden = NO;
				break;
			default:
				break;
		}
		
		bModeChanged = false;
	}
	
	if (OFSAptr->isInTransition()!=bInTransition) {
		if (OFSAptr->isInTransition()) {
			
			playButton.hidden = YES;
			recordButton.hidden = YES;
			stopButton.hidden = YES;
			menuButton.hidden = YES;
			setMenuButton.hidden = YES;
			saveButton.hidden = YES;
			
			
			
			
		} else {
			
			playButton.hidden = NO;
			recordButton.hidden = NO;
			menuButton.hidden = OFSAptr->getState() == SOLO_STATE;
			setMenuButton.hidden = OFSAptr->getState() == BAND_STATE;
			
			
			
			
		}
		bInTransition = OFSAptr->isInTransition();
	}
	
	if (songState != OFSAptr->getSongState()) {
		switch (OFSAptr->getSongState()) {
			case SONG_IDLE:
				stopButton.hidden = YES;
				playButton.hidden = NO;
				recordButton.selected = NO;
				if (OFSAptr->getState() == SOLO_STATE) {
					setMenuButton.hidden = NO;

				}
				break;
			case SONG_PLAY:
				setMenuButton.hidden = YES;
				stopButton.hidden = NO;
				playButton.hidden = YES;
				recordButton.selected = NO;
				break;
			case SONG_RECORD:
				setMenuButton.hidden = YES;
				stopButton.hidden = YES;
				playButton.hidden = NO;
				break;

			default:
				break;
		}
		songState = OFSAptr->getSongState();
	
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



- (void)interrupt {
	if (OFSAptr->getSongState() != SONG_IDLE) {
		OFSAptr->setSongState(SONG_IDLE);
		playButton.hidden = NO;
		recordButton.hidden = NO;
		stopButton.hidden = YES;
		if (OFSAptr->getState() == SOLO_STATE) {
			setMenuButton.hidden = NO;
		}
		
	}
	
}

- (void) menu:(id)sender {
	[self interrupt];
	
			 
	
	switch (OFSAptr->getState()) {
		case SOLO_STATE: {
			//topMenu.hidden = YES;
			PlayerMenu *controller = [playerControllers objectAtIndex:OFSAptr->controller];
			
			//[controller show];
			[self.navigationController pushViewController:controller animated:YES];
			//[self presentModalViewController:controller animated:YES];
			//controller.view.hidden = NO;
			OFSAptr->bMenu=true; // TODO: change upon return
		} break;
			
		case BAND_STATE: {
			[self.navigationController popViewControllerAnimated:YES];
			//[self presentModalViewController:menuController animated:YES];
			//menuController.view.hidden = NO;
		} break;

		default:
			break;
	}
	
}



- (void) play:(id)sender {
	
	if (recordButton.selected) {
		[self stop:nil];
	}
			
	OFSAptr->setSongState(SONG_PLAY);
	
	
	
	
}

- (void) stop:(id)sender {
	OFSAptr->setSongState(SONG_IDLE);
}

- (void) record:(id)sender {
	if (playButton.hidden) 
		return;
	
	
	
	if (recordButton.selected) {
		[self stop:nil];
		
	}
	else {
		OFSAptr->setSongState(SONG_RECORD);
		saveButton.hidden = NO;
	}
	
	recordButton.selected = !recordButton.selected;
}

- (void) save:(id)sender {
	[self interrupt];
	
	songName.hidden = NO;
	[songName becomeFirstResponder];
	
//	if (self.songViewController == nil) {
//		self.songViewController = [[SongViewController alloc] initWithNibName:@"SongViewController" bundle:nil];
//		songViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//	}
//	
//	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
//	[appDelegate.milgromViewController presentModalViewController:self.songViewController animated:YES];
	
}



	
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	songName.hidden = YES;
	saveButton.hidden = YES;
	
	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate saveSong:songName.text];
	
	
	return NO;
}



- (void)render:(id)sender {
	[self interrupt];
	
	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.milgromViewController renderAnimation];
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

- (void) loop:(id)sender {
	UIButton *button;
	for (int i=0; i<[loopsView.subviews count]; i++) {
		button = (UIButton*)[loopsView.subviews objectAtIndex:i];
		button.selected = NO;
	}
	button = (UIButton*)sender;
	OFSAptr->buttonPressed(button.tag);
	
//	if (button.tag == 7) {
//		triggersView.hidden = NO;
//		loopsView.hidden = YES;
//	}
	
}

- (void)updateLoops:(id)sender {
	UIButton *button = (UIButton*)sender;
	
	button.selected = YES;
}

- (void) nextLoop:(id)sender {
	UIButton *button = (UIButton*)sender;
	OFSAptr->nextLoop(button.tag);
	
}

- (void) prevLoop:(id)sender {
	UIButton *button = (UIButton*)sender;
	OFSAptr->prevLoop(button.tag);
}





- (void)dealloc {
	//TODO: release player controllers
	
    [super dealloc];
}




- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	MilgromLog(@"MainViewController::viewDidAppear");
    [self becomeFirstResponder];
	
	songState = OFSAptr->getSongState();
	bModeChanged = true;
	bInTransition = OFSAptr->isInTransition();
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	MilgromLog(@"MainViewController::viewWillAppear");
}



- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
	MilgromLog(@"shake ended");
	OFSAptr->playRandomLoop();
}


@end
