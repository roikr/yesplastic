//
//  DemoLoader.h
//  Milgrom
//
//  Created by Roee Kremer on 8/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssetLoader.h"

@protocol DemoLoaderDelegate;


@class Song;
@interface DemoLoader : NSObject<AssetLoaderDelegate> {
	id <DemoLoaderDelegate> delegate;
	Song *song;
	int currentSet;
}

@property (nonatomic,assign) id<DemoLoaderDelegate> delegate;
@property (nonatomic,retain) Song *song;


- (id) initWithSong:(Song *)theSong delegate:(id<DemoLoaderDelegate>)theDelegate;

@end

@protocol DemoLoaderDelegate<NSObject>

- (void) loaderDidFinish:(DemoLoader *)theLoader;
- (void) loader:(DemoLoader *)theLoader withProgress:(float)theProgress;


@end