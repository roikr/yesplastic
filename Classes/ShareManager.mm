//
//  ShareManager.m
//  Milgrom
//
//  Created by Roee Kremer on 10/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ShareManager.h"
#import "MainViewController.h"
#import "MilgromInterfaceAppDelegate.h"

@implementation ShareManager

@synthesize facebookUploader;
@synthesize youTubeUploader;



+ (ShareManager*) shareManager {
	
	return [[[ShareManager alloc] init] autorelease];
}

- (id)init {
	
	if (self = [super init]) {
		self.youTubeUploader = [YouTubeUploader youTubeUploaderWithDelegate:self];
		self.facebookUploader = [FacebookUploader facebookUploaderWithDelegate:self];
		
	}
	return self;
}

-(BOOL) isUploading {
	return facebookUploader.isUploading || youTubeUploader.isUploading;
}

- (void) facebookUploaderDidLogin:(FacebookUploader *)theUploader {
}

- (void) facebookUploaderDidFail:(FacebookUploader *)theUploader {
}

- (void) facebookUploaderDidStartUploading:(FacebookUploader *)theUploader {
}

- (void) facebookUploaderDidFinishUploading:(FacebookUploader *)theUploader {
}

- (void) facebookUploaderProgress:(float)progress {
	[[(MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate] mainViewController] setShareProgress:progress];
	
	
}


-(void) youTubeUploaderDidFail:(YouTubeUploader *)theUploader{
}


- (void) youTubekUploaderDidStartUploading:(YouTubeUploader *)theUploader{
}

- (void) youTubeUploaderDidFinishUploading:(YouTubeUploader *)theUploader withURL:(NSURL*) theUrl {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"YouTube Upload finished" 
													message:[NSString stringWithFormat:@"link: %@",[theUrl absoluteString]]
												   delegate:nil 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles: nil];
	[alert show];
	[alert release];
}

- (void) youTubeUploaderProgress:(float)progress {
	[[(MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate] mainViewController] setShareProgress:progress];
}



@end
