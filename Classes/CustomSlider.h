//
//  CustomSlider.h
//  MilgromInterface
//
//  Created by Roee Kremer on 7/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustomSlider : UISlider {
	UIImage *minTrack;
	UIImage *maxTrack;
}

@property (nonatomic,retain) UIImage *minTrack;
@property (nonatomic,retain) UIImage *maxTrack;

@end
