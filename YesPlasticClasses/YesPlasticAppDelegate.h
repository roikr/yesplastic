//
//  YesPlasticAppDelegate.h
//  YesPlastic
//
//  Created by Roee Kremer on 1/19/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AuthenticateConnection.h"
#import "CacheResource.h"
#import "XMLParser.h"
#import "ZoozzResourcesLoader.h"

@class MainViewController;

@interface YesPlasticAppDelegate : NSObject <UIApplicationDelegate,AuthenticateConnectionDelegate,CacheResourceDelegate,XMLParserDelegate,ZoozzResourcesLoaderDelegate> {
    UIWindow *window;
	MainViewController *viewController;
	
	NSThread *secondaryThread;
	
	
	
	BOOL bFirstParsing;
	BOOL bLoggingIn;
	
	ZoozzResourcesLoader *resourcesLoader;
	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) MainViewController *viewController;
@property (nonatomic, retain) NSThread *secondaryThread;
@property (nonatomic, retain) ZoozzResourcesLoader *resourcesLoader;



@end

