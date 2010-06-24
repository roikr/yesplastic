//
//  ZoozzResourcesLoader.m
//  YesPlastic
//
//  Created by Roee Kremer on 3/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ZoozzResourcesLoader.h"
#import "CacheResource.h"
#import "LocalStorage.h"
#import "ZoozzMacros.h"
#import "Asset.h"


@implementation ZoozzResourcesLoader

@synthesize assets;
@synthesize currentAsset;
@synthesize delegate;


- (void)pushResources:(NSArray *)resources {
	if (assets) {
		self.assets= nil;
	}
	
	self.assets = [NSMutableArray array];
	
	for (Asset *asset in resources) {
		if ([CacheResource doesAssetCachedWithResourceType:asset.contentType withIdentifier:asset.identifier]) {
			if (![[LocalStorage localStorage] doesAssetUnzipped:asset]) {
				ZoozzLog(@"asset %@ allready downloaded but does not unzipped",[asset originalID]);
				[[LocalStorage localStorage] unzipAsset:asset];
				ZoozzLog(@"unzipping done");
			}
		} else {
			[assets addObject:asset];
		}

	}
}


- (void)process {
	if (!currentAsset && [assets count]>0) {
		self.currentAsset = [assets objectAtIndex:0];
		[assets removeObjectAtIndex:0];
		
		ZoozzLog(@"downloading asset: %@ (%@)",currentAsset.originalID,currentAsset.identifier);
		[[CacheResource alloc] initWithResouceType:currentAsset.contentType withObject:currentAsset.identifier delegate:self];
			
	}
	
}


- (void) dealloc {
	[assets release];
	[currentAsset release];
	[super dealloc];
}



#pragma mark CacheResource delegate methods

- (void)CacheResourceDidFailLoading:(CacheResource *)cacheResource {
	switch (cacheResource.resourceType) {
		
		case CacheResourceAsset: 
				//[cachingWinks removeObject:cacheResource];
			break;
			
		default:
			break;
	}
	
	
	ZoozzLog(@"ZoozzResourcesLoader - CacheResourceDidFailLoading");
	
	[cacheResource release];
}

- (void)CacheResourceDidFinishLoading:(CacheResource *)cacheResource {
	
	switch (cacheResource.resourceType) {
					
		case CacheResourceAsset: {
			[[LocalStorage localStorage] unzipAsset:currentAsset];
			if (delegate) {
				[delegate resourceLoaded:currentAsset];
			}
			self.currentAsset=nil;
			
			
		} break;
			
		default:
			break;
	}
	
	
	
	[cacheResource release];
}


@end
