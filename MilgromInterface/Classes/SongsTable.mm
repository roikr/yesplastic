//
//  SongsTable.m
//  MilgromInterface
//
//  Created by Roee Kremer on 7/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SongsTable.h"
#import "SongCell.h"

#import "MilgromInterfaceAppDelegate.h"
#import "Song.h"
#import "SoundSet.h"
#import "VideoSet.h"
#import "MilgromMacros.h"
#import "BandMenu.h"



@implementation SongsTable

@synthesize tmpCell;
@synthesize songsArray;
@synthesize managedObjectContext;


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	
	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
	self.managedObjectContext = appDelegate.managedObjectContext;
	
	//songsArray = [[NSMutableArray alloc] init]; // TODO: temporal
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Song" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:
								[[NSSortDescriptor alloc] initWithKey:@"bDemo" ascending:YES],
								[[NSSortDescriptor alloc] initWithKey:@"songName" ascending:NO]
								,nil];
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptors release];
	
	
	NSError *error;
	
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	if (mutableFetchResults == nil) {
	}
	
	[self setSongsArray:mutableFetchResults];
	[mutableFetchResults release];
	[request release];
	
		
	
	

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


-(void)addDemo {
	Song *song= (Song *)[NSEntityDescription insertNewObjectForEntityForName:@"Song" inManagedObjectContext:managedObjectContext];
	[song setSongName:@"Heat"];
	[song setBLocked:[NSNumber numberWithBool:NO]];
	
	SoundSet *soundSet;
	VideoSet *videoSet;
	soundSet= (SoundSet *)[NSEntityDescription insertNewObjectForEntityForName:@"SoundSet" inManagedObjectContext:managedObjectContext];
	[soundSet setSetName:@"GTR_HEAT"];
	[soundSet setFilename:@"GTR_HEAT.zip"];
	videoSet= (VideoSet *)[NSEntityDescription insertNewObjectForEntityForName:@"VideoSet" inManagedObjectContext:managedObjectContext];
	[videoSet setSetName:@"GTR_ELECTRO"];
	[videoSet setFilename:@"GTR_ELECTRO.zip"];
	[soundSet setVideoSet:videoSet];
	[song addSoundSetsObject:soundSet];
	
	soundSet= (SoundSet *)[NSEntityDescription insertNewObjectForEntityForName:@"SoundSet" inManagedObjectContext:managedObjectContext];
	[soundSet setSetName:@"VOC_HEAT"];
	[soundSet setFilename:@"VOC_HEAT.zip"];
	videoSet= (VideoSet *)[NSEntityDescription insertNewObjectForEntityForName:@"VideoSet" inManagedObjectContext:managedObjectContext];
	[videoSet setSetName:@"VOC_BB"];
	[videoSet setFilename:@"VOC_BB.zip"];
	[soundSet setVideoSet:videoSet];
	[song addSoundSetsObject:soundSet];
	
	
	soundSet= (SoundSet *)[NSEntityDescription insertNewObjectForEntityForName:@"SoundSet" inManagedObjectContext:managedObjectContext];
	[soundSet setSetName:@"DRM_HEAT"];
	[soundSet setFilename:@"DRM_HEAT.zip"];
	videoSet= (VideoSet *)[NSEntityDescription insertNewObjectForEntityForName:@"VideoSet" inManagedObjectContext:managedObjectContext];
	[videoSet setSetName:@"DRM_ELECTRO"];
	[videoSet setFilename:@"DRM_ELECTRO.zip"];
	[soundSet setVideoSet:videoSet];
	[song addSoundSetsObject:soundSet];
	
	NSError *error;
	if (![managedObjectContext save:&error]) {
		MilgromLog(@"%@",[error description]);
	}
	
	[songsArray addObject:song];
	
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}


-(void)addSong {
	Song *song= (Song *)[NSEntityDescription insertNewObjectForEntityForName:@"Song" inManagedObjectContext:managedObjectContext];
	[song setSongName:@"My Song"];
	
	[song setBReady:[NSNumber numberWithBool:YES]];
	
	
	NSError *error;
	if (![managedObjectContext save:&error]) {
	}
	
	[songsArray addObject:song];
	
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([songsArray count]-1) inSection:0];
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	 [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)deleteSong:(SongCell*)songCell {
	
	NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)songCell];
	
	[self.tableView.dataSource tableView:self.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
	
}

- (void)updateContext {
	NSError *error;
	if (![managedObjectContext save:&error]) {
		
	}
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
    
	
	SongCell *cell = (SongCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"SongCell" owner:self options:nil];
        cell = tmpCell;
        self.tmpCell = nil;
		
    }
	
	 // Configure the cell...
	Song *song = (Song *)[songsArray objectAtIndex:indexPath.row];
	[cell updateBackgroundWithNumber:[indexPath row]];
	[cell configureWithSong:song withSongsTable:self];
		    
    
    return (UITableViewCell*) cell;
}


/*
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}
 */

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	
    // Return NO if you do not want the specified item to be editable.
    return YES;//[indexPath row]>2;
}




// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		NSManagedObject *songToDelete = [songsArray objectAtIndex:indexPath.row];
		[managedObjectContext deleteObject:songToDelete];
		
		[songsArray removeObjectAtIndex:indexPath.row];
		
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		
		NSError *error;
		
		if (![managedObjectContext save:&error]) {
			
		}
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



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
	
	//MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
	//[appDelegate.viewController dismissMenu:self];
	
	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate loadSong:nil];
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
	self.songsArray = nil;
	
}


- (void)dealloc {
	[managedObjectContext release];
	[songsArray release];
    [super dealloc];
}


@end

