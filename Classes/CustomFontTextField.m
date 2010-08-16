//
//  CustomFontTextField.m
//  MilgromInterface
//
//  Created by Roee Kremer on 8/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CustomFontTextField.h"


@implementation CustomFontTextField


- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder: decoder])
    {
        [self setFont: [UIFont fontWithName: @"Wonderlism" size: self.font.pointSize]];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [super dealloc];
}


@end
