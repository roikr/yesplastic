//
//  CustomSlider.m
//  MilgromInterface
//
//  Created by Roee Kremer on 7/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CustomSlider.h"


@implementation CustomSlider

@synthesize minTrack;
@synthesize maxTrack;
@synthesize playerName;


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder: decoder])
    {
		
		self.minTrack = [UIImage imageNamed:[NSString stringWithFormat:@"%@_SLIDER_OVER.png",playerName]];
		self.maxTrack = [UIImage imageNamed:[NSString stringWithFormat:@"%@_SLIDER_BACK.png",playerName]];
		[self setThumbImage: [UIImage imageNamed:[NSString stringWithFormat:@"%@_SLIDER_PIN.png",playerName]] forState:UIControlStateNormal];
		//[self setThumbImage: [UIImage imageNamed:@"slider2_B_PUSH.png"] forState:UIControlStateHighlighted];
		CGRect frame = self.frame;
		frame.size = minTrack.size;
		self.frame = frame;
		
		[self setMinimumTrackImage:minTrack forState:UIControlStateNormal];
		[self setMaximumTrackImage:maxTrack forState:UIControlStateNormal];
//        UIImage *stetchLeftTrack = [[UIImage imageNamed:@"sliderOrange.png"]
//									stretchableImageWithLeftCapWidth:5.0 topCapHeight:0.0];
//		UIImage *stetchRightTrack = [[UIImage imageNamed:@"sliderGrey.png"]
//									 stretchableImageWithLeftCapWidth:5.0 topCapHeight:0.0];
//		
//		//coffee
//		CGRect coffeeSliderRect = CGRectMake(20, 167.0, 277, 23);
//		coffeeSlider = [[UISlider alloc] initWithFrame:coffeeSliderRect];
//		[coffeeSlider addTarget:self action:@selector(coffeeSliderChanged) forControlEvents:UIControlEventValueChanged];
//		coffeeSlider.backgroundColor = [UIColor clearColor];	
//		
//		
//		coffeeSlider.minimumValue = 0.0;
//		coffeeSlider.maximumValue = 10.0;
//		coffeeSlider.continuous = NO;
//		coffeeSlider.value = 0.0;
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
	[minTrack release];
	[maxTrack release];
    [super dealloc];
}


@end
