//
//  FacebookUploadController.h
//  FacebookUpload
//
//  Created by Roee Kremer on 9/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"

@protocol FacebookControllerDelegate;



@interface FacebookUploadController : NSObject<FBRequestDelegate,FBDialogDelegate,FBSessionDelegate>{
	FBSession* session;
		
	NSString *videoName;
	NSString *path;
	
	id <FacebookControllerDelegate> delegate;

}
@property (nonatomic, assign) id<FacebookControllerDelegate> delegate;

@property (nonatomic,retain) FBSession *session;
@property (nonatomic,retain) NSString *videoName;
@property (nonatomic,retain) NSString *path;

- (id)initWithDelegate:(id<FacebookControllerDelegate>)theDelegate;
- (void) uploadVideoWithVideoName:(NSString *)theVideoName andPath:(NSString *)thePath;

@end

@protocol FacebookControllerDelegate<NSObject>

- (void) facebookControllerDidFail:(FacebookUploadController *)theController;
- (void) facebookControllerDidFinish:(FacebookUploadController *)theController;

@end
