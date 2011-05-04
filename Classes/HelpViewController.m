//
//  HelpViewController.m
//  MilgromInterface
//
//  Created by Roee Kremer on 7/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HelpViewController.h"
#import "MilgromMacros.h"

#ifdef _FLURRY
#import "FlurryAPI.h"
#endif


@implementation HelpViewController

@synthesize scrollView;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    }
    return self; 
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	scrollView.transform = CGAffineTransformIdentity;
	scrollView.transform = CGAffineTransformMakeRotation(0.5*M_PI);
	scrollView.bounds = CGRectMake(0.0f, 0.0f, 480.0f, 320.0f);
	scrollView.center = CGPointMake(160.0f, 240.0f);
	
	scrollView.contentSize=CGSizeMake(480,1152);
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	MilgromLog(@"HelpViewController::viewWillAppear");
	[scrollView setContentOffset:CGPointMake(0.0f, 0.0f) animated:NO];
#ifdef _FLURRY
	[FlurryAPI logEvent:@"HELP"];
#endif
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
