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
		self.youTubeUploader = [YouTubeUploader youTubeUploader];
		[youTubeUploader addDelegate:self];
		self.facebookUploader = [FacebookUploader facebookUploaderWithDelegate:self];
		
	}
	return self;
}

-(BOOL) isUploading {
	return facebookUploader.isUploading || youTubeUploader.state == YOUTUBE_UPLOADER_STATE_UPLOAD_STARTED || youTubeUploader.state == YOUTUBE_UPLOADER_STATE_UPLOADING;
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


-(void) youTubeUploaderStateChanged:(YouTubeUploader *)theUploader{
	switch (theUploader.state) {
		case YOUTUBE_UPLOADER_STATE_UPLOAD_FINISHED: {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"YouTube Upload finished" 
															message:[NSString stringWithFormat:@"link: %@",[theUploader.link absoluteString]]
														   delegate:nil 
												  cancelButtonTitle:@"OK" 
												  otherButtonTitles: nil];
			[alert show];
			[alert release];
		} break;
		default:
			break;
	}
}





- (void) youTubeUploaderProgress:(float)progress {
	[[(MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate] mainViewController] setShareProgress:progress];
}



@end
