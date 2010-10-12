//
//  ShareViewController.h
//  Milgrom
//
//  Created by Roee Kremer on 8/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "FacebookUploadController.h"

@class CustomImageView;



@interface ShareViewController : UIViewController <UINavigationControllerDelegate,UIActionSheetDelegate,MFMailComposeViewControllerDelegate,FacebookControllerDelegate> {
	CustomImageView *progressView;
	BOOL bRendered;
	BOOL bYouTubeUploaded;
	BOOL bFaceBookUploaded;
	
	NSInteger state;
	UIView *renderingView;
	
	FacebookUploadController *facebookController;
}



@property (nonatomic,retain) NSNumber *progress;
@property (nonatomic,retain) IBOutlet CustomImageView *progressView;

//@property (nonatomic, retain) NSArray *dataSourceArray;
//@property (nonatomic,assign) IBOutlet ActionCell *tmpCell;

@property (nonatomic, retain) IBOutlet UIView *renderingView;

@property (nonatomic, retain) FacebookUploadController *facebookController;

- (void)menu;

@end
