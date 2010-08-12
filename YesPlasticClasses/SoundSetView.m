//
//  SoundSetView.m
//  YesPlastic
//
//  Created by Roee Kremer on 3/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SoundSetView.h"
#import "RatingView.h"

@implementation SoundSetView

@synthesize useDarkBackground, icon, publisher, name, rating, numRatings, price, loading, locked;

- (void)setUseDarkBackground:(BOOL)flag
{
    if (flag != useDarkBackground || !self.backgroundView) {
        useDarkBackground = flag;
		
        NSString *backgroundImagePath = [[NSBundle mainBundle] pathForResource:useDarkBackground ? @"DarkBackground" : @"LightBackground" ofType:@"png"];
        UIImage *backgroundImage = [[UIImage imageWithContentsOfFile:backgroundImagePath] stretchableImageWithLeftCapWidth:0.0 topCapHeight:1.0];
        self.backgroundView = [[[UIImageView alloc] initWithImage:backgroundImage] autorelease];
        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundView.frame = self.bounds;
		self.backgroundView.alpha = 0.2;
    }
}


/*
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		
    }
    return self;
}
 */


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
	
    iconView.backgroundColor = backgroundColor;
    publisherLabel.backgroundColor = backgroundColor;
    nameLabel.backgroundColor = backgroundColor;
    ratingView.backgroundColor = backgroundColor;
    numRatingsLabel.backgroundColor = backgroundColor;
    priceLabel.backgroundColor = backgroundColor;
}

- (void)setLoading:(BOOL)bLoading {
	if (bLoading) {
		[activity startAnimating];
		nameLabel.textColor=[UIColor grayColor];
		self.userInteractionEnabled = NO;
	} else {
		[activity stopAnimating];
		nameLabel.textColor=[UIColor whiteColor];
		self.userInteractionEnabled = YES;
	}
}

- (void)setLocked:(BOOL)bLocked {
	
	priceLabel.hidden = bLocked;
	buyButton.hidden = !bLocked;
}
		

- (void)setIcon:(UIImage *)newIcon
{
   
    iconView.image = newIcon;
}

- (void)setPublisher:(NSString *)newPublisher
{
   
    publisherLabel.text = newPublisher;
}

- (void)setRating:(float)newRating
{
  
    ratingView.rating = newRating;
}

- (void)setNumRatings:(NSInteger)newNumRatings
{
   
    numRatingsLabel.text = [NSString stringWithFormat:@"%d Ratings", newNumRatings];
}

- (void)setName:(NSString *)newName
{
	nameLabel.text = newName;
}

- (void)setPrice:(NSString *)newPrice
{

    //priceLabel.text = newPrice;
	if (newPrice) {
		buyButton.hidden = NO;
		buyButton.titleLabel.text = newPrice;
		priceLabel.hidden = NO;
		priceLabel.text = newPrice;
	} else {
		buyButton.hidden = YES;
		priceLabel.hidden = YES;
	}

	
}


- (void)dealloc
{
	
	[icon release];
	[publisher release];
	[name release];
	[price release];
		
    [iconView release];
    [publisherLabel release];
    [nameLabel release];
    [ratingView release];
    [numRatingsLabel release];
    [priceLabel release];
	[activity release];
    [super dealloc];
}



@end
