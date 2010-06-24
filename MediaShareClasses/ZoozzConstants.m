//
//  ZoozzConstants.m
//  YesPlastic
//
//  Created by Roee Kremer on 3/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ZoozzConstants.h"
#import "ZoozzMacros.h"

#ifdef _DEVELOPMENT_SERVER
// DEVELOPMENT
NSString * const kZoozzHost=@"dev.zoozzmedia.com";
NSString * const kZoozzURL = @"http://dev.zoozzmedia.com";
NSString * const kZoozzSecuredURL = @"http://dev.zoozzmedia.com";

#else
// PRODUCTION
NSString * const kZoozzHost=@"imbooster.zoozzmedia.com";
NSString * const kZoozzURL = @"http://imbooster.zoozzmedia.com";
NSString * const kZoozzSecuredURL = @"https://imbooster.zoozzmedia.com";
#endif


NSString * const kUpgradeProductIdentifier = @"com.iminent.IMBoosterFree.UpgradeToIMBooster";


//#ifdef _YesPlastic 
NSString * const kAppVersionID = @"4";
NSString * const kZoozzAppID = @"339715267"; // paid
//#endif

#ifdef _YesPlasticPaid
NSString * const kAppVersionID = @"5";
NSString * const kZoozzAppID = @"339039054"; // free
#endif



