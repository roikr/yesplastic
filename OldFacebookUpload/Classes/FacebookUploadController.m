//
//  FacebookUploadController.m
//  FacebookUpload
//
//  Created by Roee Kremer on 9/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FacebookUploadController.h"
#import <CommonCrypto/CommonDigest.h>



// Your Facebook APP Id must be set before running this example
// See http://www.facebook.com/developers/createapp.php
static NSString* kAppId = @"142588289117470";
static NSString* kApiKey = @"e06968ce5ad567d5685a8ebabfd63619";
static NSString* kApiSecret = @"05e64b714292c6405e111357e7110078";



@interface FacebookUploadController (PrivateMethods) 
- (void) requestPermission;

@end

@implementation FacebookUploadController

@synthesize delegate;
@synthesize session;
@synthesize videoName;
@synthesize path;

- (id)initWithDelegate:(id<FacebookControllerDelegate>)theDelegate {
	
	if (self = [super init]) {
		self.delegate = theDelegate;
		//_permissions =  [[NSArray arrayWithObjects: @"read_stream", @"offline_access",@"publish_stream",nil] retain];
		self.session = [FBSession sessionForApplication: kApiKey secret: kApiSecret delegate: self] ;
		
		
	}
	return self;
}

- (void) dealloc {
	[session release];
	[videoName release];
	[path release];
	[super dealloc];
}


	
- (void) requestPermission { // Ask for extended permissions
	FBPermissionDialog* dialog = [[[FBPermissionDialog alloc] init] autorelease];
	dialog.delegate = self;
	dialog.permission = @"publish_stream";
	[dialog show];
	
}



- (void) uploadVideoWithVideoName:(NSString *)theVideoName andPath:(NSString *)thePath {
	
	self.videoName = theVideoName;
	self.path = thePath;
	
	if (![session resume]) {
		// Show the login dialog
		FBLoginDialog* dialog = [[[FBLoginDialog alloc] init] autorelease];
		dialog.delegate = self;
		//m_FBDialogStage = 0;
		[dialog show];
	}
}



/**
 * Called when a user has successfully logged in and begun a session.
 */
- (void)session:(FBSession*)session didLogin:(FBUID)uid {
	NSLog(@"logged in"); 
	
	[self requestPermission];
}	



/**
 * Called when a user closes the login dialog without logging in.
 */
- (void)sessionDidNotLogin:(FBSession*)session {
	NSLog(@"did not login");
	[delegate facebookControllerDidFail:self];

}

/**
 * Called when a session is about to log out.
 */
- (void)session:(FBSession*)session willLogout:(FBUID)uid {
	NSLog(@"will log out");
}

/**
 * Called when a session has logged out.
 */
- (void)sessionDidLogout:(FBSession*)session {
	NSLog(@"logged out");
}


/**
 * Called when the dialog succeeds and is about to be dismissed.
 */
- (void)dialogDidSucceed:(FBDialog*)dialog {
	NSLog(@"dialogDidSucceed");
	if ([dialog isKindOfClass:[FBPermissionDialog class]]) {
		NSData *data = [NSData dataWithContentsOfFile:path];
		
		FBRequest *m_UploadRequest = [FBRequest requestWithSession: session delegate: self];
		
		NSMutableDictionary* Parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"video.upload", @"method", videoName, @"title", nil];
		[m_UploadRequest call: @"facebook.video.upload" params: Parameters dataParam: data];
	}
}

/**
 * Called when the dialog is cancelled and is about to be dismissed.
 */
- (void)dialogDidCancel:(FBDialog*)dialog {
	NSLog(@"dialogDidCancel");
	[delegate facebookControllerDidFail:self];
}

/**
 * Called when dialog failed to load due to an error.
 */
- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError*)error {
	NSLog(@"dialog didFailWithError");
	[delegate facebookControllerDidFail:self];
}

/**
 * Asks if a link touched by a user should be opened in an external browser.
 *
 * If a user touches a link, the default behavior is to open the link in the Safari browser, 
 * which will cause your app to quit.  You may want to prevent this from happening, open the link
 * in your own internal browser, or perhaps warn the user that they are about to leave your app.
 * If so, implement this method on your delegate and return NO.  If you warn the user, you
 * should hold onto the URL and once you have received their acknowledgement open the URL yourself
 * using [[UIApplication sharedApplication] openURL:].
 */
- (BOOL)dialog:(FBDialog*)dialog shouldOpenURLInExternalBrowser:(NSURL*)url {
	return NO;
}





///////////////////////////////////////////////////////////////////////////////////////////////////
// FBRequestDelegate

/**
 * Called just before the request is sent to the server.
 */
- (void)requestLoading:(FBRequest*)request {
	
}

/**
 * Called when the server responds and begins to send back data.
 */
- (void)request:(FBRequest*)request didReceiveResponse:(NSURLResponse*)response {
	NSLog(@"request didReceiveResponse");
}

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest*)request didFailWithError:(NSError*)error {
	NSLog(@"request didFailWithError");
	[delegate facebookControllerDidFail:self];
}

/**
 * Called when a request returns and its response has been parsed into an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number, depending
 * on thee format of the API response.
 */
- (void)request:(FBRequest*)request didLoad:(id)result {
	NSLog(@"Video upload Success");
	[delegate facebookControllerDidFinish:self];
	[session logout];
}

/**
 * Called when the request was cancelled.
 */
- (void)requestWasCancelled:(FBRequest*)request {
	NSLog(@"requestWasCancelled");
	[delegate facebookControllerDidFail:self];
	
}








@end
