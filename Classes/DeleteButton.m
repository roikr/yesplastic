//
//  DeleteButton.m
//  Milgrom
//
//  Created by Roee Kremer on 12/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DeleteButton.h"


@implementation DeleteButton

@synthesize song;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
    [super dealloc];
}


@end
