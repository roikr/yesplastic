//
//  SetsTable.m
//  MilgromInterface
//
//  Created by Roee Kremer on 7/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SetsTable.h"
#import "SetCell.h"
#import "MilgromInterfaceAppDelegate.h"
#import "Song.h"
#import "SoundSet.h"
#import "MilgromMacros.h"



@implementation SetsTable

@synthesize tmpCell;
@synthesize songsArray;
@synthesize playerName;


#pragma mark -
#pragma mark View lifecycle

/*
- (void)viewDidLoad {
    [super viewDidLoad];
	
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
 */

-(void) loadData {
	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.managedObjectContext; // TODO: why is that - ok to initialize it in case it didn't been initialized yet

	//songsArray = [[NSMutableArray alloc] init]; // TODO: temporal
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Song" inManagedObjectContext:appDelegate.managedObjectContext];
	[request setEntity:entity];
	
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:
								[[NSSortDescriptor alloc] initWithKey:@"bDemo" ascending:YES],
								[[NSSortDescriptor alloc] initWithKey:@"songName" ascending:NO]
								,nil];
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptors release];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bDemo == YES"]; //  AND bReady == YES AND bLocked == NO
    [request setPredicate:predicate];
	
	NSError *error;
	NSArray *fetchResults = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
	
	if (fetchResults == nil) {
	}
	
	[self setSongsArray:fetchResults];
	[request release];
	
	[self.tableView reloadData];
	
}




- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	MilgromLog(@"SetsTable::viewDidAppear");
	
	
	
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	MilgromLog(@"SetsTable::viewWillAppear");
	
	
	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
	//SetCell *cell =  (SetCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[songsArray indexOfObject:demo] inSection:0]];
	[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:[songsArray indexOfObject:[appDelegate getDemoForCurrentSoundSet]] inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
		
}

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


//-(void)selectSong:(Song *)song {
//	
//	SetCell *cell;
//	for (int i=0; i<[self.tableView.dataSource tableView:self.tableView numberOfRowsInSection:0] ; i++) {
//		cell = (SetCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
//		[cell setSelected:NO animated:NO];
//	}
//	
//	cell = (SetCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[songsArray indexOfObject:song] inSection:0]];
//	[cell setSelected:YES animated:YES];
//}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [songsArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    SetCell *cell = (SetCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"SetCell" owner:self options:nil];
        cell = tmpCell;
        self.tmpCell = nil;
		
    }
	Song  *song = (Song *)[songsArray objectAtIndex:indexPath.row];
	// Configure the cell...
	[cell configureCell:[indexPath row] withPlayerName:playerName withLabel:song.songName];
	
    
    return (UITableViewCell*) cell;
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


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
	
	Song *song = [songsArray objectAtIndex:indexPath.row];
	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
	if ([song.bReady boolValue]  && ![song.bLocked boolValue] && song!=[appDelegate getDemoForCurrentSoundSet]) {
		if ([appDelegate loadSoundSetByDemo:song]) {
			[appDelegate popViewController];
		}
	}
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[songsArray release];
    [super dealloc];
}


@end

