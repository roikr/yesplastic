//
//  ShareViewController.h
//  Milgrom
//
//  Created by Roee Kremer on 8/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>


@class CustomImageView;


@interface ShareViewController : UIViewController <UINavigationControllerDelegate,UIActionSheetDelegate,MFMailComposeViewControllerDelegate> {
	CustomImageView *progressView;
	
	BOOL _didUploadToYouTube;
	BOOL _didUploadToFacebook;
	BOOL _hasBeenRendered;
	BOOL isTemporary;
	
	NSInteger state;
	UIView *renderingView;
	
	
}



@property (nonatomic,retain) NSNumber *progress;
@property (nonatomic,retain) IBOutlet CustomImageView *progressView;

//@property (nonatomic, retain) NSArray *dataSourceArray;
//@property (nonatomic,assign) IBOutlet ActionCell *tmpCell;

@property (nonatomic, retain) IBOutlet UIView *renderingView;



@property (readonly) BOOL didUploadToYouTube;
@property (readonly) BOOL didUploadToFacebook;
@property (readonly) BOOL hasBeenRendered;


- (void)prepare;
- (void)menu;

@end
