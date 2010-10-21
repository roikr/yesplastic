//
//  FacebookUploader.h
//  FacebookUpload
//
//  Created by Roee Kremer on 10/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"

@protocol FacebookUploaderDelegate;


@interface FacebookUploader : NSObject<FBRequestDelegate,FBDialogDelegate,FBSessionDelegate> {

	FBSession* session;
	id <FacebookUploaderDelegate> delegate;
	
	NSString *videoTitle;
	NSString *videoDescription;
	NSString *videoPath;
	
	BOOL isUploading;
	float progress;
	
}

@property (nonatomic, assign) id<FacebookUploaderDelegate> delegate;
@property (nonatomic,retain) FBSession *session;
@property (nonatomic,retain) NSString *videoTitle;
@property (nonatomic,retain) NSString *videoDescription;
@property (nonatomic,retain) NSString *videoPath;

@property (readonly) BOOL isUploading;
@property (readonly) float progress;


+ (FacebookUploader *) facebookUploaderWithDelegate:(id<FacebookUploaderDelegate>)theDelegate; 
- (id)initWithDelegate:(id<FacebookUploaderDelegate>)theDelegate; 
- (void) uploadVideoWithTitle:(NSString *)title withDescription:(NSString *)description andPath:(NSString *)path;
- (void) logout;
- (BOOL) isConnected;
@end

@protocol FacebookUploaderDelegate<NSObject>

- (void) facebookUploaderDidLogin:(FacebookUploader *)theUploader;
- (void) facebookUploaderDidFail:(FacebookUploader *)theUploader;

- (void) facebookUploaderDidStartUploading:(FacebookUploader *)theUploader;
- (void) facebookUploaderDidFinishUploading:(FacebookUploader *)theUploader;
- (void) facebookUploaderProgress:(float)progress;

@end

