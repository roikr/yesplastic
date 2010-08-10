//
//  AssetLoader.h
//  MilgromInterface
//
//  Created by Roee Kremer on 8/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "URLCacheConnection.h"

@protocol AssetLoaderDelegate;


@interface AssetLoader : NSObject<URLCacheConnectionDelegate> {
	id <AssetLoaderDelegate> delegate;
	
	NSString *filePath;

}

@property (nonatomic, assign) id delegate;
@property (nonatomic, copy) NSString *filePath;

- (id) initWithURL:(NSURL *)theURL delegate:(id<AssetLoaderDelegate>)theDelegate;
@end

@protocol AssetLoaderDelegate<NSObject>

- (void) loaderDidFail:(AssetLoader *)theLoader;
- (void) loaderDidFinish:(AssetLoader *)theLoader;
- (void) loaderProgress:(NSNumber *)theProgress;

@end



