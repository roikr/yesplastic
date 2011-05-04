//
//  MilgromMacros.h
//  
//
//  Created by Roee Kremer on 8/101/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#ifdef _Debug
#define _SETTINGS
#endif

#ifdef _Debug
#define MilgromLog( s, ... ) \
do { \
NSLog( @"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] ); \
} \
while (0)
#else
#define MilgromLog( s, ... ) do {} while (0)
#endif

//NSLog( @"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] ); \

