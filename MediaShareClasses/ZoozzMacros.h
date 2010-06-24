//
//  ZoozzMacros.h
//  IMBooster
//
//  Created by Roee Kremer on 1/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#define _DEVELOPMENT_SERVER
//#define _ADMOB

#ifdef _Debug
#define _SETTINGS
#endif

#ifdef _Debug
#define ZoozzLog( s, ... ) \
do { \
NSLog( @"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] ); \
} \
while (0)
#else
#define ZoozzLog( s, ... ) do {} while (0)
#endif

//NSLog( @"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] ); \

