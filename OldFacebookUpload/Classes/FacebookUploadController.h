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
		
	
	
	id <FacebookControllerDelegate> delegate;

}
@property (nonatomic, assign) id<FacebookControllerDelegate> delegate;

@property (nonatomic,retain) FBSession *session;



- (id)initWithDelegate:(id<FacebookControllerDelegate>)theDelegate; 
- (void)login;
- (void) uploadVideoWithVideoName:(NSString *)theVideoName andPath:(NSString *)thePath;

@end

@protocol FacebookControllerDelegate<NSObject>

- (void) facebookControllerDidLogin:(FacebookUploadController *)theController;
- (void) facebookControllerDidFail:(FacebookUploadController *)theController;

- (void) facebookControllerDidStartUploading:(FacebookUploadController *)theController;
- (void) facebookControllerDidFinishUploading:(FacebookUploadController *)theController;

@end
