//
//  ActionCell.m
//  Milgrom
//
//  Created by Roee Kremer on 10/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ActionCell.h"


@implementation ActionCell

@synthesize label;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
} 


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
