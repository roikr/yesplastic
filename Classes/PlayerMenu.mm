//
//  PlayerMenu.m
//  MilgromInterface
//
//  Created by Roee Kremer on 7/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PlayerMenu.h"
#import "SetsTable.h"
#import "MilgromInterfaceAppDelegate.h"
#import "testApp.h"
#import "CustomSlider.h"
#import "MilgromMacros.h"


@implementation PlayerMenu

@synthesize setsTable;
@synthesize setsView;
@synthesize volumeSlider;
@synthesize bpmSlider;

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
	if (self.setsTable == nil) {
		self.setsTable = [[SetsTable alloc] initWithNibName:@"SetsTable" bundle:nil];
		[self.setsView addSubview:setsTable.view];
		//NSArray *array = [NSArray arrayWithObject:self.songsTable.editButtonItem];
	}
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
	//[setsTable viewDidAppear:animated];
	MilgromLog(@"PlayerMenu::viewDidAppear");
	volumeSlider.value = ((MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate]).OFSAptr->getVolume();
	bpmSlider.value = ((MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate]).OFSAptr->getBPM();

   
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	//[setsTable viewWillAppear:animated];
	MilgromLog(@"PlayerMenu::viewWillAppear");
}



- (void)volumeChanged:(id)sender {
	
	((MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate]).OFSAptr->setVolume(volumeSlider.value);
	
}

- (void) bpmChanged:(id)sender {
	
	((MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate]).OFSAptr->setBPM(bpmSlider.value);
}

- (void)exit:(id)sender {
	((MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate]).OFSAptr->bMenu=false;
	[self.navigationController popViewControllerAnimated:YES];
	
}


- (void)dealloc {
	[setsTable release];
    [super dealloc];
}


@end
