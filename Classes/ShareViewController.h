//
//  ShareViewController.h
//  Milgrom
//
//  Created by Roee Kremer on 4/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ShareViewController : UIViewController {
	UIView *slides;
	UIView *container;
}

@property (nonatomic, retain) IBOutlet UIView *slides;
@property (nonatomic, retain) IBOutlet UIView *container;

- (void) action:(id)sender;
- (void) tutorialShare;


@end
