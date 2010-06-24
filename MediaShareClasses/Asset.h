#import <Foundation/Foundation.h>
#import "CacheResource.h"



@interface Asset : NSObject{
@protected   
	NSString *identifier;
	CacheResourceType contentType;
	NSString * originalID;
	
}

@property (nonatomic, retain) NSString *identifier;
@property CacheResourceType	contentType;
@property (nonatomic, retain) NSString *originalID;


-(id) initWithIdentifier:(NSString *)aid withOriginalID:(NSString *)oid;

//- (void)copyResources;

@end