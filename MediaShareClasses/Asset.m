#import "Asset.h"
#import "ZoozzMacros.h"

//#include <stdlib.h>


@implementation Asset


@synthesize identifier;
@synthesize originalID;
@synthesize contentType;



-(id) initWithIdentifier:(NSString *)aid withOriginalID:(NSString *)oid {

if (self = [super init]) {
		
		self.identifier = aid;
		contentType = CacheResourceAsset;
		self.originalID = oid;
	}
	return self;
}

/*
- (void)copyResources {
	
	[CacheResource copyWithResourceType:CacheResourceThumb withIdentifier:identifier];
	bThumbCached = [CacheResource doesAssetCachedWithResourceType:CacheResourceThumb withIdentifier:identifier];
	
	[CacheResource copyWithResourceType:contentType withIdentifier:identifier];
	bContentCached = [CacheResource doesAssetCachedWithResourceType:contentType withIdentifier:identifier];
}
*/

- (void)dealloc {
	[identifier release];
	[originalID release];
    [super dealloc];
}

@end