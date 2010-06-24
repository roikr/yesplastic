//
//  CacheResource.m
//  IMBooster
//
//  Created by Roee Kremer on 11/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CacheResource.h"
#import "ZoozzConnection.h"
#import "LocalStorage.h"
#import "ZoozzConstants.h"
#import "ZoozzMacros.h"


@interface CacheResource (PrivateMethods)

@end

@implementation CacheResource

@synthesize delegate;
@synthesize filePath;
@synthesize resourceType;
@synthesize connection;
@synthesize identifier;
@synthesize transaction;

- (id) initWithResouceType:(CacheResourceType)aResourceType withObject:(id)object delegate:(id<CacheResourceDelegate>)theDelegate {
	if (self = [super init]) {
		self.delegate = theDelegate;
		resourceType = aResourceType;
		
		switch (resourceType) {
			case CacheResourceLibrary:
				self.transaction = object;
				break;
			case CacheResourceAsset:
				self.identifier = object;
				break;
			default:
				break;
		}
		
		
		
		NSString *relativePath = [CacheResource resourceRelativePathWithResourceType:aResourceType WithIdentifier:identifier];
		
				
		self.filePath = [CacheResource cacheResourcePathWithResourceType:aResourceType WithIdentifier:identifier];
		
		switch (resourceType) {
			case CacheResourceLibrary:
				self.connection = [[ZoozzConnection alloc] initWithRequestType:ZoozzLibrary withString:nil delegate:self];
				break;
			case CacheResourceAsset:
				self.connection = [[ZoozzConnection alloc] initWithRequestType:ZoozzAsset withString:relativePath delegate:self];
				break;
				
			default:
				
				break;
		}
		
	}
	
	return self;
}


/*
+ (void) copyWithResourceType:(CacheResourceType)aResourceType withIdentifier:(NSString*)identifier {
		
	NSString * precache = [CacheResource preCacheResourcePathWithResourceType:aResourceType WithIdentifier:identifier];	
	
	if (precache) {
		
		NSString * cache = [CacheResource cacheResourcePathWithResourceType:aResourceType WithIdentifier:identifier];
		
		
		if ([[NSFileManager defaultManager] fileExistsAtPath:cache]) {
			NSError * error = nil;
			if (![[NSFileManager defaultManager] removeItemAtPath:cache error:&error]) {
				//URLCacheAlertWithError(error);
				ZoozzLog(@"delete cached failed");
			}
			//ZoozzLog(@"precache asset at: %@ copied to: %@",cache,filePath);
			//ZoozzLog(@"precache asset to: %@",cache);
		}
		
		
		
		if (![[NSFileManager defaultManager] fileExistsAtPath:cache]) {
			NSError * error = nil;
			if (![[NSFileManager defaultManager] copyItemAtPath:precache toPath:cache error:&error]) {
				//URLCacheAlertWithError(error);
				ZoozzLog(@"precache failed");
			}
			//ZoozzLog(@"precache asset at: %@ copied to: %@",cache,filePath);
			//ZoozzLog(@"precache asset to: %@",cache);
		}
		 
	}
}
*/

+ (NSString*)resourceRelativePathWithResourceType:(CacheResourceType)aResourceType WithIdentifier:(NSString *)identifier {
	NSString *relativePath = nil;
	
	switch (aResourceType) {
		case CacheResourceLibrary:
			break;
		
		default:
			relativePath = [@"content" stringByAppendingPathComponent:identifier];
			break;
	}
	
	return relativePath;
	
}

/*
+ (NSString*)preCacheResourcePathWithResourceType:(CacheResourceType)aResourceType WithIdentifier:(NSString *)identifier {
	NSString * precache = nil;	
	NSBundle *bundle = [NSBundle mainBundle];
	if (bundle) 
	{
		switch (aResourceType) {
			case CacheResourceLibrary:
				precache = [bundle pathForResource:@"library" ofType:@"xml" inDirectory:@"precache"];
				break;
			case CacheResourceAsset:
				precache = [bundle pathForResource:identifier ofType:@"zip" inDirectory:@"precache"];
				break;
			default:
				
				break;
		}
		
	}
	
	return precache;
}
 */

+ (NSString*)cacheResourcePathWithResourceType:(CacheResourceType)aResourceType WithIdentifier:(NSString *)identifier {
	NSString * theFilePath = nil;
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	switch (aResourceType) {
		case CacheResourceLibrary:
			theFilePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"data/library.xml"];
			break;
		
		case CacheResourceAsset:
			theFilePath = [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"cache"] stringByAppendingPathComponent:[identifier stringByAppendingPathExtension:@"zip"]];
			//ZoozzLog(@"requesting zip: %@",identifier);
			break;
		default:
			break;
	}
	
	return theFilePath;
}



+ (BOOL) doesAssetCachedWithResourceType:(CacheResourceType)aResourceType withIdentifier:(NSString*)identifier {
	
	NSString * theFilePath = [CacheResource cacheResourcePathWithResourceType:aResourceType WithIdentifier:identifier];
		
	return  [[NSFileManager defaultManager] fileExistsAtPath:theFilePath];
	
}





/*
 ------------------------------------------------------------------------
 URLCacheConnectionDelegate protocol methods
 ------------------------------------------------------------------------
 */

#pragma mark -
#pragma mark ZoozzConnectionDelegate methods

- (void) connectionDidFail:(ZoozzConnection *)theConnection
{	
	
	
	[self.delegate CacheResourceDidFailLoading:self];
	
	[connection release];
	self.connection = nil;
	
}


- (void) connectionDidFinish:(ZoozzConnection *)theConnection
{	
	
	NSInteger statusCode = [theConnection.theResponse statusCode];
	
	switch (theConnection.requestType) {
			
			
		case ZoozzLibrary: {
			switch (statusCode) {
				case HTTPStatusCodeOK:
					ZoozzLog(@"CacheResource - connectionDidFinish - library loaded");
					NSString *dataString = [[NSString alloc] initWithData:theConnection.receivedData encoding:NSASCIIStringEncoding];
					ZoozzLog(@"%@",dataString);
					[dataString release];
					break;
				case HTTPStatusCodeNotModified:
					ZoozzLog(@"CacheResource - connectionDidFinish - library did not modified");
					break;
					
					
				default:
					break;
			}
			
		} break;
			
			/*
			 case ZoozzAsset: {
			 switch (statusCode) {
			 case HTTPStatusCodeOK:
			 ZoozzLog(@"connectionDidFinish - ZoozzAsset: HTTPStatusCodeOK, data length: %u",[receivedData length]);
			 break;
			 default:
			 break;
			 }
			 
			 }
			 */
			
		default:
			break;
	}
	
	
	// the resource is cached if it is an asset or ( it is a new library )
	if (statusCode == HTTPStatusCodeOK) {
		[[NSFileManager defaultManager] createFileAtPath:filePath contents:theConnection.receivedData  attributes:nil];
		
		if (resourceType==CacheResourceLibrary) {
			NSString * date = [[theConnection.theResponse allHeaderFields] objectForKey:@"Z-Date"];
			
			[LocalStorage localStorage].libraryDate = date;
			[[LocalStorage localStorage] archive];
			ZoozzLog(@"CacheResource - connectionDidFinish - CacheResourceLibrary - Z-Date: %@",date);
		}
		
	}
	/*
	else if ([theConnection.theResponse statusCode] != HTTPStatusCodeNotModified) {
		if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] == YES) {
			NSError * error = nil;
			if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error]) {
				//URLCacheAlertWithError(error);
			}
		}
	}
	 */
	
	[self.delegate CacheResourceDidFinishLoading:self];
	
	[connection release];
	self.connection = nil;
	
}

- (void)cancel {
	if (connection) {
		[connection cancel];
		connection.delegate = nil;
		[connection release];
		self.connection = nil;
	}
}

- (void)dealloc {
	//no need to release connection because it released on its delegate ?
	if (connection) {
		connection.delegate = nil;
	}
	[filePath release];
	[identifier release];
	[transaction release];
	[super dealloc];
}

@end
