//
//  SongCell.h
//  MilgromInterface
//
//  Created by Roee Kremer on 7/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssetLoader.h"

@class CustomFontLabel;
@class SongsTable;
@class Song;
@interface SongCell : UITableViewCell {
	CustomFontLabel *label;
	UIImageView *lock;
	UIButton *deleteButton;
	SongsTable *songsTable;
	NSNumber * _progress;
		
	
	
}

@property (nonatomic,retain) IBOutlet CustomFontLabel *label;
@property (nonatomic,retain) IBOutlet UIImageView *lock;
@property (nonatomic,retain) IBOutlet UIButton *deleteButton;
@property (nonatomic,retain) SongsTable *songsTable;
@property (nonatomic,retain) NSNumber *progress;


- (void) updateBackgroundWithNumber:(NSInteger)num;
- (void) configureWithSong:(Song*)theSong withSongsTable:(SongsTable*)theTable; 
- (void) delete:(id)sender;

@end
