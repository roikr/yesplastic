//
//  YouTubeUploader.h
//  YouTubeUpload
//
//  Created by Roee Kremer on 10/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GDataServiceTicket;

@protocol YouTubeUploaderDelegate;


@interface YouTubeUploader : NSObject {

	GDataServiceTicket *mUploadTicket;
	id <YouTubeUploaderDelegate> delegate;
	
		
	NSString *username;
	NSString *password;
	
	BOOL isUploading;
	float progress;
	
}

@property (nonatomic, assign) id<YouTubeUploaderDelegate> delegate;
@property (nonatomic,retain) NSString *username;
@property (nonatomic,retain) NSString *password;
@property (readonly) BOOL isUploading;
@property (readonly) float progress;


+ (YouTubeUploader *) youTubeUploaderWithDelegate:(id<YouTubeUploaderDelegate>)theDelegate; 
- (id)initWithDelegate:(id<YouTubeUploaderDelegate>)theDelegate; 
- (void) uploadVideoWithTitle:(NSString *)title withDescription:(NSString *)description andPath:(NSString *)path;
@end

@protocol YouTubeUploaderDelegate<NSObject>

//- (void) facebookUploaderDidLogin:(YouTubeUploader *)theUploader;
-(void) youTubeUploaderDidFail:(YouTubeUploader *)theUploader;

- (void) youTubekUploaderDidStartUploading:(YouTubeUploader *)theUploader;
- (void) youTubeUploaderDidFinishUploading:(YouTubeUploader *)theUploader;
- (void) youTubeUploaderProgress:(float)progress;

@end

