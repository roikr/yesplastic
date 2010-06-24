//
//  LocalStorage.m
//  PropertyListExample
//
//  Created by Roee Kremer on 11/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LocalStorage.h"
//#import "Asset.h"
//#import "Section.h"
//#import "Category.h"
#import "Utilities.h"
#import "ZoozzMacros.h"
#import "Asset.h"
#import "SoundSet.h"
#import "ZipArchive.h"

@implementation LocalStorage

@synthesize sessionID;
@synthesize libraryDate;
@synthesize tried;
@synthesize message;
@synthesize tokenNumber;
@synthesize firstLaunch;
@synthesize cookieInstalled;
@synthesize purchases;
@synthesize events;

@synthesize backgroundLoad;

@synthesize parsedAssets;
@synthesize unzippedAssets;
@synthesize soundSets;

@synthesize assetsByName;
@synthesize assetsByIdentifier;

@synthesize bLoggedIn;
@synthesize APNToken;


static LocalStorage *sharedLocalStorage = nil;


+ (void)unzipPrecache {
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	if (!documentsDirectory) {
		ZoozzLog(@"Documents directory not found!");
		return ;
	}
	
	
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:[documentsDirectory stringByAppendingPathComponent:@"data"]]) { // roikr: first time run check for release
		NSString * precache = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"zip" inDirectory:@"precache"];
		
		if (precache) {
			ZoozzLog(@"unzipping precache");
			
			ZipArchive *zip = [[ZipArchive alloc] init];
			[zip UnzipOpenFile:precache];
			[zip UnzipFileTo:[paths objectAtIndex:0] overWrite:YES];
			[zip UnzipCloseFile];
		} 
		/*
		else {
			NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"data"];
			NSError * error = nil;
			if (![[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]) {
				URLCacheAlertWithError(error);
				return;
			}
			
			
		}
		 */

		
	}
}

+ (LocalStorage*)localStorage
{
    if (sharedLocalStorage == nil) {
        
		
		NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
		
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString * dataPath = [documentsDirectory stringByAppendingPathComponent:@"cache"]; 
		NSError * error = nil;
		
#ifdef _SETTINGS
		if ([defaults boolForKey:@"clear_cache_identifier"]) 
		{
			/* removes every file in the cache directory */
			/* remove the cache directory and its contents */
			if (![[NSFileManager defaultManager] removeItemAtPath:dataPath error:&error]) {
				URLCacheAlertWithError(error);
				return nil;
			}
		}
			
#endif 
		
		/* check for existence of cache directory */
		if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
			if (![[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]) {
				URLCacheAlertWithError(error);
				return nil;
			}
		}
		
		/*	
		 if ([defaults boolForKey:@"delete_user_identifier"]) 
		 [LocalStorage delete];
		 */
		
		
		
				
		NSString *archivePath = [documentsDirectory stringByAppendingPathComponent:@"data/local"];
		NSData *data = [NSData dataWithContentsOfFile:archivePath];
		
		if (data) {
			sharedLocalStorage = [NSKeyedUnarchiver unarchiveObjectWithData:data];
			/*
			NSKeyedUnarchiver * unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
			// Customize unarchiver here
			[sharedLocalStorage initWithCoder:unarchiver];
			[unarchiver finishDecoding];
			[unarchiver release];
			 
			[[NSKeyedUnarchiver alloc] 
			 */
		} else {
			//sharedLocalStorage = [super allocWithZone:NULL];
			sharedLocalStorage = [[[LocalStorage alloc] init] autorelease];
		}

		
		
	
		
		
		//if (!retVal) 
		//	retVal= [[[self alloc] init] autorelease];
		
		
		
		/*
		 if ([defaults boolForKey:@"delete_sessionID_identifier"])
		 localStorage.sessionID = nil;
		 
		 if ([defaults boolForKey:@"delete_libraryDate_identifier"]) {
		 retVal.libraryDate = nil;
		 
		 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		 NSString *path= [[paths objectAtIndex:0] stringByAppendingPathComponent:@"URLCache"];
		 NSString * appFile = [path stringByAppendingPathComponent:@"library.xml"];
		 if ([[NSFileManager defaultManager] fileExistsAtPath:appFile]) {
		 NSError * error = nil;
		 if (![[NSFileManager defaultManager] removeItemAtPath:appFile error:&error]) 
		 ZoozzLog(@"can't delete %@: %@",appFile,[error localizedDescription]);
		 else
		 ZoozzLog(@"%@ deleted",appFile);
		 }
		 
		 }
		 *?
		 
		 /*
		 if ([defaults boolForKey:@"delete_tried_identifier"])
		 localStorage.tried = NO;
		 
		 if ([defaults boolForKey:@"delete_purchases_identifier"])
		 localStorage.purchases = nil;
		 */
		
		
    }
    return sharedLocalStorage;
}

/*
+ (id)allocWithZone:(NSZone *)zone
{
    return [[self localStorage] retain];
}
 */

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}



- (id)init {
	
	if (self = [super init]) {
		
		backgroundLoad = NO;
		tokenNumber = 1;
		firstLaunch = NO;
		cookieInstalled = NO;
		bLoggedIn = NO;
		self.unzippedAssets = [NSMutableArray array];
		//tried = NO;
	}
	return self;
}




- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
	if (self != nil) {
		self.sessionID = [coder decodeObjectForKey:@"sessionID"];
		self.libraryDate = [coder decodeObjectForKey:@"libraryDate"];
		self.message = [coder decodeObjectForKey:@"message"];
		self.tokenNumber = [coder decodeIntegerForKey:@"tokenNumber"];
		self.firstLaunch = [coder decodeBoolForKey:@"firstLaunch"];
		self.cookieInstalled = [coder decodeBoolForKey:@"cookieInstalled"];
		//self.tried = [coder decodeBoolForKey:@"tried"];
		self.purchases = [coder decodeObjectForKey:@"purchases"];
		//self.events	= [coder decodeObjectForKey:@"events"]; // doesn't archive events
		backgroundLoad = NO;
		self.unzippedAssets = [coder decodeObjectForKey:@"unzippedAssets"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.sessionID forKey:@"sessionID"];
	[coder encodeObject:self.libraryDate forKey:@"libraryDate"];
	[coder encodeObject:self.message forKey:@"message"];
	[coder encodeInteger:self.tokenNumber forKey:@"tokenNumber"];
	[coder encodeBool:self.firstLaunch forKey:@"firstLaunch"];
	[coder encodeBool:self.cookieInstalled forKey:@"cookieInstalled"];
	//[coder encodeBool:self.tried forKey:@"tried"];
	[coder encodeObject:self.purchases forKey:@"purchases"];
	[coder encodeObject:self.unzippedAssets forKey:@"unzippedAssets"];
	//[coder encodeObject:self.events forKey:@"events"]; // // doesn't archive events
}

- (void)dealloc
{
	[assetsByName release];
	[assetsByIdentifier release];
	[sessionID release];
	[message release];
	[purchases release];
	[parsedAssets release];
	[unzippedAssets release];
	[soundSets release];
	[events release];
	[super dealloc];
}


	
- (BOOL)archive {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"data/local"];
	return [NSKeyedArchiver archiveRootObject:self toFile:appFile];
}
	
	
	
+ (void)delete {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSError * error = nil;
	NSString * appFile = [documentsDirectory stringByAppendingPathComponent:@"data/local"];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:appFile]) {
		if (![[NSFileManager defaultManager] removeItemAtPath:appFile error:&error]) 
			ZoozzLog(@"can't delete %@: %@",appFile,[error localizedDescription]);
		else
			ZoozzLog(@"%@ deleted",appFile);
	}
	
}
	
	




/*
- (Page*)getPage:(NSUInteger)page withSection:(NSUInteger)sec {
	return nil;
}
 */



- (NSString *)token {
	ZoozzLog(@"create token for sessionID: %@",self.sessionID);
	if (self.sessionID== nil) 
		return nil;
	
	return encodeToken(self.sessionID,self.tokenNumber);
}







- (BOOL)doesAssetUnzipped:(Asset *)asset {
	
	NSUInteger i;
	
	for (i=0; i<[unzippedAssets count]; i++) {
		NSString *str = [[LocalStorage localStorage].unzippedAssets objectAtIndex:i];
		if ([asset.identifier isEqualToString:str])
			return YES;
		
	}
	return NO;
}

- (void)unzipAsset:(Asset *)asset {
	
	ZipArchive *zip = [[ZipArchive alloc] init];
	[zip UnzipOpenFile:[CacheResource cacheResourcePathWithResourceType:asset.contentType WithIdentifier:asset.identifier]];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	[zip UnzipFileTo:[paths objectAtIndex:0] overWrite:YES];
	[zip UnzipCloseFile];
	[unzippedAssets addObject:asset.identifier];
	[self archive];
	
	
	
}



- (void)arrangeAssets:(NSArray *)assets; {
	
	if (self.parsedAssets) {
		self.parsedAssets = nil;
	}
	
	if (self.soundSets) {
		self.soundSets = nil;
	}
	
	self.parsedAssets = [NSArray arrayWithArray:assets];
	
	NSMutableArray * sets = [NSMutableArray array];
	
	for (Asset * asset in parsedAssets) {
		if ([asset isKindOfClass:[SoundSet self]]) {
			[sets addObject:asset];
		}
	}
	
	self.soundSets = [NSArray arrayWithArray:sets];
	
	 
	/*
	self.sections = nil;
	self.assetsByUnichar = nil;
	self.assetsByIdentifier = nil;
	
	
	self.sections = [NSMutableArray array];
	self.assetsByUnichar = [NSMutableDictionary dictionaryWithCapacity:[assets count]];
	self.assetsByIdentifier = [NSMutableDictionary dictionaryWithCapacity:[assets count]];
	
	Section * section = [[Section alloc] init];
	[self.sections addObject:section];
	[section release];
	Category * category = [[Category alloc] init];
	[section.categories addObject:category];
	[category release];
	int sec = 0;
	int cat = 0;

	
	for (Asset * asset in assets) {
		
		if (asset.section>sec) {
			section = [[Section alloc] init];
			[sections addObject:section];
			[section release];
			category = [[Category alloc] init];
			[section.categories addObject:category];
			[category release];
			cat = 0;
			sec++;
		} else if (asset.category>cat) {
			category = [[Category alloc] init];
			[section.categories addObject:category];
			[category release];
			cat++;
		}
		
		//if (!asset.bLocked) 
		[section.assets addObject:asset];			
		
		[category.assets addObject:asset];
		[assetsByUnichar setObject:asset forKey:[NSString stringWithFormat:@"%u",asset.charCode]];
		[assetsByIdentifier setObject:asset forKey:asset.identifier];
		
		//Asset * asset = [assetsList objectAtIndex:ch-0xE900];
		
		//ZoozzLog(@"arrange asset - section: %u(%u), category: %u(%u), identifier: %@",asset.section,sec,asset.category,cat,asset.identifier);
		
	}
	
	ZoozzLog(@"arrangeAssets ended");
	*/
}
/*

- (NSArray *)productAssetsWithIdentifier:(NSString *)identifier {
	NSMutableArray *assets;
	assets = [NSMutableArray array];
	for (Section *sec in sections) {
		for (Category *cat in sec.categories) {
			for (Asset *asset in cat.assets) {
				if ([asset.productIdentifier isEqualToString:identifier]) {
					[assets addObject:asset];
				}
			}
		}
		
	}
				 
	return assets;
	
	
}
*/

/*
- (void)removeAssets{
	
	for (Section * section in self.sections) {
		[section.assets removeAllObjects];
		while ([section.categories count]) {
			Category * category = [section.categories lastObject];
			[category.assets removeAllObjects];
			[section.categories removeLastObject];
		}
	}
	 
	[self.sections removeAllObjects];
	
	
}



*/




@end
