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
	[songName becomeFirstResponder];
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	[self done:nil];
	return NO;
}

- (void)done:(id)sender {
	[songName resignFirstResponder];
	[(MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate] saveSong:songName.text];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)cancel:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
    [super dealloc];
}


@end
