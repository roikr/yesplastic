//
//  ShareViewController.h
//  Milgrom
//
//  Created by Roee Kremer on 8/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomImageView;
@class AVAssetExportSession;

@interface ShareViewController : UIViewController<UINavigationControllerDelegate> {
	CustomImageView *progressView;
	BOOL bRender;
}

@property (nonatomic,retain) NSNumber *progress;
@property (nonatomic,retain) IBOutlet CustomImageView *progressView;
@property BOOL bRender;


- (void)done:(id)sender;
- (void)play:(id)sender;
- (void)youTube:(id)sender;
- (void)render;

@end
