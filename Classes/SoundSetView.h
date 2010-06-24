//
//  SoundSetView.h
//  YesPlastic
//
//  Created by Roee Kremer on 3/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RatingView;
@interface SoundSetView : UITableViewCell {
	BOOL useDarkBackground;
	BOOL loading;
	BOOL locked;
	
    UIImage *icon;
    NSString *publisher;
    NSString *name;
    float rating;
    NSInteger numRatings;
    NSString *price;
	
	IBOutlet UIActivityIndicatorView *activity;
	IBOutlet UIImageView *iconView;
    IBOutlet UILabel *publisherLabel;
    IBOutlet UILabel *nameLabel;
    IBOutlet RatingView *ratingView;
    IBOutlet UILabel *numRatingsLabel;
    IBOutlet UILabel *priceLabel;
	IBOutlet UIButton *buyButton;
}

@property BOOL useDarkBackground;
@property BOOL loading;
@property BOOL locked;

@property(retain) UIImage *icon;
@property(retain) NSString *publisher;
@property(retain) NSString *name;
@property float rating;
@property NSInteger numRatings;
@property(retain) NSString *price;



@end
