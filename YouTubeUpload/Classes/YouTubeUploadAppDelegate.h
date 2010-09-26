//
//  YouTubeUploadAppDelegate.h
//  YouTubeUpload
//
//  Created by Roee Kremer on 9/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YouTubeUploadViewController;

@interface YouTubeUploadAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    YouTubeUploadViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet YouTubeUploadViewController *viewController;

@end

