//
//  SongsTable.h
//  MilgromInterface
//
//  Created by Roee Kremer on 7/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class SongCell;
@class SoundSet;
@class Song;
@interface SongsTable : UITableViewController {
	SongCell *tmpCell;
	
	NSMutableArray *songsArray;
	NSManagedObjectContext *managedObjectContext;
}


@property (nonatomic,assign) IBOutlet SongCell *tmpCell;

@property (nonatomic,retain) NSMutableArray *songsArray;
@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;

-(void)selectCurrentSong;
-(void)addCurrentSong;
-(void)updateSong:(Song*)song WithProgress:(NSNumber *)theProgress; // needed for loading and downloading
- (void)deleteSong:(SongCell*)songCell;
- (void)updateProgress:(SongCell*)cell;
- (void) loadData;
@end
