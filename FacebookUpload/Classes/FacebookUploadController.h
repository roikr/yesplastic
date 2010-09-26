//
//  FacebookUploadController.h
//  FacebookUpload
//
//  Created by Roee Kremer on 9/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"


@interface FacebookUploadController : NSObject<FBRequestDelegate,FBDialogDelegate,FBSessionDelegate>{
	Facebook* _facebook;
	NSArray* _permissions;
}

- (id)init;

@end
