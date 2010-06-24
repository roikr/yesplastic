//
//  LocalStorage.h
//  PropertyListExample
//
//  Created by Roee Kremer on 11/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Asset;
@interface LocalStorage : NSObject<NSCoding> {
	BOOL backgroundLoad;
	NSArray *parsedAssets;
	NSMutableArray *unzippedAssets;
	NSArray *soundSets;
	
	NSMutableDictionary * assetsByName;
	NSMutableDictionary * assetsByIdentifier;
	
	
	
	NSString *sessionID;
	NSString *libraryDate;
	NSString *message;
	NSInteger tokenNumber;
	BOOL firstLaunch;
	BOOL cookieInstalled;
	BOOL tried;
	NSString *purchases;
	
	NSMutableArray *events;
	
	BOOL bLoggedIn;
	NSString *APNToken;
}

@property (retain, nonatomic) NSString * sessionID;
@property (retain, nonatomic) NSString * libraryDate;
@property (retain, nonatomic) NSString *message;
@property NSInteger tokenNumber;
@property BOOL firstLaunch;
@property BOOL cookieInstalled;
@property BOOL tried;
@property (retain, nonatomic) NSString * purchases;
@property (retain, nonatomic) NSMutableArray *events;

@property BOOL backgroundLoad;
@property (nonatomic ,retain) NSArray *parsedAssets;
@property (nonatomic, retain) NSMutableArray *unzippedAssets;
@property (nonatomic, retain) NSArray *soundSets;
@property (nonatomic, retain) NSMutableDictionary * assetsByName;
@property (nonatomic, retain) NSMutableDictionary * assetsByIdentifier;

@property BOOL bLoggedIn;
@property (nonatomic, retain) NSString *APNToken;


+ (LocalStorage*) localStorage;
+ (void)unzipPrecache;
- (void)arrangeAssets:(NSArray *)assets;
- (NSString *)token;
//- (void)removeAssets;
- (BOOL)archive;
+ (void)delete;
//- (NSArray *)productAssetsWithIdentifier:(NSString *)identifier;

- (BOOL)doesAssetUnzipped:(Asset *)asset;
- (void)unzipAsset:(Asset *)asset;

@end
