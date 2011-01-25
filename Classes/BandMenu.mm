//
//  BandMenu.m
//  MilgromInterface
//
//  Created by Roee Kremer on 7/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BandMenu.h"
#import "SongsTable.h"
#import "MilgromInterfaceAppDelegate.h"
#import "MilgromMacros.h"



@implementation BandMenu

@synthesize songsTable;
@synthesize songsView;
@synthesize activityIndicator;
@synthesize editButton;
@synthesize firstLaunchView;




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
	MilgromLog(@"BandView::viewDidLoad");
	if (self.songsTable == nil) {
		self.songsTable = [[SongsTable alloc] initWithNibName:@"SongsTable" bundle:nil];
		
	}
		
	[self.songsView addSubview:songsTable.view];
	
		//NSArray *array = [NSArray arrayWithObject:self.songsTable.editButtonItem];
	

}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	self.editButton = nil;
	self.activityIndicator = nil;
	self.songsView = nil;
	//[songsTable release];
	//self.songsTable = nil;
    [super viewDidUnload];
	//self.songsTable = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	
	[songsTable release]; // TODO: need to check ?
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
	
	if (button.selected) {
		[self.songsTable scrollToSongs];
	}
}

- (void)cancelEdit {
	if (editButton.selected) {
		[self edit:editButton];
	}
}


- (void)help:(id)sender {
	[self cancelEdit];
	[((MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate]) help];
}

- (void)link:(id)sender {
	[self cancelEdit];
	UIButton *button = (UIButton *)sender;
	
	switch (button.tag) {
		case 0:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.myspace.com/milgromband"]];
			break;
		case 1:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.facebook.com/pages/Milgrom/137470506285895?ref=ts"]];
			break;
		case 2:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.youtube.com/user/yesplastictube"]];
			
			break;
		default:
			break;
	}
	
}

/*
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	MilgromLog(@"BandView::viewDidAppear");
}
 */

- (void)viewWillAppear:(BOOL)animated {
	MilgromLog(@"BandView::viewWillAppear");
	[super viewWillAppear:animated];
	self.view.userInteractionEnabled = YES;
	//[songsTable viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	MilgromLog(@"BandView::viewDidDisappear");
    [super viewDidDisappear:animated];
	[songsTable viewDidDisappear:animated];
}



@end
