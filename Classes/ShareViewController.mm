//
//  ShareViewController.m
//  Milgrom
//
//  Created by Roee Kremer on 4/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShareViewController.h"
#import "MilgromInterfaceAppDelegate.h"
#import "ShareManager.h"
#import "MilgromMacros.h"

#ifdef _FLURRY
#import "FlurryAPI.h"
#endif


@implementation ShareViewController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeRight;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	MilgromLog(@"ShareViewController::viewWillAppear");
#ifdef _FLURRY
	[FlurryAPI logEvent:@"SHARE"];
#endif
}

- (void)dealloc {
    [super dealloc];
}

- (void) action:(id)sender {
		
	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	
	UIButton *button = (UIButton *)sender;
	NSInteger action;
	
	switch (button.tag)
	{
		case 0: 
			action = ACTION_UPLOAD_TO_FACEBOOK;
			break;
		case 1:
			action = ACTION_UPLOAD_TO_YOUTUBE;
			break;
		case 2:
			action = ACTION_ADD_TO_LIBRARY;
			break;
		case 3:
			action = ACTION_SEND_VIA_MAIL;
			break;
		case 4:
			action = ACTION_SEND_RINGTONE;
			break;
		case 5:
			action = ACTION_CANCEL;
			break;
	}
	
	[self.parentViewController dismissModalViewControllerAnimated:action==ACTION_CANCEL];
	
	[appDelegate.shareManager action:action];
}

@end
