//
//  ActionCell.h
//  Milgrom
//
//  Created by Roee Kremer on 10/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomFontLabel;

@interface ActionCell : UITableViewCell {
	CustomFontLabel *label;
}

@property (nonatomic,retain) IBOutlet CustomFontLabel *label;

@end
