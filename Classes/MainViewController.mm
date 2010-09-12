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
#import "TouchView.h"
#import "MilgromMacros.h"
#import "SaveViewController.h"



@implementation MainViewController

@synthesize playButton;
@synthesize stopButton;
@synthesize recordButton;
@synthesize menuButton;
@synthesize setMenuButton;
@synthesize saveButton;
@synthesize shareButton;
@synthesize triggersView;
@synthesize loopsView;
@synthesize bandLoopsView;


@synthesize triggerButton;
@synthesize loopButton;
@synthesize saveViewController;


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
	[self updateViews];
	
//	switch (OFSAptr->getState()) {
//		case SOLO_STATE:
//			setMenuButton.hidden = NO;
//			switch (OFSAptr->getMode(OFSAptr->controller)) {
//				case LOOP_MODE:
//					loopsView.hidden = NO;
//					break;
//				case MANUAL_MODE:
//					triggersView.hidden = NO;
//					break;
//				default:
//					break;
//			}
//			break;
//		case BAND_STATE:
//			bandLoopsView.hidden = NO;
//			menuButton.hidden = NO;
//			break;
//		default:
//			break;
//	}
}




- (void)updateViews {
	
	if (self.navigationController.topViewController != self) {
		return;
	}
	
	playButton.hidden = YES;
	recordButton.hidden = YES;
	stopButton.hidden = YES;
	menuButton.hidden = YES;
	setMenuButton.hidden = YES;
	saveButton.hidden = YES;
	loopsView.hidden = YES;
	triggersView.hidden = YES;
	bandLoopsView.hidden = YES;
	recordButton.selected = OFSAptr->getSongState() == SONG_RECORD;
	
	
	
	if (!OFSAptr->isInTransition()) {
		switch (OFSAptr->getSongState()) {
			case SONG_IDLE:
			case SONG_RECORD:
			case SONG_TRIGGER_RECORD:
				playButton.hidden = NO;
				
				
				switch (OFSAptr->getState()) {
					case SOLO_STATE:
						setMenuButton.hidden = NO;
						
						switch (OFSAptr->getMode(OFSAptr->controller)) {
							case LOOP_MODE:
								loopsView.hidden = NO;
								UIButton *button;
								for (int i=0; i<[loopsView.subviews count]; i++) {
									button = (UIButton*)[loopsView.subviews objectAtIndex:i];
									button.selected = button.tag == OFSAptr->getCurrentLoop(OFSAptr->controller);
								}
								
								break;
							case MANUAL_MODE:
								triggersView.hidden = NO;
								break;
							default:
								break;
						}
						
						break;
					case BAND_STATE:
						menuButton.hidden = NO;
						bandLoopsView.hidden = NO;
					default:
						break;
				}
				
				
								
								
				break;	
				
			case SONG_PLAY:
		
				stopButton.hidden = NO;
				
				break;
			
				
			default:
				break;
		
		}
		
		saveButton.hidden = !OFSAptr->bTempDoc;
		recordButton.hidden = NO;

		
			
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




- (void) menu:(id)sender {
	
	if (OFSAptr->getSongState()==SONG_RECORD ) {
		OFSAptr->setSongState(SONG_IDLE);
	}
	
	switch (OFSAptr->getState()) {
		case SOLO_STATE: 
			[(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] pushSetMenu]; 
			break;
			
		case BAND_STATE: {
			[(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] pop]; 
			//[self.navigationController popViewControllerAnimated:YES];
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
		OFSAptr->setSongState(SONG_TRIGGER_RECORD);
		
	}
	
	
}

- (void) save:(id)sender {
	OFSAptr->setSongState(SONG_IDLE);
	
	
	if (self.saveViewController == nil) {
		self.saveViewController = [[SaveViewController alloc] initWithNibName:@"SaveViewController" bundle:nil];
		saveViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	}
	
	
	[(MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate] presentModalViewController:self.saveViewController animated:YES];
	
}



	




- (void)share:(id)sender {
	OFSAptr->setSongState(SONG_IDLE);
	[(MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate] share];
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
	OFSAptr->nextLoop(button.tag);
	
}

- (void) prevLoop:(id)sender {
	UIButton *button = (UIButton*)sender;
	OFSAptr->prevLoop(button.tag);
}





- (void)dealloc {
	
    [super dealloc];
}




- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	MilgromLog(@"MainViewController::viewDidAppear");
    [self becomeFirstResponder];
	
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
