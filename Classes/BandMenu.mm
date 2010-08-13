//
//  BandMenu.m
//  MilgromInterface
//
//  Created by Roee Kremer on 7/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BandMenu.h"
#import "SongsTable.h"
#import "MainViewController.h"
#import "HelpViewController.h"


@implementation BandMenu

@synthesize songsTable;
@synthesize songsView;
@synthesize mainViewController;
@synthesize help;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	if (self.songsTable == nil) {
		self.songsTable = [[SongsTable alloc] initWithNibName:@"SongsTable" bundle:nil];
		[self.songsView addSubview:songsTable.view];
		//NSArray *array = [NSArray arrayWithObject:self.songsTable.editButtonItem];
	}
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;//(interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) ;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	
	[songsTable release]; // TODO: need to check ?
	[mainViewController release];
	//[help release];
    [super dealloc];
}

- (void)edit:(id)sender {
	UIButton *button = (UIButton*)sender;
	if (button.selected) {
		[self.songsTable setEditing:NO animated:YES];
	} else {
		[self.songsTable setEditing:YES animated:YES];
	}
	
	button.selected = !button.selected;
}

- (void)exit:(id)sender {
	
	if (self.mainViewController == nil) { // this check use in case of loading after warning message...
		self.mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
		//self.menuController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		
		
		//self.menuController = [[MenuViewController alloc] init];
		
		//menuController.mainController = self; // TODO: move testApp to app delegate
	}
	
	[self.navigationController pushViewController:self.mainViewController animated:YES];
	
	//[self dismissModalViewControllerAnimated:YES];
	//MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
	//[appDelegate.viewController dismissMenu:self];
}

- (void)help:(id)sender {
	
	if (self.help == nil) {
		self.help = [[HelpViewController alloc] initWithNibName:@"HelpViewController" bundle:nil];
		help.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	}
	
	
	[self presentModalViewController:self.help animated:YES];
}

- (void)link:(id)sender {
	UIButton *button = (UIButton *)sender;
	
	switch (button.tag) {
		case 0:
			//[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.myspace.com/yesplastic"]];
			[songsTable addDemo];
			break;
		case 1:
			[self exit:nil];
			//[songsTable addSong];
			//[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.facebook.com/pages/Milgrom/137470506285895?ref=ts"]];
			break;
		case 2:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.youtube.com/user/yesplastictube"]];
			break;
		default:
			break;
	}
	
}

@end
