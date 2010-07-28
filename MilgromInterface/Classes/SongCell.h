//
//  SongCell.h
//  MilgromInterface
//
//  Created by Roee Kremer on 7/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomFontLabel;

@interface SongCell : UITableViewCell {
	CustomFontLabel *label;
	UIImageView *lock;
	UIButton *deleteButton;
	
}

@property (nonatomic,retain) IBOutlet CustomFontLabel *label;
@property (nonatomic,retain) IBOutlet UIImageView *lock;
@property (nonatomic,retain) IBOutlet UIButton *deleteButton;


- (void) configureCell:(NSInteger)num withLabel:(NSString*)theLabel; 

@end
