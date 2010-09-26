//
//  YouTubeUploadViewController.m
//  YouTubeUpload
//
//  Created by Roee Kremer on 9/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "YouTubeUploadViewController.h"
#import "GData.h"
#import "GDataServiceGoogleYouTube.h"
#import "GDataEntryYouTubeUpload.h"

NSString* const kDeveloperKey = @"AI39si435pYVfbsWYr6_f70JFUWGyfK7_SEb7vOkGO7ay_ouUT6HFwaWn1GQxuyAIK-zvoeFB-GU_cqx30q-0HggREKxXG-b8w";


@interface YouTubeUploadViewController (PrivateMethods)
//- (void)updateUI;


- (void)uploadVideoFile;

- (GDataServiceTicket *)uploadTicket;
- (void)setUploadTicket:(GDataServiceTicket *)ticket;

- (GDataServiceGoogleYouTube *)youTubeService;


@end

@implementation YouTubeUploadViewController

@synthesize username;
@synthesize password;
@synthesize videoTitle;
@synthesize description;
@synthesize mUploadProgressIndicator;



/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	username.text = @"roikr75";
	videoTitle.text = @"test";
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[mUploadTicket release];
    [super dealloc];
}

- (void) upload:(id)sender {
	[self uploadVideoFile];
}

- (void) cancel:(id)sender {
	
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return NO;
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
	
	
	if ([username.text length] > 0 && [password.text length] > 0) {
		[service setUserCredentialsWithUsername:username.text
									   password:password.text];
	} else {
		// fetch unauthenticated
		[service setUserCredentialsWithUsername:nil
									   password:nil];
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



- (void)uploadVideoFile {
	
	
	
	GDataServiceGoogleYouTube *service = [self youTubeService];
	[service setYouTubeDeveloperKey:kDeveloperKey];
	
	
	
	NSURL *url = [GDataServiceGoogleYouTube youTubeUploadURLForUserID:username.text];
	
	
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	if (!documentsDirectory) {
		//MilgromLog(@"Documents directory not found!");
		return;
	}
	
	
	
	// load the file data
	NSString *path = [[NSBundle mainBundle] pathForResource:@"video" ofType:@"mov"];
	NSData *data = [NSData dataWithContentsOfFile:path];
	NSString *filename = [path lastPathComponent];
	
	// gather all the metadata needed for the mediaGroup
	NSString *titleStr = videoTitle.text;
	GDataMediaTitle *title = [GDataMediaTitle textConstructWithString:titleStr];
	
	NSString *categoryStr = @"Film";//[[mCategoryPopup selectedItem] representedObject];
	GDataMediaCategory *category = [GDataMediaCategory mediaCategoryWithString:categoryStr]; 
	[category setScheme:kGDataSchemeYouTubeCategory];
	
	NSString *descStr = description.text;
	GDataMediaDescription *desc = [GDataMediaDescription textConstructWithString:descStr];
	
	NSString *keywordsStr = nil;//[mKeywordsField stringValue];
	GDataMediaKeywords *keywords = [GDataMediaKeywords keywordsWithString:keywordsStr];
	
	BOOL isPrivate = YES;//([mPrivateCheckbox state] == NSOnState);
	
	GDataYouTubeMediaGroup *mediaGroup = [GDataYouTubeMediaGroup mediaGroup];
	[mediaGroup setMediaTitle:title];
	[mediaGroup setMediaDescription:desc];
	[mediaGroup addMediaCategory:category];
	//[mediaGroup setMediaKeywords:keywords];
	[mediaGroup setIsPrivate:isPrivate];
	
	NSString *mimeType = [GDataUtilities MIMETypeForFileAtPath:path
											   defaultMIMEType:@"video/quicktime"];
	
	// create the upload entry with the mediaGroup and the file data
	GDataEntryYouTubeUpload *entry;
	entry = [GDataEntryYouTubeUpload uploadEntryWithMediaGroup:mediaGroup
														  data:data
													  MIMEType:mimeType
														  slug:filename];
	
	SEL progressSel = @selector(ticket:hasDeliveredByteCount:ofTotalByteCount:);
	[service setServiceUploadProgressSelector:progressSel];
	
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
	
	
	[mUploadProgressIndicator setProgress:(float)numberOfBytesRead/(float)dataLength];
}

// upload callback
- (void)uploadTicket:(GDataServiceTicket *)ticket
   finishedWithEntry:(GDataEntryYouTubeVideo *)videoEntry
               error:(NSError *)error {
	//	if (error == nil) {
	//		// tell the user that the add worked
	//		NSBeginAlertSheet(@"Uploaded", nil, nil, nil,
	//						  [self window], nil, nil,
	//						  nil, nil, @"Uploaded video: %@",
	//						  [[videoEntry title] stringValue]);
	//		
	//		// refetch the current entries, in case the list of uploads
	//		// has changed
	//		[self fetchAllEntries];
	//		[self updateUI];
	//	} else {
	//		NSBeginAlertSheet(@"Upload failed", nil, nil, nil,
	//						  [self window], nil, nil,
	//						  nil, nil, @"Upload failed: %@", error);
	//	}
	[mUploadProgressIndicator setProgress:0.0];
	
	[self setUploadTicket:nil];
}




@end
