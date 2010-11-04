//
//  ShareManager.h
//  Milgrom
//
//  Created by Roee Kremer on 10/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "FacebookUploader.h"
#import "YouTubeUploader.h"

@interface ShareManager : NSObject<FacebookUploaderDelegate,YouTubeUploaderDelegate,MFMailComposeViewControllerDelegate,UIActionSheetDelegate> {
	FacebookUploader *facebookUploader;
	YouTubeUploader *youTubeUploader;
	
	BOOL _didUploadToYouTube;
	BOOL _didUploadToFacebook;
	BOOL _hasBeenRendered;
	BOOL isTemporary;
	BOOL canSendMail;
	NSInteger action;
	NSInteger state;
}


@property (nonatomic,retain) FacebookUploader *facebookUploader;
@property (nonatomic,retain) YouTubeUploader *youTubeUploader;
@property (readonly) BOOL isUploading;

@property (readonly) BOOL didUploadToYouTube;
@property (readonly) BOOL didUploadToFacebook;
@property (readonly) BOOL hasBeenRendered;



+ (ShareManager*) shareManager;
- (void)setRendered;
- (NSString *)getVideoName;
- (NSString *)getVideoPath;
- (NSString *)getVideoTitle;
- (void)menuWithView:(UIView *)view;
- (void)action;
- (void)cancel;
//- (void)prepare;


@end
