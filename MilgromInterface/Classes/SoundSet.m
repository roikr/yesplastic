#import "SoundSet.h"
#import "ZoozzMacros.h"

//#include <stdlib.h>





@implementation SoundSet

@synthesize bNew,bChanged;
@synthesize productIdentifier;
@synthesize purchaseID;
@synthesize bLocked;
@synthesize originalID;



-(id) initWithIdentifier:(NSString *)aid withProductIdentifier:(NSString *)pidfr 
		  withPurchaseID:(NSString *)pid withNew:(BOOL)assetNew withChanged:(BOOL)assetChanged withOriginalID:(NSString *)oid {

	if (self = [super init]) {
		
		self.productIdentifier = pidfr;
		self.purchaseID = pid;
		self.originalID = oid;
		bNew = assetNew;
		bChanged = assetChanged;
		bLocked = productIdentifier == nil ? NO : purchaseID == nil;
		
		//ZoozzLog(@"new asset - section: %u, category: %u, identifier: %@",sec,cat,identifier);
		//bThumbCached = [CacheResource doesAssetCachedWithResourceType:CacheResourceThumb withIdentifier:identifier];
		//bContentCached = [CacheResource doesAssetCachedWithResourceType:contentType withIdentifier:identifier];
		
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
	
	[productIdentifier release];
	[purchaseID release];
	[super dealloc];
	
   
}

@end