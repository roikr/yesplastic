#import <Foundation/Foundation.h>
#import "Asset.h"
#import "CacheResource.h"



@interface SoundSet : Asset {
@private
   
	NSString * productIdentifier;
	NSString * purchaseID;
	
	BOOL bNew;
	BOOL bChanged;
	
	BOOL bLocked;
		
}

@property (nonatomic, retain) NSString *productIdentifier;
@property (nonatomic, retain) NSString *purchaseID;

@property BOOL bNew;
@property BOOL bChanged;

@property BOOL bLocked;



-(id) initWithIdentifier:(NSString *)aid withProductIdentifier:(NSString *)pidfr
			 withPurchaseID:(NSString *)pid withNew:(BOOL)assetNew withChanged:(BOOL)assetChanged withOriginalID:(NSString *)oid;

//- (void)copyResources;

@end