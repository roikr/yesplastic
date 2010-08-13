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
@interface SongsTable : UITableViewController {
	SongCell *tmpCell;
	
	NSMutableArray *songsArray;
	NSManagedObjectContext *managedObjectContext;
}


@property (nonatomic,assign) IBOutlet SongCell *tmpCell;

@property (nonatomic,retain) NSMutableArray *songsArray;
@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;

-(void)addSong;
- (void)deleteSong:(SongCell*)songCell;
- (void)updateContext;
@end
