//
//  ZoozzResourcesLoader.h
//  YesPlastic
//
//  Created by Roee Kremer on 3/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CacheResource.h"

@protocol ZoozzResourcesLoaderDelegate;

@class Asset;
@interface ZoozzResourcesLoader : NSObject<CacheResourceDelegate> {
	NSMutableArray * assets;
	Asset * currentAsset;
	id <ZoozzResourcesLoaderDelegate> delegate;
}

@property (nonatomic,retain) NSMutableArray * assets;
@property (nonatomic,retain) Asset * currentAsset;
@property (nonatomic,retain) id<ZoozzResourcesLoaderDelegate> delegate;

- (void)pushResources:(NSArray *)resources;
- (void)process;


@end

@protocol ZoozzResourcesLoaderDelegate<NSObject>
- (void)resourceLoaded:(Asset*)asset;
@end