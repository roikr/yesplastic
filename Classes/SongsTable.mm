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
#import "testApp.h" // for loading progress
#import "DeleteButton.h"


@interface SongsTable()
- (NSIndexPath *) currentSongIndexPath;
@end

@implementation SongsTable

@synthesize tmpCell;
@synthesize songsArray;
@synthesize managedObjectContext;


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
	self.managedObjectContext = appDelegate.managedObjectContext;
	
	
	
	//songsArray = [[NSMutableArray alloc] init]; // TODO: temporal
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Song" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:
								[[NSSortDescriptor alloc] initWithKey:@"bDemo" ascending:NO],
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
	
	
	[self.tableView reloadData];
}

- (void) scrollToSongs {
	
	CGPoint offset = CGPointMake(0, 0);
	
	for (int i=0; i< [songsArray count]; i++) { // [self.tableView.dataSource tableView:self.tableView numberOfRowsInSection:0]
		Song *song = (Song *)[songsArray objectAtIndex:i];
		
		//MilgromLog(@"SongsTable::cell: %i %@",i,song.songName);
		if (![song.bDemo boolValue]) {
			offset.y = i*44;
			break;
		}
	}
	CGFloat maxOffset = self.tableView.contentSize.height - self.tableView.frame.size.height;
	offset.y = min(offset.y,maxOffset);
	//MilgromLog(@"SongsTable::scrollToSongs: %f %f",offset.x,offset.y);
	[self.tableView setContentOffset:offset animated:YES];
	
}

- (BOOL) anySongs {
	for (int i=0; i< [songsArray count]; i++) { // [self.tableView.dataSource tableView:self.tableView numberOfRowsInSection:0]
		Song *song = (Song *)[songsArray objectAtIndex:i];
		
		//MilgromLog(@"SongsTable::cell: %i %@",i,song.songName);
		if (![song.bDemo boolValue]) {
			return YES;
		}
	}
	
	return NO;
}

- (NSIndexPath *) currentSongIndexPath {
	Song * song = [(MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate] currentSong];
	return [NSIndexPath indexPathForRow:[songsArray indexOfObject:song] inSection:0];
}

-(void)deselectCurrentSong {
	[self.tableView deselectRowAtIndexPath:[self currentSongIndexPath] animated:NO];
	
}

-(void)selectCurrentSong {
	
	[self.tableView selectRowAtIndexPath:[self currentSongIndexPath] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
	
}


-(void)addCurrentSong {
	
	Song * song = [(MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate] currentSong];
	
	[songsArray addObject:song];
	
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([songsArray count]-1) inSection:0];
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	
	 //[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


- (void)deleteSong:(id)sender {
	
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[songsArray indexOfObject:((DeleteButton *)sender).song] inSection:0];
	[self.tableView.dataSource tableView:self.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
	
}

-(void)updateSong:(Song*)song WithProgress:(float)theProgress {
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[songsArray indexOfObject:song] inSection:0];
	SongCell *cell = (SongCell*)[self.tableView cellForRowAtIndexPath:indexPath];
	if (cell.progressHidden) {
		cell.progressHidden = NO;
	}
	[cell setProgress:theProgress];
	
}

/*
- (void)viewWillAppear:(BOOL)animated {
	// [super viewWillAppear:animated]; // this will cause selected background to disappear
	MilgromLog(@"SongsTable::viewWillAppear");
	//self.view.userInteractionEnabled = YES;
	
	
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

- (void)hideCurrentSongProgress {
	SongCell *cell = (SongCell*)[self.tableView cellForRowAtIndexPath:[self currentSongIndexPath]];
	cell.progressHidden = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
	MilgromLog(@"SongsTable::viewDidDisappear");
    [super viewDidDisappear:animated];
	[self hideCurrentSongProgress];
}




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
		
	[cell.deleteButton addTarget:self action:@selector(deleteSong:) forControlEvents:UIControlEventTouchUpInside];
	cell.deleteButton.song = song;
	cell.isSong = ![song.bDemo boolValue];
	((UILabel*)cell.label).text = song.displayName;
	
	if (![song.bReady boolValue]) {
		[cell setProgress:0.0f];
	}
    
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
		
		[((MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate]).bandMenu updateEditMode];
		
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

/*
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
	//SongCell *cell = (SongCell*)[self.tableView cellForRowAtIndexPath:indexPath];
	Song *song = (Song *)[songsArray objectAtIndex:indexPath.row];
	
	//if (!cell.selected) {
	if ([appDelegate currentSong] && song == [appDelegate currentSong]) {	
		MilgromLog(@"SongsTable::willSelectRowAtIndexPath: Song already selected");
		
		
	} else {
		[appDelegate loadSong:song];
		
	}

	return indexPath;
}
*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[(MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate] loadSong:[songsArray objectAtIndex:indexPath.row]];
	//self.view.userInteractionEnabled = NO;
}



#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	[super viewDidUnload];
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	//self.songsArray = nil;
	
	// TODO: after some memory warnings the songs disappear, I supposed the problem is here and with viewDidLoad;
	
}


- (void)dealloc {
	[managedObjectContext release];
	[songsArray release];
    [super dealloc];
}


@end

