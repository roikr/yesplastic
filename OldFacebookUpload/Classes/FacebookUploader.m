//
//  FacebookUploader.m
//  FacebookUpload
//
//  Created by Roee Kremer on 10/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FacebookUploader.h"
#import "RKUBackgroundTask.h"

// Your Facebook APP Id must be set before running this example
// See http://www.facebook.com/developers/createapp.php
//static NSString* kAppId = @"142588289117470";
static NSString* kApiKey = @"e06968ce5ad567d5685a8ebabfd63619";
static NSString* kApiSecret = @"05e64b714292c6405e111357e7110078";



@interface FacebookUploader (PrivateMethods) 
- (void) requestPermission;
@end



@implementation FacebookUploader

@synthesize delegates;
@synthesize session;
@synthesize videoTitle;
@synthesize videoDescription;
@synthesize videoPath;
@synthesize progress;
@synthesize task;

+ (FacebookUploader *) facebookUploader {
	return [[[FacebookUploader alloc] init] autorelease];
}

- (id)init {
	
	if (self = [super init]) {
		self.delegates = [NSMutableArray array];
		_state = FACEBOOK_UPLOADER_STATE_IDLE;	
	} return self;
}

-(void)addDelegate:(id<FacebookUploaderDelegate>)delegate {
	[delegates addObject:delegate];
}

- (void) dealloc {
	[videoTitle release];
	[videoDescription release];
	[videoPath release];
	[session release];
	[super dealloc];
}

- (NSInteger) state {
	return _state;
}
	
- (void) setState:(NSInteger)newState {
	
	BOOL finishUploading = _state == FACEBOOK_UPLOADER_STATE_UPLOADING;
	
	
	_state = newState;
	
	NSLog(@"FacebookUploader state changed: %i",_state);
	
	if (newState == FACEBOOK_UPLOADER_STATE_UPLOADING) {
		self.task = [RKUBackgroundTask backgroundTask];
	}
	
	if (finishUploading) {
		if (newState == FACEBOOK_UPLOADER_STATE_UPLOADING) {
			NSLog(@"FacebookUploader: FACEBOOK_UPLOADER_STATE_UPLOADING twice");
		} 
		
		if ([RKUBackgroundTask isBackground]) {
			
			NSLog(@"FacebookUploader: finish uploading in background, no delegate");
		}
		
		[task finish];
		
		self.task = 0;
		
	}
	
	
	for (id<FacebookUploaderDelegate> delegate in delegates) {
		if ([delegate respondsToSelector:@selector(facebookUploaderStateChanged:)]) {
			[delegate facebookUploaderStateChanged:self];
		}
	}
	
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
	
	if ([self isConnected] && self.state == FACEBOOK_UPLOADER_STATE_DID_LOGIN) {
		NSData *data = [NSData dataWithContentsOfFile:videoPath]; 
		
		FBRequest *uploadRequest = [FBRequest requestWithSession: session delegate: self];
		
		NSMutableDictionary* Parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"video.upload", @"method", 
										   videoTitle, @"title", videoDescription,@"description",nil];
		[uploadRequest call: @"facebook.video.upload" params: Parameters dataParam: data];
	}
	
//if ([self isConnected]) {
//		[self logout];
//	} else {
//		[self login];
//	}

	
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
	
	self.state = FACEBOOK_UPLOADER_STATE_DID_NOT_LOGIN;
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
	[self login];
}


/**
 * Called when the dialog succeeds and is about to be dismissed.
 */
- (void)dialogDidSucceed:(FBDialog*)dialog {
	NSLog(@"dialogDidSucceed");
	if ([dialog isKindOfClass:[FBPermissionDialog class]]) {
		
		
		self.state = FACEBOOK_UPLOADER_STATE_DID_LOGIN;
		//[delegate facebookUploaderDidLogin:self];
	}
}

/**
 * Called when the dialog is cancelled and is about to be dismissed.
 */
- (void)dialogDidCancel:(FBDialog*)dialog {
	NSLog(@"dialogDidCancel");
	self.state = FACEBOOK_UPLOADER_STATE_UPLOAD_CANCELED;
	
}

/**
 * Called when dialog failed to load due to an error.
 */
- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError*)error {
	NSLog(@"dialog didFailWithError");
	if ([dialog isKindOfClass:[FBPermissionDialog class]]) {
		self.state = FACEBOOK_UPLOADER_STATE_DID_NOT_LOGIN;
	}
	
	if ([dialog isKindOfClass:[FBLoginDialog class]]) {
		self.state = FACEBOOK_UPLOADER_STATE_DID_NOT_LOGIN;
	}
	
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
	self.state = FACEBOOK_UPLOADER_STATE_UPLOADING;
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
	self.state = FACEBOOK_UPLOADER_STATE_UPLOAD_FAILED;
}

/**
 * Called when a request returns and its response has been parsed into an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number, depending
 * on thee format of the API response.
 */
- (void)request:(FBRequest*)request didLoad:(id)result {
	NSLog(@"Video upload Success");
	self.state = FACEBOOK_UPLOADER_STATE_UPLOAD_FINISHED;
}

/**
 * Called when the request was cancelled.
 */
- (void)requestWasCancelled:(FBRequest*)request {
	NSLog(@"requestWasCancelled");
	self.state = FACEBOOK_UPLOADER_STATE_UPLOAD_CANCELED;
	
}


- (void)request:(FBRequest*)request didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
	[task update];
	
	progress = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
	NSLog(@"facebook upload progress: %f",progress);
	
	for (id<FacebookUploaderDelegate> delegate in delegates) {
		if ([delegate respondsToSelector:@selector(facebookUploaderProgress:)]) {
			[delegate facebookUploaderProgress:progress];
		}
	}

}






@end
