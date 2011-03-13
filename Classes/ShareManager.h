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
	
	NSInteger renderedVideoVersion;
	NSInteger exportedRingtoneVersion;
	BOOL canSendMail;
	NSInteger action;
	NSInteger state;
	
	UIActionSheet* sheet;
}


@property (nonatomic,retain) FacebookUploader *facebookUploader;
@property (nonatomic,retain) YouTubeUploader *youTubeUploader;
@property (readonly) BOOL isUploading;

@property (readonly) BOOL videoRendered;
@property (readonly) BOOL ringtoneExported;

@property (nonatomic, retain) UIActionSheet *sheet;


+ (ShareManager*) shareManager;
- (NSString *)getVideoName;
- (NSString *)getVideoPath;

- (void)menuWithView:(UIView *)view;
- (void)action;
- (void)cancel;
- (void)resetVersions;
//- (void)prepare;
- (void)applicationDidEnterBackground;

@end
