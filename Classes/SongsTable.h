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
-(void)deselectCurrentSong;
-(void)addCurrentSong;
-(void)updateSong:(Song*)song WithProgress:(float)theProgress; // needed for loading and downloading
- (void)deleteSong:(id)sender;
- (void) loadData;
- (void) scrollToSongs;
- (BOOL) anySongs; // use to decide if all songs are demo, or there is any real user song
@end
