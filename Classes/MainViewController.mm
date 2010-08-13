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

@implementation MainViewController

@synthesize playButton;
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
		
	/*
	self.actionToolBar.hidden = true;
	
	menuController.view.hidden = true;
	menuController.view.alpha = 0.5;
	menuController.view.backgroundColor = [UIColor blackColor];
	[self.view addSubview:[menuController view]];
	 */
	
	saveButton.enabled = NO;
	//recordButton.enabled = NO;
	//topMenu.hidden = YES;
	
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
	 
	
	bMenuMode = NO;
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
	
	
	
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
	//!bMenuMode
	return YES;	
}




- (void)hide {
	triggersView.hidden = YES;
	loopsView.hidden = YES;
	bandLoopsView.hidden = YES;
	menuButton.hidden = YES;
	setMenuButton.hidden = YES;
}



- (void)show {
	switch (OFSAptr->getState()) {
		case SOLO_STATE:
			setMenuButton.hidden = NO;
			switch (OFSAptr->getMode(0)) {
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
			break;
		case BAND_STATE:
			bandLoopsView.hidden = NO;
			menuButton.hidden = NO;
			break;
		default:
			break;
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





- (void) bringMenu:(id)sender {
	
	bMenuMode = YES;
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
	if (recordButton.selected) 
		return;
	
	
		
	if (playButton.selected) {
		OFSAptr->stopSong();
		recordButton.enabled = YES;
	}
	else {
		OFSAptr->playSong();
		recordButton.enabled = NO;
	}
	
	playButton.selected = !playButton.selected;
	
}

- (void) record:(id)sender {
	if (playButton.selected) 
		return;
	
	
	
	if (recordButton.selected) {
		OFSAptr->stopSong();
		playButton.enabled = YES;
		saveButton.enabled = YES;
	}
	else {
		OFSAptr->recordSong();
		playButton.enabled = NO;
	}
	
	recordButton.selected = !recordButton.selected;
}

- (void) save:(id)sender {
	OFSAptr->saveSong("hello");
}


- (void) checkState:(id)sender {
	
	if (OFSAptr->isInTransition()) {
		if (playButton.enabled)
			playButton.enabled = NO;
		
		if (recordButton.enabled)
			recordButton.enabled = NO;
		
		if (menuButton.enabled) 
			menuButton.enabled = NO;
		
		if (saveButton.enabled) 
			saveButton.enabled = NO;
			
			
	} else {
		
		if (!playButton.enabled)
			playButton.enabled = YES;
		
		if (!menuButton.enabled) 
			menuButton.enabled = YES;
		
		if (playButton.selected != OFSAptr->getIsSongPlaying()) 
			playButton.selected = OFSAptr->getIsSongPlaying();
		
		if (!OFSAptr->getIsSongPlaying() && !recordButton.enabled ) {
			recordButton.enabled = YES;
		}
	}
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
	UIButton *button = (UIButton*)sender;
	OFSAptr->buttonPressed(button.tag);
	
//	if (button.tag == 7) {
//		triggersView.hidden = NO;
//		loopsView.hidden = YES;
//	}
	
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


@end
