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

- (void) updateAudio:(id)sender {
	OFSAptr->updateAudio();
	
	if (OFSAptr->getIsPlaying()) {
		if (OFSAptr->getIsSongDone()) {
			OFSAptr->stop();
		}
	} else {
		if (playButton.selected) {
			playButton.selected = NO;
		}
	}
	
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
	menuController.view.hidden = NO;
	topMenu.hidden = YES;
}

- (void) dismissMenu:(id)sender {
	menuController.view.hidden = YES;
	topMenu.hidden = NO;
}

- (void) bringPlayerMenu:(id)sender {
	
	PlayerViewContorller *controller = [playerControllers objectAtIndex:OFSAptr->controller];
	[controller show];
	OFSAptr->bMenu=true;
	topMenu.hidden = true;
}

- (void) dismissPlayerMenu:(id)sender {
	
	PlayerViewContorller *controller = [playerControllers objectAtIndex:OFSAptr->controller];
	controller.view.hidden = true;
	OFSAptr->bMenu = false;
	topMenu.hidden = false;
}


- (void) play:(id)sender {
	if (recordButton.selected) 
		return;
	
	playButton.selected = !playButton.selected;
	
	if (playButton.selected) {
		OFSAptr->play();
	}
	else {
		OFSAptr->stop();
	}
	
}

- (void) record:(id)sender {
	if (playButton.selected) 
		return;
	
	recordButton.selected = !recordButton.selected;
	
	if (recordButton.selected) {
		OFSAptr->record();
	}
	else {
		OFSAptr->stop();
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
