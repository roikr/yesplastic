//
//  FacebookUploadController.m
//  FacebookUpload
//
//  Created by Roee Kremer on 9/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FacebookUploadController.h"
#import <CommonCrypto/CommonDigest.h>
#import "Facebook.h"


// Your Facebook APP Id must be set before running this example
// See http://www.facebook.com/developers/createapp.php
static NSString* kAppId = @"142588289117470";
static NSString* kApiKey = @"e06968ce5ad567d5685a8ebabfd63619";
static NSString* kAppSecret = @"05e64b714292c6405e111357e7110078";

enum  {
	FACEBOOK_NONE,
	FACEBOOK_PUBLISH_LINK,
	FACEBOOK_UPLOAD_VIDEO
};

@interface FacebookUploadController (PrivateMethods) 
- (void) login;
- (NSString *)hashForString:(NSString *)str;
@end

@implementation FacebookUploadController

@synthesize delegate;

- (id)initWithDelegate:(id<FacebookControllerDelegate>)theDelegate {
	
	if (self = [super init]) {
		self.delegate = theDelegate;
		_permissions =  [[NSArray arrayWithObjects: @"read_stream", @"offline_access",@"publish_stream",nil] retain];
		_facebook = [[Facebook alloc] init];
		
	}
	return self;
}

- (void) dealloc {
	[_facebook release];
	[_permissions release];
	[super dealloc];
}

/**
 * Example of facebook login and permission request
 */
- (void) login {
	[_facebook authorize:kAppId permissions:_permissions delegate:self];
}
	
/**
 * Example of facebook logout
 */
- (void) logout {
	[_facebook logout:self]; 
}

- (NSString *)hashForString:(NSString *)str {
	
	
	const char *cStr = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, strlen(cStr), result );
	
	
	return [NSString stringWithFormat:
			@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
			];
	
}

-(void)publish {
	if (![_facebook isSessionValid]) {
		state = FACEBOOK_PUBLISH_LINK;
		[self login];
	} else {
		NSLog(@"published");
		[delegate facebookControllerDidFinish:self];
	}

	
}


-(void) uploadVideo {
	if (![_facebook isSessionValid]) {
		return;
	}
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	
//	NSString *documentsDirectory = [paths objectAtIndex:0];
//	
//	if (!documentsDirectory) {
//		//MilgromLog(@"Documents directory not found!");
//		return;
//	}
//	
//	
//	
//	// load the file data
//	NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"video.mov"];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"IMG_0015" ofType:@"MOV"];
	
	NSData *data = [NSData dataWithContentsOfFile:path];
	
	//NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//									data, @"video",
//									nil];
	
	NSMutableDictionary * params = [NSMutableDictionary dictionary];
	
	[params setValue:kApiKey forKey:@"api_key"];
	[params setValue:[NSString stringWithFormat:@"%f",[NSDate timeIntervalSinceReferenceDate]*1000] forKey:@"call_id"];
	[params setValue:@"1.0" forKey:@"v"];
	[params setValue:@"facebook.video.upload" forKey:@"method"];
	[params setValue:@"test" forKey:@"title"];
	[params setValue:@"test desc" forKey:@"description"];
	
	
	NSArray *parts = [_facebook.accessToken componentsSeparatedByString:@"|"];
	[params setValue:[parts objectAtIndex:1] forKey:@"session_key"];
		
	
	
	NSArray *array = [NSArray arrayWithObjects:@"api_key",@"call_id",@"v",@"method",@"session_key",nil];
	
	NSString *builder = [NSString string];
	for (int i=0;i<[array count];i++) {
		builder = [builder stringByAppendingFormat:@"%@=%@",[array objectAtIndex:i],[params objectForKey:[array objectAtIndex:i]]];
	}
	
	builder = [builder stringByAppendingString:[parts objectAtIndex:2]];
	NSLog(@"builder: %@",builder);
	NSString * sig = [[self hashForString:builder] lowercaseString];
	
	NSLog(@"sig: %@",sig);
	
	[params setValue:sig forKey:@"sig"];
		
	[params setObject:data forKey:@"video"];
	
	[_facebook requestUploadVideoWithParams:params andDelegate: self]; 
}


/**
 * Callback for facebook login
 */ 
-(void) fbDidLogin {
	NSLog(@"logged in");
	
	switch (state) {
		case FACEBOOK_PUBLISH_LINK:
			[self publish];
			break;
		default:
			break;
	}
}

/**
 * Callback for facebook did not login
 */
- (void)fbDidNotLogin:(BOOL)cancelled {
	NSLog(@"did not login");
	[delegate facebookControllerDidFail:self];
}

/**
 * Callback for facebook logout
 */ 
-(void) fbDidLogout {
	NSLog(@"logged out");

}


///////////////////////////////////////////////////////////////////////////////////////////////////
// FBRequestDelegate

/**
 * Callback when a request receives Response
 */ 
- (void)request:(FBRequest*)request didReceiveResponse:(NSURLResponse*)response{
	NSLog(@"received response");
};

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest*)request didFailWithError:(NSError*)error{
	NSLog(@"request didFailWithError: %@",[error localizedDescription]);

};

/**
 * Called when a request returns and its response has been parsed into an object.
 * The resulting object may be a dictionary, an array, a string, or a number, depending
 * on thee format of the API response.
 */
- (void)request:(FBRequest*)request didLoad:(id)result {
	if ([result isKindOfClass:[NSArray class]]) {
		result = [result objectAtIndex:0]; 
	}
	if ([result objectForKey:@"owner"]) {
		NSLog(@"Video upload Success");
	} else {
		NSLog(@"request didLoad, owner: %@",[result objectForKey:@"name"]);
	}
};


@end
