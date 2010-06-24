//
//  CacheResource.h
//  IMBooster
//
//  Created by Roee Kremer on 11/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZoozzConnection.h"

@protocol CacheResourceDelegate;

enum {
    CacheResourceLibrary = 1,
	CacheResourceAsset = 2
    
};
typedef NSUInteger CacheResourceType; 

@class SKPaymentTransaction;
@interface CacheResource : NSObject<ZoozzConnectionDelegate> {
//@private
	CacheResourceType resourceType;
	id <CacheResourceDelegate> delegate;
	NSString * filePath;
	ZoozzConnection *connection;
	NSString *identifier;
	SKPaymentTransaction *transaction;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) ZoozzConnection *connection;
@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) SKPaymentTransaction *transaction;

@property CacheResourceType resourceType;

+ (NSString*)resourceRelativePathWithResourceType:(CacheResourceType)aResourceType WithIdentifier:(NSString *)identifier;
//+ (NSString*)preCacheResourcePathWithResourceType:(CacheResourceType)aResourceType WithIdentifier:(NSString *)identifier;
+ (NSString*)cacheResourcePathWithResourceType:(CacheResourceType)aResourceType WithIdentifier:(NSString *)identifier;
//+ (void) copyWithResourceType:(CacheResourceType)aResourceType withIdentifier:(NSString*)identifier;
+ (BOOL) doesAssetCachedWithResourceType:(CacheResourceType)aResourceType withIdentifier:(NSString*)identifier;

- (id) initWithResouceType:(CacheResourceType)aResourceType withObject:(id)object delegate:(id<CacheResourceDelegate>)theDelegate;
- (void)cancel;
@end


@protocol CacheResourceDelegate<NSObject>
- (void)CacheResourceDidFinishLoading:(CacheResource *)cacheResource;
- (void)CacheResourceDidFailLoading:(CacheResource *)cacheResource;
@end
