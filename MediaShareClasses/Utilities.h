//
//  Utilities.h
//  IMBooster
//
//  Created by Roee Kremer on 12/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

void NoInternetAlert();
void NoServerAlert();
void NoConnectionAlert();
BOOL isConnected();
void firstLaunchAlert();

void URLCacheAlertWithError(NSError *error);
void URLCacheAlertWithMessage(NSString *message);
void URLCacheAlertWithMessageAndDelegate(NSString *message, id delegate);

void enableEmoji();

void alert(NSString *title,NSString* message);

NSData* encode(const uint8_t* input,NSInteger length);

NSData *convertToHex(NSData *deviceToken);

NSString* encodeToken(NSString * str,uint8_t number);