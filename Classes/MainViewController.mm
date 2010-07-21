//
//  MainViewController.mm
//  YesPlastic
//
//  Created by Roee Kremer on 2/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "MenuViewController.h"
#import "PlayerViewContorller.h"
#import "EAGLView.h"

#include "testApp.h"
#include "Constants.h"

@implementation MainViewController


@synthesize glView;
@synthesize OFSAptr;
@synthesize playButton;
@synthesize recordButton;
@synthesize menuButton;
@synthesize saveButton;
@synthesize topMenu;
@synthesize actionToolBar;
@synthesize menuController;
@synthesize playerControllers;


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
	glView.controller = self;
	OFSAptr = new testApp;
	OFSAptr->setup();
	
	/*
	self.actionToolBar.hidden = true;
	
	menuController.view.hidden = true;
	menuController.view.alpha = 0.5;
	menuController.view.backgroundColor = [UIColor blackColor];
	[self.view addSubview:[menuController view]];
	 */
	
	saveButton.enabled = NO;
	//recordButton.enabled = NO;
	topMenu.hidden = YES;
	
	
	if (self.menuController == nil) { // this check use in case of loading after warning message...
		self.menuController = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
		
		menuController.mainController = self;
	}
	 
	
	
	if (self.playerControllers == nil) { // this check use in case of loading after warning message...
		NSMutableArray *controllers = [[NSMutableArray alloc] init];
		for (unsigned i = 0; i < 3; i++) {
			PlayerViewContorller *controller = [[PlayerViewContorller alloc] initWithNibName:@"PlayerViewController" bundle:nil];
			controller.mainController = self;
			[controllers addObject:controller];
			[controller release];
		}
		self.playerControllers = [NSArray arrayWithArray:controllers];
		[controllers release];
	}
	
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return YES;	
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
	switch (interfaceOrientation) {
		case UIInterfaceOrientationPortrait:
		case UIInterfaceOrientationPortraitUpsideDown:
			OFSAptr->setState(SOLO_STATE);
			break;
		case UIInterfaceOrientationLandscapeRight:
		case UIInterfaceOrientationLandscapeLeft:
			OFSAptr->setState(BAND_STATE);
		default:
			break;
	}
	
	[self dismissMenu:nil];
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



- (void) setupMenus {
	
	[self.view addSubview:menuController.view];
	menuController.view.hidden = YES;
	
	for (unsigned i = 0; i < 3; i++) {
		PlayerViewContorller *controller = [playerControllers objectAtIndex:i];
		[self.view addSubview:controller.view];
		controller.view.hidden = YES;
	}
	
	topMenu.hidden = NO;
}

- (void) bringMenu:(id)sender {
	topMenu.hidden = YES;
	switch (OFSAptr->getState()) {
		case SOLO_STATE: {
			PlayerViewContorller *controller = [playerControllers objectAtIndex:OFSAptr->controller];
			[controller show];
			OFSAptr->bMenu=true;
		} break;
			
		case BAND_STATE: {
			menuController.view.hidden = NO;
		} break;

		default:
			break;
	}
	
}

- (void) dismissMenu:(id)sender {
	topMenu.hidden = NO;
	switch (OFSAptr->getState()) {
		case SOLO_STATE: {
			PlayerViewContorller *controller = [playerControllers objectAtIndex:OFSAptr->controller];
			controller.view.hidden = YES;
			OFSAptr->bMenu = false;
			
		} break;
			
		case BAND_STATE: {
			menuController.view.hidden = YES;
			
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
		

- (void) updateTables {
	[menuController.tableView reloadData];
	
	for (unsigned i = 0; i < 3; i++) {
		PlayerViewContorller *controller = [playerControllers objectAtIndex:i];
		[controller.tableView reloadData];
	}
	
}


- (void)dealloc {
	[glView release];
    [super dealloc];
}


@end
