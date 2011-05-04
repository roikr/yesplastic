//
//  SaveViewController.m
//  Milgrom
//
//  Created by Roee Kremer on 8/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SaveViewController.h"
#import "CustomFontTextField.h"
#import "MilgromInterfaceAppDelegate.h"
#import "MilgromMacros.h"

#ifdef _FLURRY
#import "FlurryAPI.h"
#endif


@implementation SaveViewController

@synthesize songName;
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
	self.songName.returnKeyType = UIReturnKeyDone;
	
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeRight;
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

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	MilgromLog(@"SaveViewController::viewDidAppear");
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	MilgromLog(@"SaveViewController::viewWillAppear");
	[songName becomeFirstResponder];
#ifdef _FLURRY
	[FlurryAPI logEvent:@"SAVE"];
#endif
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	[self done:nil];
	return NO;
}

- (void)done:(id)sender {
	
	if (![songName.text length]) {
		[MilgromInterfaceAppDelegate alertWithTitle:@"Milgrom Alert" withMessage:@"Don’t you believe in naming your songs?\nplease enter the song name" withCancel:@"OK"];
	} else if ([(MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate] canSaveSongName:songName.text]) {
		[songName resignFirstResponder];
		[(MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate] saveSong:songName.text];
		[self.parentViewController dismissModalViewControllerAnimated:YES];
	} else {
		[MilgromInterfaceAppDelegate alertWithTitle:@"Milgrom Alert" withMessage:@"Cannot save with preset song name" withCancel:@"OK"];
	}
}

- (void)cancel:(id)sender {

	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
    [super dealloc];
}


@end
