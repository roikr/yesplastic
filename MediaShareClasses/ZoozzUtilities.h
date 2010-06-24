//
//  ZoozzUtilities.h
//  YesPlastic
//
//  Created by Roee Kremer on 3/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ZoozzUtilities : NSObject {

}

+(void) NoInternetAlert;
+(void) NoServerAlert;
+(void) NoConnectionAlert;
+(BOOL) isConnected;
+(void) firstLaunchAlert;

+(void) URLCacheAlertWithError:(NSError *)error;
+(void) URLCacheAlertWithMessage:(NSString *)message;
+(void) URLCacheAlertWithMessageAndDelegate:(NSString )*message  withDelegate:(id)delegate;

+(void) enableEmoji();

+(void) alert:(NSString *)title withMessage:(NSString*) message;

+(NSData*) encode(const uint8_t* input,NSInteger length);

+(NSData*) convertToHex(NSData *deviceToken);

@end
