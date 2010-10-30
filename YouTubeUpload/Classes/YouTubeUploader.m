//
//  YouTubeUploader.m
//  YouTubeUpload
//
//  Created by Roee Kremer on 10/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "YouTubeUploader.h"

//#import "GData.h"
#import "GDataYouTubeConstants.h"
#import "GDataServiceGoogleYouTube.h"
#import "GDataEntryYouTubeUpload.h"
#import "GDataEntryYouTubeVideo.h"

NSString* const kDeveloperKey = @"AI39si435pYVfbsWYr6_f70JFUWGyfK7_SEb7vOkGO7ay_ouUT6HFwaWn1GQxuyAIK-zvoeFB-GU_cqx30q-0HggREKxXG-b8w";


@interface YouTubeUploader (PrivateMethods) 

- (GDataServiceTicket *)uploadTicket;
- (void)setUploadTicket:(GDataServiceTicket *)ticket;
- (GDataServiceGoogleYouTube *)youTubeService;
@end



@implementation YouTubeUploader

@synthesize delegates;
@synthesize username;
@synthesize password;
@synthesize progress;
@synthesize link;
@synthesize state;


+ (YouTubeUploader *) youTubeUploader {
	return [[[YouTubeUploader alloc] init] autorelease];
}

- (id)init {
	
	if (self = [super init]) {
		self.delegates = [NSMutableArray array];
		state = YOUTUBE_UPLOADER_STATE_IDLE;
	}
	return self;
}

-(void)addDelegate:(id<YouTubeUploaderDelegate>)delegate {
	[delegates addObject:delegate];
}

- (void) dealloc {
	[mUploadTicket release];
	
	[username release];
	[password release];
	[super dealloc];
}




#pragma mark -

- (GDataServiceGoogleYouTube *)youTubeService { 
	
	static GDataServiceGoogleYouTube* service = nil;
	
	if (!service) {
		service = [[GDataServiceGoogleYouTube alloc] init];
		
		[service setShouldCacheDatedData:YES];
		[service setServiceShouldFollowNextLinks:YES];
		[service setIsServiceRetryEnabled:YES];
	}
	
	// update the username/password each time the service is requested
	
	
	if ([username length] > 0 && [password length] > 0) {
		[service setUserCredentialsWithUsername:username
									   password:password];
	} else {
		// fetch unauthenticated
		[service setUserCredentialsWithUsername:nil
									   password:nil];
		
		state = YOUTUBE_UPLOADER_STATE_INCORRECT_CREDENTIALS;
		
		for (id<YouTubeUploaderDelegate> delegate in delegates) {
			if ([delegate respondsToSelector:@selector(youTubeUploaderStateChanged:)]) {
				[delegate youTubeUploaderStateChanged:self];
			}
		}
		
		return nil;
		
		
	}
	
	[service setYouTubeDeveloperKey:kDeveloperKey];
	
	return service;
}

- (GDataServiceTicket *)uploadTicket {
	return mUploadTicket;
}

- (void)setUploadTicket:(GDataServiceTicket *)ticket {
	[mUploadTicket release];
	mUploadTicket = [ticket retain];
}



- (void) uploadVideoWithTitle:(NSString *)titleStr withDescription:(NSString *)descStr andPath:(NSString *)path {
	
	
	
	GDataServiceGoogleYouTube *service = [self youTubeService];
	
	if (!service) {
		return;
	}
	
	[service setYouTubeDeveloperKey:kDeveloperKey];
	
	
	
	NSURL *url = [GDataServiceGoogleYouTube youTubeUploadURLForUserID:username];
	
	
	
	
	
	NSData *data = [NSData dataWithContentsOfFile:path];
	NSString *filename = [path lastPathComponent];
	
	// gather all the metadata needed for the mediaGroup
	GDataMediaTitle *title = [GDataMediaTitle textConstructWithString:titleStr];
	
	NSString *categoryStr = @"Film";//[[mCategoryPopup selectedItem] representedObject];
	GDataMediaCategory *category = [GDataMediaCategory mediaCategoryWithString:categoryStr]; 
	[category setScheme:kGDataSchemeYouTubeCategory];
	
	
	GDataMediaDescription *desc = [GDataMediaDescription textConstructWithString:descStr];
	
	//	NSString *keywordsStr = nil;//[mKeywordsField stringValue];
	//	GDataMediaKeywords *keywords = [GDataMediaKeywords keywordsWithString:keywordsStr];
	
	BOOL isPrivate = NO;//([mPrivateCheckbox state] == NSOnState);
	
	GDataYouTubeMediaGroup *mediaGroup = [GDataYouTubeMediaGroup mediaGroup];
	[mediaGroup setMediaTitle:title];
	[mediaGroup setMediaDescription:desc];
	[mediaGroup addMediaCategory:category];
	//[mediaGroup setMediaKeywords:keywords];
	[mediaGroup setIsPrivate:isPrivate];
	
	NSString *mimeType = [GDataUtilities MIMETypeForFileAtPath:path defaultMIMEType:@"video/quicktime"];
	
	// create the upload entry with the mediaGroup and the file data
	GDataEntryYouTubeUpload *entry;
	entry = [GDataEntryYouTubeUpload uploadEntryWithMediaGroup:mediaGroup
														  data:data
													  MIMEType:mimeType
														  slug:filename];
	
	SEL progressSel = @selector(ticket:hasDeliveredByteCount:ofTotalByteCount:);
	[service setServiceUploadProgressSelector:progressSel];
	
	state = YOUTUBE_UPLOADER_STATE_UPLOAD_STARTED;
	
	for (id<YouTubeUploaderDelegate> delegate in delegates) {
		if ([delegate respondsToSelector:@selector(youTubeUploaderStateChanged:)]) {
			[delegate youTubeUploaderStateChanged:self];
		}
	}
	
	
	GDataServiceTicket *ticket;
	ticket = [service fetchEntryByInsertingEntry:entry
									  forFeedURL:url
										delegate:self
							   didFinishSelector:@selector(uploadTicket:finishedWithEntry:error:)];
	
	[self setUploadTicket:ticket];
	
		
		//[self updateUI];
}

// progress callback
- (void)ticket:(GDataServiceTicket *)ticket
hasDeliveredByteCount:(unsigned long long)numberOfBytesRead 
ofTotalByteCount:(unsigned long long)dataLength {
	
	if (state==YOUTUBE_UPLOADER_STATE_UPLOAD_STARTED) {
		state = YOUTUBE_UPLOADER_STATE_UPLOADING;
		
		for (id<YouTubeUploaderDelegate> delegate in delegates) {
			if ([delegate respondsToSelector:@selector(youTubeUploaderStateChanged:)]) {
				[delegate youTubeUploaderStateChanged:self];
			}
		}
	}
	
	progress = (float)numberOfBytesRead/(float)dataLength;
	NSLog(@"youtube upload progress: %f",progress);
	
	for (id<YouTubeUploaderDelegate> delegate in delegates) {
		if ([delegate respondsToSelector:@selector(youTubeUploaderProgress:)]) {
			[delegate youTubeUploaderProgress:progress];
		}
	}
	
	
}

// upload callback
- (void)uploadTicket:(GDataServiceTicket *)ticket finishedWithEntry:(GDataEntryYouTubeVideo *)videoEntry error:(NSError *)error {
	
	[self setUploadTicket:nil];
		
	if (error == nil) {
		GDataLink *videoLink = [videoEntry HTMLLink];
		link = [videoLink URL];
		//NSLog(@"location: %@",[videoEntry location]);
		
		state = YOUTUBE_UPLOADER_STATE_UPLOAD_FINISHED;
		
		for (id<YouTubeUploaderDelegate> delegate in delegates) {
			if ([delegate respondsToSelector:@selector(youTubeUploaderStateChanged:)]) {
				[delegate youTubeUploaderStateChanged:self];
			}
		}
		
		
	} else {
//		NSBeginAlertSheet(@"Upload failed", nil, nil, nil,
//						  [self window], nil, nil,
//						  nil, nil, @"Upload failed: %@", error);
		
		switch (state) {
			case YOUTUBE_UPLOADER_STATE_UPLOAD_STARTED:
				state = YOUTUBE_UPLOADER_STATE_INCORRECT_CREDENTIALS;
				break;
			case YOUTUBE_UPLOADER_STATE_UPLOADING:
				state = YOUTUBE_UPLOADER_STATE_UPLOAD_STOPPED;
				break;
				
			default:
				break;
		}
		
		
		
		for (id<YouTubeUploaderDelegate> delegate in delegates) {
			if ([delegate respondsToSelector:@selector(youTubeUploaderStateChanged:)]) {
				[delegate youTubeUploaderStateChanged:self];
			}
		}
		
	}
	
	
	
	
	
		
}

@end