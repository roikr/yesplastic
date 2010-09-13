//
//  SetsTable.h
//  MilgromInterface
//
//  Created by Roee Kremer on 7/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SetCell;
@class Song;
@interface SetsTable : UITableViewController {
	SetCell *tmpCell;
	
	NSArray *songsArray;
	
}

@property (nonatomic,assign) IBOutlet SetCell *tmpCell;
@property (nonatomic,retain) NSArray *songsArray;

- (void) loadData;
- (void) selectCurrentSet;
-(void)selectSong:(Song *)song;
@end
