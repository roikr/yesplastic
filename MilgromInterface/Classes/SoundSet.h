#import <Foundation/Foundation.h>



@interface SoundSet:NSObject {
@private
   
	NSString * originalID;
	NSString * productIdentifier;
	NSString * purchaseID;
	
	BOOL bNew;
	BOOL bChanged;
	
	BOOL bLocked;
		
}

@property (nonatomic, retain) NSString *productIdentifier;
@property (nonatomic, retain) NSString *purchaseID;
@property (nonatomic, retain) NSString *originalID;

@property BOOL bNew;
@property BOOL bChanged;

@property BOOL bLocked;



-(id) initWithIdentifier:(NSString *)aid withProductIdentifier:(NSString *)pidfr
			 withPurchaseID:(NSString *)pid withNew:(BOOL)assetNew withChanged:(BOOL)assetChanged withOriginalID:(NSString *)oid;

//- (void)copyResources;

@end