//
//  PlayerViewContorller.m
//  YesPlastic
//
//  Created by Roee Kremer on 2/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PlayerViewContorller.h"

#import "MainViewController.h"
#include "testApp.h"
#include "PlayerController.h"
#include "LocalStorage.h"
#include "SoundSet.h"

@implementation PlayerViewContorller

@synthesize mainController;
@synthesize timer;
@synthesize volumeSlider;
@synthesize bpmSlider;



/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

/*
- (void)viewDidLoad {
    [super viewDidLoad];
	
	volumeSlider.value = mainController.OFSAptr->getVolume();
	bpmSlider.value = mainController.OFSAptr->getBPM();
	
	//PlayerController *player = controller.OFSAptr->player+controller.OFSAptr->controller;
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

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
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[LocalStorage localStorage].soundSets count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
   	
	static NSString *kCellIdentifier = @"MyCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier] autorelease];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:20.0];
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.textColor=[UIColor whiteColor];
    }
	SoundSet *soundSet = [[LocalStorage localStorage].soundSets objectAtIndex:indexPath.row];
	cell.textLabel.text = soundSet.originalID;
	
	if (!mainController.OFSAptr->isSoundSetAvailiable([soundSet.originalID UTF8String])) {
		cell.textLabel.textColor=[UIColor grayColor];
		cell.userInteractionEnabled = NO;
	} else {
		cell.textLabel.textColor=[UIColor whiteColor];
		cell.userInteractionEnabled = YES;
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	[mainController dismissPlayerMenu:nil];
	
	PlayerController *player = mainController.OFSAptr->player+mainController.OFSAptr->controller;
	SoundSet *soundSet = [[LocalStorage localStorage].soundSets objectAtIndex:indexPath.row];

	string nextSoundSet = [soundSet.originalID UTF8String];
	if ( player->getCurrentSoundSet() != nextSoundSet && !player->isInTransition() && mainController.OFSAptr->isSoundSetAvailiable(nextSoundSet)) {
		mainController.OFSAptr->changeSoundSet(nextSoundSet, false);
	}
	
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)show {
	self.view.hidden = false;
	if ([self isViewLoaded]) {
		volumeSlider.value = mainController.OFSAptr->getVolume();
		bpmSlider.value = mainController.OFSAptr->getBPM();
		
	}
	
	
}

- (void)touchDown:(id)sender {
	[timer invalidate];
	self.timer = nil;
}

- (void)volumeChanged:(id)sender {
	mainController.OFSAptr->setVolume(volumeSlider.value);

}

- (void)touchUp:(id)sender {
	if (timer) {
		[timer invalidate];
		self.timer = nil;
	}
	self.timer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)(1.0) target:mainController selector:@selector(dismissPlayerMenu:) userInfo:nil repeats:NO];
	
	if (sender == bpmSlider) {
		mainController.OFSAptr->setBPM(bpmSlider.value);
	}
}





- (void)dealloc {
    [super dealloc];
}


@end

