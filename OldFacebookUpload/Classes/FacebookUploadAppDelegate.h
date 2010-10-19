//
//  FacebookUploadAppDelegate.h
//  FacebookUpload
//
//  Created by Roee Kremer on 9/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookUploadController.h"

@class FacebookUploadController;

@interface FacebookUploadAppDelegate : NSObject <UIApplicationDelegate,FacebookControllerDelegate> {
    UIWindow *window;
	FacebookUploadController *controller;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) FacebookUploadController *controller;

@end
 
