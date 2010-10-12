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
	Facebook* _facebook;
	NSArray* _permissions;
	
	id <FacebookControllerDelegate> delegate;
	NSInteger state;
}
@property (nonatomic, assign) id<FacebookControllerDelegate> delegate;

- (id)initWithDelegate:(id<FacebookControllerDelegate>)theDelegate;
- (void) publish;
@end

@protocol FacebookControllerDelegate<NSObject>

- (void) facebookControllerDidFail:(FacebookUploadController *)theController;
- (void) facebookControllerDidFinish:(FacebookUploadController *)theController;

@end
