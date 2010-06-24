//
//  MenuViewController.m
//  YesPlastic
//
//  Created by Roee Kremer on 3/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MenuViewController.h"
#import "MainViewController.h"
#import "LocalStorage.h"
#import "SoundSet.h"
#include "testApp.h"
#import "SoundSetView.h"
#import "ZoozzMacros.h"


/*
 Predefined colors to alternate the background color of each cell row by row (see tableView:cellForRowAtIndexPath: and tableView:willDisplayCell:forRowAtIndexPath:).
 */
#define DARK_BACKGROUND  [UIColor colorWithRed:151.0/255.0 green:152.0/255.0 blue:155.0/255.0 alpha:1.0]
#define LIGHT_BACKGROUND [UIColor colorWithRed:172.0/255.0 green:173.0/255.0 blue:175.0/255.0 alpha:1.0]


@implementation MenuViewController

@synthesize mainController;
@synthesize tmpCell;
@synthesize products;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/


- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	// Configure the table view.
    self.tableView.rowHeight = 73.0;
	//self.tableView.backgroundColor = DARK_BACKGROUND;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
}


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
    
    static NSString *CellIdentifier = @"Cell";
    
    SoundSetView *cell = (SoundSetView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"SoundSetView" owner:self options:nil];
        cell = tmpCell;
        self.tmpCell = nil;
	
    }
    
	SoundSet *soundSet = [[LocalStorage localStorage].soundSets objectAtIndex:indexPath.row];

	// Display dark and light background in alternate rows -- see tableView:willDisplayCell:forRowAtIndexPath:.
	cell.useDarkBackground = (indexPath.row % 2 == 0);
	cell.loading = !mainController.OFSAptr->isSoundSetAvailiable([soundSet.originalID UTF8String]);
	cell.name = soundSet.originalID;
	cell.locked = soundSet.bLocked;
	cell.price = [self priceOfProduct:soundSet.productIdentifier];	
	
	// Configure the data for the cell.
	/*
    NSDictionary *dataItem = [data objectAtIndex:indexPath.row];
    cell.icon = [UIImage imageNamed:[dataItem objectForKey:@"Icon"]];
    cell.publisher = [dataItem objectForKey:@"Publisher"];
    cell.name = [dataItem objectForKey:@"Name"];
    cell.numRatings = [[dataItem objectForKey:@"NumRatings"] intValue];
    cell.rating = [[dataItem objectForKey:@"Rating"] floatValue];
    cell.price = [dataItem objectForKey:@"Price"];
	*/
	
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    // Set up the cell...
	
    return cell;
	
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	[mainController dismissMenu:nil];
	
	
	SoundSet *soundSet = [[LocalStorage localStorage].soundSets objectAtIndex:indexPath.row];
	
	string nextSoundSet = [soundSet.originalID UTF8String];
	if (  !mainController.OFSAptr->isInTransition() && mainController.OFSAptr->isSoundSetAvailiable(nextSoundSet)) {
		
		mainController.OFSAptr->changeSoundSet(nextSoundSet, true);
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


- (void)dealloc {
    [super dealloc];
}

- (void)touchDown:(id)sender {
	[mainController dismissMenu:nil];
}

- (void)updateProducts {
	NSMutableSet *productsIdentifiers = [NSMutableSet set];
	for (SoundSet *soundSet in [LocalStorage localStorage].soundSets) {
		if (soundSet.bLocked)
			[productsIdentifiers addObject:soundSet.productIdentifier];
	}
	SKProductsRequest * request = [[SKProductsRequest alloc] initWithProductIdentifiers:productsIdentifiers];
	request.delegate = self;
	[request start];
	
}

-(void) productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
	self.products = response.products;
	[self.tableView reloadData];
}
	

- (NSString *)priceOfProduct:(NSString *)productIdentifier {
	for (SKProduct * aProduct in products) {
		//ZoozzLog([NSString stringWithFormat:@"title: %@, desciption: %@, id: %@",[aProduct localizedTitle],[aProduct localizedDescription],[aProduct productIdentifier]]);
		ZoozzLog([aProduct productIdentifier]);
		if ([aProduct.productIdentifier isEqualToString:productIdentifier]) {
						
			NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
			[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
			[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
			[numberFormatter setLocale:aProduct.priceLocale];
			NSString *formattedString = [numberFormatter stringFromNumber:aProduct.price];
			return formattedString;
		}
	}
	return nil;
}


@end

