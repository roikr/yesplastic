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

- (void) loadData {
	[self.songsTable loadData];
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
}


- (void)help:(id)sender {
	[((MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate]) help];
}

- (void)link:(id)sender {
	UIButton *button = (UIButton *)sender;
	
	switch (button.tag) {
		case 0:
			//[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.myspace.com/yesplastic"]];
			[(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] share];
			break;
		case 1:
			//[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.facebook.com/pages/Milgrom/137470506285895?ref=ts"]];
			[(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] play];
			break;
		case 2:
			//[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.youtube.com/user/yesplastictube"]];
			[(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] youTubeUpload];
			break;
		default:
			break;
	}
	
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	MilgromLog(@"BandView::viewDidAppear");
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	MilgromLog(@"BandView::viewWillAppear");
}



@end
