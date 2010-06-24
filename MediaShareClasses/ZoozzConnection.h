//
//  ZoozzConnection.h
//  IMBooster
//
//  Created by Roee Kremer on 11/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZoozzConnectionDelegate;

enum {
    ZoozzLogin = 1,
	ZoozzAuthenticateTransaction = 2,
	ZoozzAuthenticateTrial = 3,
    ZoozzLibrary = 4,
	ZoozzAsset = 5,
	ZoozzEvents = 6,
};

typedef NSUInteger ZoozzRequestType; 


enum {
	HTTPStatusCodeOK = 200,
	HTTPStatusCodeNoContent = 204,
	HTTPStatusCodeNotModified = 304,
	HTTPStatusForbidden = 403, // can be recieved on library and assets
	HTTPStatusCodeNotFound = 404,
	HTTPStatusCodeInternalServerError = 500
};

typedef NSUInteger HTTPStatusCode;

	

@interface ZoozzConnection : NSObject {
	id <ZoozzConnectionDelegate> delegate;
	NSMutableData *receivedData;
	NSDate *lastModified;
	NSMutableURLRequest *request;
	ZoozzRequestType requestType;
	NSHTTPURLResponse *theResponse;
	
	NSURLConnection *theConnection;
	
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSDate *lastModified;
@property ZoozzRequestType requestType;
@property (nonatomic, retain) NSHTTPURLResponse * theResponse;
@property (nonatomic, retain) NSURLConnection *theConnection;
@property (nonatomic, retain) NSMutableURLRequest *request;


- (id)initWithRequestType:(NSUInteger)aRequestType withString:(NSString*)string delegate:(id<ZoozzConnectionDelegate>) theDelegate;
+ (NSDictionary *)requestHeaderWithSessionID:(NSString *)sid;
+ (NSDictionary *)requestLoginHeaderWithSessionID:(NSString *)sid withAPNToken:(NSString *)token;
- (void)cancel;

@end

@protocol ZoozzConnectionDelegate<NSObject>

- (void) connectionDidFail:(ZoozzConnection *)theConnection;
- (void) connectionDidFinish:(ZoozzConnection *)theConnection;

@end
