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


enum {
	ACTION_UPLOAD_TO_YOUTUBE,
	ACTION_UPLOAD_TO_FACEBOOK,
	ACTION_ADD_TO_LIBRARY,
	ACTION_SEND_VIA_MAIL,
	ACTION_SEND_RINGTONE,
	ACTION_CANCEL,
	ACTION_RENDER,
	ACTION_PLAY
};


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
- (NSString *)getSongName;
- (NSString *)getDisplayName;
- (NSString *)getVideoPath;

//- (void)menuWithView:(UIView *)view;
- (void)start:(NSInteger)actionToStart;
- (void)action;
- (void)cancel;
- (void)resetVersions;
//- (void)prepare;
- (void)applicationDidEnterBackground;

@end
