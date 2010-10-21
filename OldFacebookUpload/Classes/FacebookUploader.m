//
//  FacebookUploader.m
//  FacebookUpload
//
//  Created by Roee Kremer on 10/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FacebookUploader.h"

// Your Facebook APP Id must be set before running this example
// See http://www.facebook.com/developers/createapp.php
//static NSString* kAppId = @"142588289117470";
static NSString* kApiKey = @"e06968ce5ad567d5685a8ebabfd63619";
static NSString* kApiSecret = @"05e64b714292c6405e111357e7110078";



@interface FacebookUploader (PrivateMethods) 
- (void)login;
- (void) requestPermission;
@end



@implementation FacebookUploader

@synthesize delegate;
@synthesize session;
@synthesize videoTitle;
@synthesize videoDescription;
@synthesize videoPath;
@synthesize isUploading;
@synthesize progress;

+ (FacebookUploader *) facebookUploaderWithDelegate:(id<FacebookUploaderDelegate>)theDelegate {
	return [[[FacebookUploader alloc] initWithDelegate:theDelegate] autorelease];
}

- (id)initWithDelegate:(id<FacebookUploaderDelegate>)theDelegate {
	
	if (self = [super init]) {
		self.delegate = theDelegate;
		isUploading = NO;
	}
	return self;
}

- (void) dealloc {
	[videoTitle release];
	[videoDescription release];
	[videoPath release];
	[session release];
	[super dealloc];
}

- (void)login {
	if ( self.session == nil) {
		self.session = [FBSession sessionForApplication: kApiKey secret: kApiSecret delegate: self] ;
	}
		
	if (![session resume]) {
		// Show the login dialog
		FBLoginDialog* dialog = [[[FBLoginDialog alloc] init] autorelease];
		dialog.delegate = self;
		//m_FBDialogStage = 0;
		[dialog show];
	}	
}

- (void) requestPermission { // Ask for extended permissions
	FBPermissionDialog* dialog = [[[FBPermissionDialog alloc] init] autorelease];
	dialog.delegate = self;
	dialog.permission = @"publish_stream";
	[dialog show];
	
}



- (void) uploadVideoWithTitle:(NSString *)title withDescription:(NSString *)description andPath:(NSString *)path {
	
	self.videoTitle = title;
	self.videoDescription = description;
	self.videoPath = path;
	
	[self login];
	
}

- (void) logout {
	[session logout];
}

- (BOOL) isConnected {
	return [session isConnected];
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
	[delegate facebookUploaderDidFail:self];
	
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
		NSData *data = [NSData dataWithContentsOfFile:videoPath];
		
		FBRequest *uploadRequest = [FBRequest requestWithSession: session delegate: self];
		
		NSMutableDictionary* Parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"video.upload", @"method", 
										   videoTitle, @"title", videoDescription,@"description",nil];
		[uploadRequest call: @"facebook.video.upload" params: Parameters dataParam: data];
		
		isUploading = YES;
		//[delegate facebookUploaderDidLogin:self];
	}
}

/**
 * Called when the dialog is cancelled and is about to be dismissed.
 */
- (void)dialogDidCancel:(FBDialog*)dialog {
	NSLog(@"dialogDidCancel");
	[delegate facebookUploaderDidFail:self];
}

/**
 * Called when dialog failed to load due to an error.
 */
- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError*)error {
	NSLog(@"dialog didFailWithError");
	[delegate facebookUploaderDidFail:self];
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
	isUploading = NO;
	[delegate facebookUploaderDidFail:self];
}

/**
 * Called when a request returns and its response has been parsed into an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number, depending
 * on thee format of the API response.
 */
- (void)request:(FBRequest*)request didLoad:(id)result {
	NSLog(@"Video upload Success");
	isUploading = NO;
	[delegate facebookUploaderDidFinishUploading:self];
	//[session logout];
}

/**
 * Called when the request was cancelled.
 */
- (void)requestWasCancelled:(FBRequest*)request {
	NSLog(@"requestWasCancelled");
	isUploading = NO;
	[delegate facebookUploaderDidFail:self];
	
}


- (void)request:(FBRequest*)request didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
	progress = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
	NSLog(@"facebook upload progress: %f",progress);
	[delegate facebookUploaderProgress:progress];
}






@end
