//
//  ShareManager.m
//  Milgrom
//
//  Created by Roee Kremer on 10/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "ShareManager.h"
#import "MainViewController.h"
#import "MilgromInterfaceAppDelegate.h"
#import "Song.h"
#import "MilgromMacros.h"
#import "YouTubeUploadViewController.h"
#import "FacebookUploadViewController.h"
#import "RenderViewController.h"

#import "testApp.h"
#import "Reachability.h"

enum {
	STATE_IDLE,
	STATE_RENDER_AUDIO,
	STATE_EXPORT_AUDIO,
	STATE_RENDER_VIDEO,
	STATE_CANCEL
};


void ShareAlert(NSString *title,NSString *message) {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil  cancelButtonTitle:@"OK"  otherButtonTitles: nil];
	[alert show];
	[alert release];
}


static NSString* kMilgromURL = @"http://www.mmmilgrom.com";

@interface ShareManager ()
- (void)sendViaMailWithSubject:(NSString *)subject withMessage:(NSString*)message 
					  withData:(NSData *)data withMimeType:(NSString*) mimeType withFileName:(NSString*)fileName;
- (void)exportToLibrary;
- (void)setVideoRendered;
- (void)setRingtoneExported;
- (BOOL)gotInternet;
- (void)processVideo;
- (void)processRingtone;

@end

@implementation ShareManager

@synthesize facebookUploader;
@synthesize youTubeUploader;
@synthesize sheet;



+ (ShareManager*) shareManager {
	
	return [[[ShareManager alloc] init] autorelease];
}

- (id)init {
	
	if (self = [super init]) {
		self.youTubeUploader = [YouTubeUploader youTubeUploader];
		[youTubeUploader addDelegate:self];
		self.facebookUploader = [FacebookUploader facebookUploader];
		[facebookUploader addDelegate:self];
		
		canSendMail = [MFMailComposeViewController canSendMail];
		
		[self resetVersions];
	}
	return self;
}


- (BOOL)gotInternet {
	
	MilgromLog(@"ShareManager::checkInternet Testing Internet Connectivity");
	Reachability *r = [Reachability reachabilityForInternetConnection];
	
	MilgromLog(@"ShareManager::checkInternet %i",[r currentReachabilityStatus] != NotReachable);
	return [r currentReachabilityStatus] != NotReachable;
}

-(BOOL) isUploading {
	return facebookUploader.state == FACEBOOK_UPLOADER_STATE_UPLOADING || youTubeUploader.state == YOUTUBE_UPLOADER_STATE_UPLOADING;
}


- (void)setVideoRendered {
	MilgromInterfaceAppDelegate * appDelegate = (MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate];
	renderedVideoVersion = appDelegate.OFSAptr->getSongVersion();
	if (appDelegate.lastSavedVersion == appDelegate.OFSAptr->getSongVersion()) {
		Song * song = [appDelegate currentSong];
		[song setBVideoRendered:[NSNumber numberWithBool:YES]];
		[appDelegate saveContext];
	}
	
}


- (BOOL)videoRendered {
	MilgromInterfaceAppDelegate * appDelegate = (MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate];
	if (appDelegate.lastSavedVersion == appDelegate.OFSAptr->getSongVersion()) {
		Song * song = [(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] currentSong];
		return [song.bVideoRendered boolValue];
	} else {
		return renderedVideoVersion == appDelegate.OFSAptr->getSongVersion();
	}
}


- (void)setRingtoneExported {
	MilgromInterfaceAppDelegate * appDelegate = (MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate];
	exportedRingtoneVersion = appDelegate.OFSAptr->getSongVersion();
	if (appDelegate.lastSavedVersion == appDelegate.OFSAptr->getSongVersion()) {
		Song * song = [appDelegate currentSong];
		[song setBRingtoneExprted:[NSNumber numberWithBool:YES]];
		[appDelegate saveContext];
	}
	
}


- (BOOL)ringtoneExported {
	MilgromInterfaceAppDelegate * appDelegate = (MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate];
	if (appDelegate.lastSavedVersion == appDelegate.OFSAptr->getSongVersion()) {
		Song * song = [(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] currentSong];
		return [song.bRingtoneExprted boolValue];
	} else {
		return exportedRingtoneVersion == appDelegate.OFSAptr->getSongVersion();
	}
}



- (NSString *)getSongName {
	Song * song = [(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] currentSong];
	return [song songName];

}


- (NSString *)getDisplayName {
	Song * song = [(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] currentSong];
	return [song displayName];
		
}

- (NSString *)getVideoPath {
	
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	if (!documentsDirectory) {
		MilgromLog(@"Documents directory not found!");
		return @"";
	}
	
	MilgromInterfaceAppDelegate * appDelegate = (MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	
	return appDelegate.lastSavedVersion == appDelegate.OFSAptr->getSongVersion() ? 
		[[paths objectAtIndex:0] stringByAppendingPathComponent:[[(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] currentSong] songName]] :
	[[paths objectAtIndex:0] stringByAppendingPathComponent:@"temp"];
}





#pragma mark mailClass


- (void)sendViaMailWithSubject:(NSString *)subject withMessage:(NSString*)message
					  withData:(NSData *)data withMimeType:(NSString*) mimeType withFileName:(NSString*)fileName {
	
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil)
	{
		// We must always check whether the current device is configured for sending emails
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		picker.mailComposeDelegate = self;
		
		[picker setSubject:subject];
		[picker addAttachmentData:data mimeType:mimeType fileName:fileName];
		
		[picker setMessageBody:message isHTML:YES];
		[((MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate]).navigationController presentModalViewController:picker animated:YES];
		[picker release];

	}
	
}




// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	//appDelegate.toolbar.hidden = NO;
	//message.hidden = NO;
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			//message.text = @"Result: canceled";
			break;
		case MFMailComposeResultSaved:
			//message.text = @"Result: saved";
			break;
		case MFMailComposeResultSent: 
			//message.text = @"Result: sent";
			
			break;
		case MFMailComposeResultFailed:
			//message.text = @"Result: failed";
			break;
		default:
			//message.text = @"Result: not sent";
			break;
	}
	[((MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate]).navigationController dismissModalViewControllerAnimated:YES];
	
}


#pragma mark Uploaders delegates

- (void) facebookUploaderStateChanged:(FacebookUploader *)theUploader {
	switch (theUploader.state) {
		case FACEBOOK_UPLOADER_STATE_UPLOAD_FINISHED: {
			ShareAlert(@"Facebook upload", @"Your video was uploaded successfully!\ngo check your wall");
		} break;
		case FACEBOOK_UPLOADER_STATE_UPLOADING: {
			ShareAlert(@"Facebook upload", @"Upload is in progress");
		} break;
		default:
			break;
	}
	
	[((MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate]).mainViewController updateViews];
		
}

- (void) facebookUploaderProgress:(float)progress {
	[[(MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate] mainViewController] setShareProgress:progress];
}


-(void) youTubeUploaderStateChanged:(YouTubeUploader *)theUploader{
	switch (theUploader.state) {
		case YOUTUBE_UPLOADER_STATE_UPLOAD_FINISHED: {
			ShareAlert(@"YouTube upload", [NSString stringWithFormat:@"your video was uploaded successfully!"]); // link: %@",[theUploader.link absoluteString]]);
		} break;
		case YOUTUBE_UPLOADER_STATE_UPLOADING: {
			ShareAlert(@"YouTube upload", @"Upload is in progress");
			
		} break;
		case YOUTUBE_UPLOADER_STATE_UPLOAD_STOPPED: {
			ShareAlert(@"YouTube Upload error" , @"your upload has been stopped");
		} break;
			
		default:
			break;
	}
	
	[((MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate]).mainViewController updateViews];
	
}


- (void) youTubeUploaderProgress:(float)progress {
	[[(MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate] mainViewController] setShareProgress:progress];
}



- (void)resetVersions {
	
	renderedVideoVersion = 0;
	exportedRingtoneVersion = 0;
}
						
				
/*
#pragma mark actionSheet

- (void)menuWithView:(UIView *)view {
	
	
	
	self.sheet = [[UIActionSheet alloc] init];
	
	
	//sheet.title = @"Illustrations";
	sheet.delegate = self;
	
	
	
	[sheet addButtonWithTitle:@"Upload to YouTube"];
	[sheet addButtonWithTitle:@"Upload to FaceBook"];
	[sheet addButtonWithTitle:@"Add to Library"];

	if (canSendMail) {
		[sheet addButtonWithTitle:@"Send via mail"];
		[sheet addButtonWithTitle:@"Send ringtone"];
	}
	
	
	
	[sheet addButtonWithTitle:@"Cancel"];
//	[sheet addButtonWithTitle:@"Render"];
//	[sheet addButtonWithTitle:@"Play"];
	
	sheet.actionSheetStyle = UIActionSheetStyleDefault;
	
	[sheet showInView:view];
	//sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
	
}


- (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	
	state = STATE_IDLE;
	// Change the navigation bar style, also make the status bar match with it
	
	if (!canSendMail && buttonIndex>3) { // skip send mail result (2)
		buttonIndex+=2;
	}
	
	
	switch (buttonIndex)
	{
		case 0: {
			if ([self gotInternet]) {
				action = buttonIndex ? ACTION_UPLOAD_TO_FACEBOOK : ACTION_UPLOAD_TO_YOUTUBE;
			} else {
				ShareAlert(@"Upload Movie", @"We're trying hard, but there's no Internet connection");
				action = ACTION_CANCEL;
			}

			//action = self.isUploading ? ACTION_CANCEL : ACTION_UPLOAD_TO_YOUTUBE ;
			//action = self.isUploading ? ACTION_CANCEL :ACTION_UPLOAD_TO_FACEBOOK;
		} break;
		case 1:
			ShareAlert(@"Upload Movie", @"in the near future, very near...");
			action = ACTION_CANCEL;

			break;
		case 2:
			action = ACTION_ADD_TO_LIBRARY;
			break;
		case 3:
			action = ACTION_SEND_VIA_MAIL;
			break;
		case 4:
			action = ACTION_SEND_RINGTONE;
			break;
			
		case 5:
			action = ACTION_CANCEL;
			break;
			
		case 6:
			action = ACTION_RENDER;
			break;
			
		case 7:
			action = ACTION_PLAY;
			break;
			
	}
	
	[self performSelector:@selector(action)];
	self.sheet = nil;
}
 */


- (void)action:(NSInteger)theAction {
	action = theAction;
	
	BOOL bNeedToRender = YES;
	
	switch (action) {
		case ACTION_CANCEL:
			break;
		case ACTION_UPLOAD_TO_YOUTUBE:
		case ACTION_UPLOAD_TO_FACEBOOK:
			if (![self gotInternet]) {
				ShareAlert(@"Upload Movie", @"We're trying hard, but there's no Internet connection");
				return;
			}
		case ACTION_ADD_TO_LIBRARY:
		case ACTION_SEND_VIA_MAIL:
		case ACTION_PLAY:
		case ACTION_RENDER:
			if (self.videoRendered ) {
				bNeedToRender = NO;
				[self processVideo];
			}
			break;
		case ACTION_SEND_RINGTONE:
			if (self.ringtoneExported ) {
				bNeedToRender = NO;
				[self processRingtone];
			} 		
			break;
			
		default:
			break;
	}
				 
	if (bNeedToRender) {
		RenderViewController *renderViewController = [[RenderViewController alloc] initWithNibName:@"RenderViewController" bundle:nil];
		renderViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		[renderViewController setDelegate:self];
		[((MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate]).navigationController presentModalViewController:renderViewController animated:YES];
		[renderViewController release];
	}
}

- (void) processRingtone {
	NSString *subject = @"Sweeeet! My New Milgrom Ringtone!";
	NSString *message = [NSString stringWithFormat:@"Hey,<br/>I just made a ringtone created with the help of this cool little band Milgrom.<br/>I'm sending it to you as I believe you'll get a kick out of it (or else we cannot be friends)<br/>Double click the attachment to listen to it first.<br/>Then, save it to your desktop, and then drag it to your itunes library. Now sync your iDevice.<br/>Next, in your iDevice, go to Settings > Sounds > Ringtone > and under 'Custom' you should see this file name.<br/>You can always switch it back if you feel like you're not ready for this work of art, yet.<br/><br/>Now, pay a visit to <a href='%@'>Milgrom's</a> website. I leave it to you to handle the truth.",kMilgromURL];
	
	
	NSData *myData = [NSData dataWithContentsOfFile:[[self getVideoPath]  stringByAppendingPathExtension:@"m4r"]];
	[self sendViaMailWithSubject:subject withMessage:message withData:myData withMimeType:@"audio/m4r" 
					withFileName:[[self getSongName] stringByAppendingPathExtension:@"m4r"]];	
}

- (void) processVideo {
	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate];

	switch (action)
	{
		case ACTION_UPLOAD_TO_YOUTUBE: {
			
			YouTubeUploadViewController *controller = [[YouTubeUploadViewController alloc] initWithNibName:@"YouTubeUploadViewController" bundle:nil];
			[controller setDelegate:self];
			[appDelegate.navigationController presentModalViewController:controller animated:YES];
			controller.uploader = appDelegate.shareManager.youTubeUploader;
			controller.videoTitle = [[self getDisplayName] uppercaseString];
			//controller.additionalText = kMilgromURL;
			controller.descriptionView.text = [NSString stringWithFormat:@"this video created with Milgrom's iphone app\nvisit milgrom at http://www.mmmilgrom.com"];
			controller.videoPath = [[self getVideoPath] stringByAppendingPathExtension:@"mov"];
			
			[controller release];
		}	break;
			
		case ACTION_UPLOAD_TO_FACEBOOK: {
			
			[facebookUploader login];
			FacebookUploadViewController * controller = [[FacebookUploadViewController alloc] initWithNibName:@"FacebookUploadViewController" bundle:nil];
			[controller setDelegate:self];
			[appDelegate.navigationController presentModalViewController:controller animated:YES];
			controller.uploader = appDelegate.shareManager.facebookUploader;
			controller.videoTitle = [NSString stringWithFormat:@"MILGROM PLAYS %@",[[self getDisplayName] uppercaseString]];
			//controller.additionalText = kMilgromURL;
			controller.descriptionView.text = @"more milgrom at http://www.mmmilgrom.com/fb";
			controller.videoPath = [[self getVideoPath]  stringByAppendingPathExtension:@"mov" ];
			[controller release];
			
		}	break;
			
		case ACTION_ADD_TO_LIBRARY:
			//[appDelegate mainViewController].view.userInteractionEnabled = YES; 
			[self exportToLibrary];
			break;
			
		case ACTION_SEND_VIA_MAIL: 
		{
			
			NSString *subject = @"check out my milgrom song";
			NSString *message = [NSString stringWithFormat:@"Isn't  it a work of art?<br/><br/><a href='%@'>visit milgrom</a>",kMilgromURL];
			NSData *myData = [NSData dataWithContentsOfFile:[[self getVideoPath]  stringByAppendingPathExtension:@"mov"]];
			[self sendViaMailWithSubject:subject withMessage:message withData:myData withMimeType:@"video/mov" 
							withFileName:[[self getSongName] stringByAppendingPathExtension:@"mov"]];
		} break;
			
			
		case ACTION_PLAY:
			[appDelegate playURL:[NSURL fileURLWithPath:[[self getVideoPath] stringByAppendingPathExtension:@"mov"]]];
			break;
			
		case ACTION_CANCEL:
		case ACTION_RENDER:
			//[appDelegate mainViewController].view.userInteractionEnabled = YES; 
			break;
			
	}	
	
}



#pragma mark delegates

- (void) RenderViewControllerDelegateCanceled:(RenderViewController *)controller {
	[((MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate]).navigationController dismissModalViewControllerAnimated:YES];
	

}

- (void) RenderViewControllerDelegateAudioRendered:(RenderViewController *)controller {
	
	switch (action) {
		case ACTION_UPLOAD_TO_YOUTUBE:
		case ACTION_UPLOAD_TO_FACEBOOK:
		case ACTION_ADD_TO_LIBRARY:
		case ACTION_SEND_VIA_MAIL:
		case ACTION_PLAY:
		case ACTION_RENDER:
			[controller renderVideo];
			break;
		case ACTION_SEND_RINGTONE:
			[controller exportRingtone];
			break;
		default:
			break;
	}
}

- (void) RenderViewControllerDelegateVideoRendered:(RenderViewController *)controller {
	[self setVideoRendered];
	[((MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate]).navigationController dismissModalViewControllerAnimated:NO];
	[self processVideo];
}


- (void) RenderViewControllerDelegateRingtoneExported:(RenderViewController *)controller {
	[self setRingtoneExported];
	[((MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate]).navigationController dismissModalViewControllerAnimated:NO];
	[self processRingtone];
}



- (void) YouTubeUploadViewControllerDone:(YouTubeUploadViewController *)controller {
	[((MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate]).navigationController dismissModalViewControllerAnimated:YES];
}

- (void) FacebookUploadViewControllerDone:(FacebookUploadViewController *)controller {
	[((MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate]).navigationController dismissModalViewControllerAnimated:YES];
}

- (void)exportToLibrary
{
	NSURL *outputURL = [NSURL fileURLWithPath:[[self getVideoPath] stringByAppendingPathExtension:@"mov"]];
	ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
	if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
		[library writeVideoAtPathToSavedPhotosAlbum:outputURL
									completionBlock:^(NSURL *assetURL, NSError *error){
										dispatch_async(dispatch_get_main_queue(), ^{
											if (error) {
												MilgromLog(@"writeVideoToAssestsLibrary failed: %@", error);
												ShareAlert([error localizedDescription], [error localizedRecoverySuggestion]);
												
											}
											else {
												MilgromLog(@"writeVideoToAssestsLibrary successed");
												ShareAlert(@"Library", @"The video has been saved to your photos library");
										
											}
										});
										
									}];
	}
	[library release];
}

- (void)applicationDidEnterBackground {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	
	
//	if (sheet) {
//		[sheet dismissWithClickedButtonIndex:0 animated:NO];
//		self.sheet = nil;
//	}
	
	[facebookUploader applicationDidEnterBackground];
	
}


@end
