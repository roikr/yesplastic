//
//  ShareViewController.h
//  Milgrom
//
//  Created by Roee Kremer on 8/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomImageView;

@interface ShareViewController : UIViewController {
	CustomImageView *progressView;
}

@property (nonatomic,retain) NSNumber *progress;
@property (nonatomic,retain) IBOutlet CustomImageView *progressView;


- (void)done:(id)sender;
- (void)render;
@end
