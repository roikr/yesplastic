//
//  SongCell.h
//  MilgromInterface
//
//  Created by Roee Kremer on 7/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomFontLabel;
@class CustomImageView;
@class Song;
@class DeleteButton;

@interface SongCell : UITableViewCell {
	CustomFontLabel *label;
	UIImageView *lock;
	DeleteButton *deleteButton;
	float progress;
	CustomImageView *progressView; 
	
	BOOL isSong;
}

@property (nonatomic,retain) IBOutlet CustomFontLabel *label;
@property (nonatomic,retain) IBOutlet UIImageView *lock;
@property (nonatomic,retain) IBOutlet DeleteButton *deleteButton;
@property float progress;
@property (nonatomic,retain) IBOutlet CustomImageView *progressView;
@property BOOL isSong;
@property BOOL progressHidden;

- (void) updateBackgroundWithNumber:(NSInteger)num;


@end
