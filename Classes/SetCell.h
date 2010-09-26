//
//  SetCell.h
//  MilgromInterface
//
//  Created by Roee Kremer on 7/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomFontLabel;


@interface SetCell : UITableViewCell {
	CustomFontLabel *label;
	

}

@property (nonatomic,retain) IBOutlet CustomFontLabel *label;


- (void) configureCell:(NSInteger)num withPlayerName:(NSString *)playerName withLabel:(NSString*)theLabel;

@end
