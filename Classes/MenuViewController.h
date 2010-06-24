//
//  MenuViewController.h
//  YesPlastic
//
//  Created by Roee Kremer on 3/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "SoundSetView.h"

@class MainViewController;

@interface MenuViewController : UITableViewController<SKProductsRequestDelegate> {
	MainViewController *mainController;
	SoundSetView *tmpCell;
	
	NSArray *products;
	
}

@property (nonatomic,retain) MainViewController *mainController;
@property (nonatomic,assign) IBOutlet SoundSetView *tmpCell;
@property (nonatomic,retain) NSArray * products;

- (void)touchDown:(id)sender;
- (void)updateProducts;
- (NSString *)priceOfProduct:(NSString *)productIdentifier;

@end
