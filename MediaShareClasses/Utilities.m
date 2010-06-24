//
//  Utilities.m
//  IMBooster
//
//  Created by Roee Kremer on 12/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Utilities.h"
#import <SystemConfiguration/SystemConfiguration.h>
//#import <sys/socket.h>
#import <netinet/in.h>
//#import "ZoozzMacros.h"
//#import <netinet6/in6.h>
//#import <arpa/inet.h>
//#import <ifaddrs.h>
//#import <netdb.h>


BOOL isConnected() {
	BOOL retVal = NO;
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
	
	
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
	if(reachability!= NULL)
	{
		SCNetworkReachabilityFlags flags;
		if (SCNetworkReachabilityGetFlags(reachability, &flags)) 
			retVal = flags & kSCNetworkReachabilityFlagsReachable;
	}
	
	if(reachability!= NULL)
		CFRelease(reachability);
	
	
	return retVal;
}



void NoInternetAlert()
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NoInternetTitle",@"No internet connection title") message:NSLocalizedString(@"NoInternetMessage",@"No Internet Connection message") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	[alertView release];	
}


void NoServerAlert()
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NoServerTitle",@"No connection to the server ") message:NSLocalizedString(@"NoServerMessage",@"Oops, our server can't be reached right now, please try again soon.") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	[alertView release];	
}

void NoConnectionAlert()
{
	if (isConnected()) {
		NoServerAlert();
	}
	else {
		NoInternetAlert();
	}
}

void firstLaunchAlert()
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WelcomeTitle",@"Welcome to IMBooster Lite Edition") message:NSLocalizedString(@"WelcomeMessage",@"You can get more content any time by downloading the full version.") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	[alertView release];	
}

void URLCacheAlertWithError(NSError *error)
{
    NSString *message = [NSString stringWithFormat:@"Error! %@ %@",
						 [error localizedDescription],
						 [error localizedFailureReason]];
	
	URLCacheAlertWithMessage (message);
}


void URLCacheAlertWithMessage(NSString *message)
{
	/* open an alert with an OK button */
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
													message:message
												   delegate:nil 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles: nil];
	[alert show];
	[alert release];
}


void URLCacheAlertWithMessageAndDelegate(NSString *message, id delegate)
{
	/* open an alert with OK and Cancel buttons */
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"URLCache" 
													message:message
												   delegate:delegate 
										  cancelButtonTitle:@"Cancel" 
										  otherButtonTitles: @"OK", nil];
	[alert show];
	[alert release];
}


void alert(NSString *title,NSString* message) {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title 
													message:message
												   delegate:nil 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles: nil];	
	[alert show];
	[alert release];
}

void enableEmoji() {
	NSMutableDictionary* plistDict = [NSMutableDictionary dictionaryWithContentsOfFile:@"/private/var/mobile/Library/Preferences/com.apple.Preferences.plist"];
	//ZoozzLog(@"write prefs:\%@",[plistDict description]);
	NSNumber *emoji = [plistDict valueForKey:@"KeyboardEmojiEverywhere"];
	//ZoozzLog(@"%@",[emoji description]);
	
	if (![emoji boolValue]) {
		[plistDict setValue:[NSNumber numberWithBool:YES] forKey:@"KeyboardEmojiEverywhere"];
		[plistDict writeToFile:@"/private/var/mobile/Library/Preferences/com.apple.Preferences.plist" atomically:YES];
	}
	 
	//ZoozzLog(@"write prefs:\%@",[plistDict description]);
	
}


// encoding token for sessionID 

unsigned char cycleChar(unsigned char ch ,int n){
	
	for (int i=0;i<n % 16;i++)
		switch (ch) {
			case 57:
				ch = 65;
				break;
			case 70:
				ch = 48;
				break;
			default:
				ch++;
				break;
		}
	
	
	return ch;
}

unsigned char hexDigit(int n) {
	return n<10 ? n+48 : n+55;	
}

NSString* encodeToken(NSString * str,uint8_t number)
{
	NSData * srcData = [str dataUsingEncoding:NSASCIIStringEncoding];
	int length = [srcData length];
	const uint8_t* input = [srcData bytes];
	NSMutableData* data = [NSMutableData dataWithLength:length+2];
    uint8_t* output = (uint8_t*)data.mutableBytes;
	
	int i;
	
	for (i=0; i<length; i++) {
		uint8_t src = input[i];
		uint8_t res = cycleChar(src,number);
		int j = 1+(i+number+1)%length;
        output[j ] = res;
	}
	
	output[0] = hexDigit(number / 16);
	output[length+1] = hexDigit(number % 16);
	//ZoozzLog(@"%@",[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
	
    return  [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
}




NSData* encode(const uint8_t* input,NSInteger length)
{
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
	
    for (NSInteger i = 0; i < length; i += 3) {
		NSInteger value = 0;
        for (NSInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        NSInteger index = (i / 3) * 4;
        output[index + 0] =                    table[(value >> 18) & 0x3F];
        output[index + 1] =                    table[(value >> 12) & 0x3F];
        output[index + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[index + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
	
    return  [NSData dataWithData:data];
}



NSData *convertToHex(NSData *deviceToken) {
	//ZoozzLog(@"remote notification token: %s, length: %i",input,length);
	//NSData *data = [NSData dataWithBytes:input length:length];
	//ZoozzLog(@"description: %@",[data description]);
	static char table[] = "0123456789ABCDEF";

	const uint8_t* input = (const uint8_t*)[deviceToken bytes];
	NSMutableData* data = [NSMutableData dataWithLength: 2*[deviceToken length]];
	uint8_t* output = (uint8_t*)data.mutableBytes;
	
    for (NSInteger i = 0; i < [deviceToken length]; i ++) {
		NSInteger value = input[i];
		output[2*i + 0] =   table[(value >> 4) & 0xf];
		output[2*i + 1] =   table[value & 0xf];
        
	}
	
    return [NSData dataWithData:data];
}


