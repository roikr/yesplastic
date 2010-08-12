//
//  HelpViewController.m
//  MilgromInterface
//
//  Created by Roee Kremer on 7/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HelpViewController.h"


@implementation HelpViewController


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        [super viewDidLoad];
		UIScrollView *tempScrollView=(UIScrollView *)self.view;
		tempScrollView.contentSize=CGSizeMake(480,1180);
    }
    return self;
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) ;
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

- (void) exit:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}
- (void)dealloc {
    [super dealloc];
}


@end
