//
//  ZoozzConnection.m
//  IMBooster
//
//  Created by Roee Kremer on 11/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ZoozzConnection.h"
#import "LocalStorage.h"
#import "ZoozzConstants.h"
#import "ZoozzMacros.h"
// This framework was imported so we could use the kCFURLErrorNotConnectedToInternet error code.
#import <CFNetwork/CFNetwork.h>

@implementation ZoozzConnection

@synthesize delegate;
@synthesize receivedData;
@synthesize lastModified;
@synthesize request;
@synthesize requestType;
@synthesize theResponse;
@synthesize theConnection;

- (id)initWithRequestType:(NSUInteger)aRequestType withString:(NSString*)string delegate:(id<ZoozzConnectionDelegate>) theDelegate
{
	if (self = [super init]) {
		
		self.delegate = theDelegate;
		self.requestType = aRequestType;
		
		switch (requestType) {
			case ZoozzLogin: 
			case ZoozzAuthenticateTransaction:
			case ZoozzAuthenticateTrial: {
				self.request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[kZoozzSecuredURL stringByAppendingPathComponent:@"authenticate"]] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5];
				
				if (requestType == ZoozzLogin) {
					[request setAllHTTPHeaderFields:[ZoozzConnection requestLoginHeaderWithSessionID:[LocalStorage localStorage].sessionID withAPNToken:[LocalStorage localStorage].APNToken]];
				}
				else {
					[request setAllHTTPHeaderFields:[ZoozzConnection requestHeaderWithSessionID:[LocalStorage localStorage].sessionID]];
				}
				
				[request setHTTPMethod:@"POST"];
				[request addValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
				
				ZoozzLog(requestType == ZoozzLogin ? @"authenticate" : requestType == ZoozzAuthenticateTransaction ? @"authenticateTransactions" :  @"authenticateTrial");
				
				if (string) // purchases
					[request setHTTPBody:[string dataUsingEncoding:NSASCIIStringEncoding]];
				
			} break;
			case ZoozzLibrary: {
				self.request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[kZoozzSecuredURL stringByAppendingPathComponent:@"library"]] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5];
				NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:[ZoozzConnection requestHeaderWithSessionID:[LocalStorage localStorage].sessionID]];
				NSString * date = [LocalStorage localStorage].libraryDate;
				if (date) 
					[dict setObject:date forKey:@"If-Modified-Since"];
				[request setAllHTTPHeaderFields:dict]; 
				[request setHTTPMethod:@"GET"];
				
			} break;
			case ZoozzAsset: {
				
				self.request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",kZoozzSecuredURL,string]] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5];
				[request setAllHTTPHeaderFields:[ZoozzConnection requestHeaderWithSessionID:[LocalStorage localStorage].sessionID]]; 
				[request setHTTPMethod:@"GET"];
				ZoozzLog(@"ZoozzConnection: %@\n%@",[request URL],[[request allHTTPHeaderFields] description]);
				
			} break;
				
			case ZoozzEvents: {
				self.request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:
							[kZoozzSecuredURL stringByAppendingPathComponent:@"events"]] 
								cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5];
				[request setAllHTTPHeaderFields:[ZoozzConnection requestHeaderWithSessionID:[LocalStorage localStorage].sessionID]];
				[request setHTTPMethod:@"POST"];
				[request addValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
				
				if (string) // events
					[request setHTTPBody:[string dataUsingEncoding:NSASCIIStringEncoding]];
			}
			
							
			default:
				break;
		}
		
		if (requestType != ZoozzAsset) {
			NSString * body = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSASCIIStringEncoding];
			ZoozzLog(@"ZoozzConnection:%@\nheader: %@\nbody: %@",[request URL],[[request allHTTPHeaderFields] description],body);
			[body release];
		}
		
		
		/* create the NSMutableData instance that will hold the received data */
		receivedData = [[NSMutableData alloc] initWithLength:0];
		
		/* Create the connection with the request and start loading the
		 data. The connection object is owned both by the creator and the
		 loading system. */
		
		if (requestType!=ZoozzAsset && requestType!=ZoozzEvents) {
			[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		}
		
		self.theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
		
		if (theConnection == nil) {
			[self.delegate connectionDidFail:self];
			
			/* inform the user that the connection failed
			 NSString *message = NSLocalizedString (@"Unable to initiate request.", 
			 @"NSURLConnection initialization method failed.");
			 URLCacheAlertWithMessage(message);
			 */
		}
		
		
				
	}
	
	return self;
}


+ (NSDictionary *)requestLoginHeaderWithSessionID:(NSString *)sid withAPNToken:(NSString *)token		 
{
	NSURL * url = [NSURL URLWithString:kZoozzSecuredURL];
	
	NSMutableArray * arr = [NSMutableArray arrayWithObjects:
							[NSHTTPCookie cookieWithProperties:[NSDictionary dictionaryWithObjectsAndKeys: @"login",NSHTTPCookieName,@"1",NSHTTPCookieValue,[url host],NSHTTPCookieDomain,url,NSHTTPCookieOriginURL,@"/",NSHTTPCookiePath,nil]],
							[NSHTTPCookie cookieWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:@"avid",NSHTTPCookieName,kAppVersionID,NSHTTPCookieValue,[url host],NSHTTPCookieDomain,url,NSHTTPCookieOriginURL,@"/",NSHTTPCookiePath,nil]],
							[NSHTTPCookie cookieWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:@"didfr",NSHTTPCookieName,[[UIDevice currentDevice] uniqueIdentifier],NSHTTPCookieValue,[url host],NSHTTPCookieDomain,url,NSHTTPCookieOriginURL,@"/",NSHTTPCookiePath,nil]],
							[NSHTTPCookie cookieWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:@"lang",NSHTTPCookieName,[[NSLocale preferredLanguages] objectAtIndex:0] ,NSHTTPCookieValue,[url host],NSHTTPCookieDomain,url,NSHTTPCookieOriginURL,@"/",NSHTTPCookiePath,nil]],
							[NSHTTPCookie cookieWithProperties:[NSDictionary dictionaryWithObjectsAndKeys: @"loc",NSHTTPCookieName,[[NSLocale currentLocale] localeIdentifier],NSHTTPCookieValue,[url host],NSHTTPCookieDomain,url,NSHTTPCookieOriginURL,@"/",NSHTTPCookiePath,nil]],
							nil];
	
	if (sid) 
		[arr addObject:[NSHTTPCookie cookieWithProperties:[NSDictionary dictionaryWithObjectsAndKeys: @"sid",NSHTTPCookieName,sid,NSHTTPCookieValue,[url host],NSHTTPCookieDomain,url,NSHTTPCookieOriginURL,@"/",NSHTTPCookiePath,nil]]];
	
	if (token) 
		[arr addObject:[NSHTTPCookie cookieWithProperties:[NSDictionary dictionaryWithObjectsAndKeys: @"apnt",NSHTTPCookieName,token,NSHTTPCookieValue,[url host],NSHTTPCookieDomain,url,NSHTTPCookieOriginURL,@"/",NSHTTPCookiePath,nil]]];
	
	
	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
	if (version)
		[arr addObject:[NSHTTPCookie cookieWithProperties:[NSDictionary dictionaryWithObjectsAndKeys: @"v",NSHTTPCookieName,version,NSHTTPCookieValue,[url host],NSHTTPCookieDomain,url,NSHTTPCookieOriginURL,@"/",NSHTTPCookiePath,nil]]];
	
	//ZoozzLog([arr description]);
	
	return [NSHTTPCookie requestHeaderFieldsWithCookies:arr];
}

+ (NSDictionary *)requestHeaderWithSessionID:(NSString *)sid				 
{
	NSURL * url = [NSURL URLWithString:kZoozzSecuredURL];
	
	NSMutableArray * arr = [NSMutableArray arrayWithObjects:
							[NSHTTPCookie cookieWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:@"avid",NSHTTPCookieName,kAppVersionID,NSHTTPCookieValue,[url host],NSHTTPCookieDomain,url,NSHTTPCookieOriginURL,@"/",NSHTTPCookiePath,nil]],
							[NSHTTPCookie cookieWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:@"didfr",NSHTTPCookieName,[[UIDevice currentDevice] uniqueIdentifier],NSHTTPCookieValue,[url host],NSHTTPCookieDomain,url,NSHTTPCookieOriginURL,@"/",NSHTTPCookiePath,nil]],
							nil];
	
	if (sid) 
		[arr addObject:[NSHTTPCookie cookieWithProperties:[NSDictionary dictionaryWithObjectsAndKeys: @"sid",NSHTTPCookieName,sid,NSHTTPCookieValue,[url host],NSHTTPCookieDomain,url,NSHTTPCookieOriginURL,@"/",NSHTTPCookiePath,nil]]];
	
	//ZoozzLog([arr description]);
	
	return [NSHTTPCookie requestHeaderFieldsWithCookies:arr];
}



#pragma mark NSURLConnection delegate methods

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    /* This method is called when the server has determined that it has
	 enough information to create the NSURLResponse. It can be called
	 multiple times, for example in the case of a redirect, so each time
	 we reset the data. */
	
    [self.receivedData setLength:0];
	
	/* Try to retrieve last modified date from HTTP header. If found, format  
	 date so it matches format of cached image file modification date. */
	
	if ([response isKindOfClass:[NSHTTPURLResponse self]]) {
		self.theResponse = (NSHTTPURLResponse*)response;
		NSDictionary *headers = [theResponse allHeaderFields];
		NSInteger statusCode = [theResponse statusCode];
		
		if (requestType==ZoozzLogin && ( statusCode==HTTPStatusCodeOK || statusCode == HTTPStatusCodeNoContent)) {
			if (![LocalStorage localStorage].bLoggedIn) {
				[LocalStorage localStorage].bLoggedIn = YES;
				
				NSArray * arr = [NSHTTPCookie cookiesWithResponseHeaderFields:headers forURL:nil];
				for (NSHTTPCookie * cookie in arr) {
					//ZoozzLog([cookie name]);
					if ([cookie.name isEqualToString:@"sid"]) {
						[LocalStorage localStorage].sessionID=[cookie value];
						[LocalStorage localStorage].tokenNumber = 1;
						[[LocalStorage localStorage] archive];
						break;
						
					}
				}
			}
			
		}
		
		switch (requestType) {
			case ZoozzLogin: 
			case ZoozzAuthenticateTransaction:
			case ZoozzAuthenticateTrial: {
				ZoozzLog(@"didReceiveResponse ZoozzLogin / ZoozzAuthenticateTransactions / ZoozzAuthenticateTrial - statusCode: %u\n%@",statusCode,[headers description]);
			} break;
			case ZoozzLibrary: {
				ZoozzLog(@"didReceiveResponse ZoozzLibrary - statusCode: %u\n%@",statusCode,[headers description]);	
			} break;
			case ZoozzAsset: {
				//if (statusCode!=HTTPStatusCodeOK) 
					ZoozzLog(@"didReceiveResponse ZoozzAsset - statusCode: %u\n%@",statusCode,[headers description]);
			} break;
			default:
				break;
		}
	}
}


- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    /* Append the new data to the received data. */
    [self.receivedData appendData:data];
}

// Handle errors in the download or the parser by showing an alert to the user. This is a very simple way of handling the error,
// partly because this application does not have any offline functionality for the user. Most real applications should
// handle the error in a less obtrusive way and provide offline functionality to the user.
- (void)handleError:(NSError *)error {
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NSURLConnection Error", @"Title for alert displayed when download or parse error occurs.") message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	/*
	//URLCacheAlertWithError(error); // roikr I don't want allerts
	if ([error code] == kCFURLErrorNotConnectedToInternet) {
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"No Internet Connection",@"Error message displayed when not connected to the Internet.") forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain code:kCFURLErrorNotConnectedToInternet userInfo:userInfo];
        [self handleError:noConnectionError];
    } else {
        // otherwise handle the error generically
        [self handleError:error];
    }
	 */
	ZoozzLog(@"ZoozzConnection didFailWithError: %@, code: %i, domain: %@",[error localizedDescription],[error code],[error domain]);
	
	if (requestType!=ZoozzAsset && requestType!=ZoozzEvents) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
	
	[connection release];
	self.theConnection = nil;

	if (requestType==ZoozzAsset && [error code] == NSURLErrorTimedOut) {
		self.theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	}
		
	if (theConnection == nil) {
		[self.delegate connectionDidFail:self];
	}
}


- (NSCachedURLResponse *) connection:(NSURLConnection *)connection 
				   willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
	/* this application does not use a NSURLCache disk or memory cache */
    return nil;
}


- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
	
	if (requestType!=ZoozzAsset && requestType!=ZoozzEvents) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
	
	NSInteger statusCode = [theResponse statusCode];
	
		
	switch (statusCode) {
		case HTTPStatusCodeNotFound: {
			ZoozzLog(@"connectionDidFinishLoading - HTTPStatusCodeNotFound");
			[self.delegate connectionDidFail:self];
			return;
		} break;
		case HTTPStatusCodeInternalServerError: {
			ZoozzLog(@"connectionDidFinishLoading - HTTPStatusCodeInternalServerError");
			if ([receivedData length]) {
				NSString *dataString = [[NSString alloc] initWithData:receivedData encoding:NSASCIIStringEncoding];
				ZoozzLog(@"%@",dataString);
				[dataString release];
			}
			[self.delegate connectionDidFail:self];
			[connection release];
			self.theConnection = nil;
			return;
		} break;
		default:
			break;
	}
	 
	[self.delegate connectionDidFinish:self];
	[connection release];
	self.theConnection = nil;
	
}

- (void)cancel {
	if (theConnection) {
		[theConnection cancel];
		[theConnection release];
		self.theConnection = nil; 
	}
}

- (void)dealloc {
	if (theConnection) {
		[theConnection cancel];
	}
	[receivedData release];
	[lastModified release];
	[theResponse release];
	[request release];
	[super dealloc];
}
@end
