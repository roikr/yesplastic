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

#import "testApp.h"
#import "Reachability.h"

enum {
	STATE_IDLE,
	STATE_RENDER_AUDIO,
	STATE_EXPORT_AUDIO,
	STATE_RENDER_VIDEO,
	STATE_CANCEL
};

enum {
	ACTION_UPLOAD_TO_YOUTUBE,
	ACTION_UPLOAD_TO_FACEBOOK,
	ACTION_ADD_TO_LIBRARY,
	ACTION_SEND_VIA_MAIL,
	ACTION_SEND_RINGTONE,
	ACTION_DONE,
	ACTION_RENDER,
	ACTION_PLAY
};

void ShareAlert(NSString *title,NSString *message) {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil  cancelButtonTitle:@"OK"  otherButtonTitles: nil];
	[alert show];
	[alert release];
}


static NSString* kMilgromURL = @"www.milgrom.com";

@interface ShareManager ()
- (void)action;
- (void)sendViaMailWithSubject:(NSString *)subject withData:(NSData *)data withMimeType:(NSString*) mimeType withFileName:(NSString*)fileName;
- (void)exportToLibrary;
- (void)setVideoRendered;
- (void)setRingtoneExported;
- (BOOL)gotInternet;

@end

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






- (NSString *)getVideoName {
	
	Song * song = [(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] currentSong];
	return [song songName];
	
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

- (NSString *)getVideoTitle {
	return [@"milgrom plays " stringByAppendingString:[self getVideoName]];
	
}



#pragma mark mailClass


- (void)sendViaMailWithSubject:(NSString *)subject withData:(NSData *)data withMimeType:(NSString*) mimeType withFileName:(NSString*)fileName {
	
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil)
	{
		// We must always check whether the current device is configured for sending emails
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		picker.mailComposeDelegate = self;
		
		[picker setSubject:subject];
		[picker addAttachmentData:data mimeType:mimeType fileName:fileName];
		
		[picker setMessageBody:[NSString stringWithFormat:@"<br/><br/><a href='%@'>visit milgrom</a>",kMilgromURL] isHTML:YES];
		[(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] presentModalViewController:picker animated:YES];
		//[self presentModalViewController:picker animated:YES];
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
	[(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] dismissModalViewControllerAnimated:YES];
	
}


#pragma mark Uploaders delegates

- (void) facebookUploaderStateChanged:(FacebookUploader *)theUploader {
	switch (theUploader.state) {
		case FACEBOOK_UPLOADER_STATE_UPLOAD_FINISHED: {
			ShareAlert(@"Facebook upload", @"your upload finished");
		} break;
		case FACEBOOK_UPLOADER_STATE_UPLOADING: {
			ShareAlert(@"Facebook upload", @"Upload in progress");
		} break;
		default:
			break;
	}
}

- (void) facebookUploaderProgress:(float)progress {
	[[(MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate] mainViewController] setShareProgress:progress];
}


-(void) youTubeUploaderStateChanged:(YouTubeUploader *)theUploader{
	switch (theUploader.state) {
		case YOUTUBE_UPLOADER_STATE_UPLOAD_FINISHED: {
			ShareAlert(@"YouTube upload", [NSString stringWithFormat:@"your upload finished. link: %@",[theUploader.link absoluteString]]);
		} break;
		case YOUTUBE_UPLOADER_STATE_UPLOADING: {
			ShareAlert(@"YouTube upload", @"Upload in progress");
			
		} break;
		case YOUTUBE_UPLOADER_STATE_UPLOAD_STOPPED: {
			ShareAlert(@"YouTube Upload erorr" , @"your upload has been stopped");
		} break;
			
		default:
			break;
	}
}


- (void) youTubeUploaderProgress:(float)progress {
	[[(MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate] mainViewController] setShareProgress:progress];
}



- (void)resetVersions {
	
	renderedVideoVersion = 0;
	exportedRingtoneVersion = 0;
}
						
				

#pragma mark actionSheet

- (void)menuWithView:(UIView *)view {
	
	
	
	UIActionSheet* sheet = [[[UIActionSheet alloc] init] autorelease];
	
	
	//sheet.title = @"Illustrations";
	sheet.delegate = self;
	
	
	
	[sheet addButtonWithTitle:@"Upload to YouTube"];
	[sheet addButtonWithTitle:@"Upload to FaceBook"];
	[sheet addButtonWithTitle:@"Add to Library"];

	if (canSendMail) {
		[sheet addButtonWithTitle:@"Send via mail"];
		[sheet addButtonWithTitle:@"Send ringtone"];
	}
	
	
	
	[sheet addButtonWithTitle:@"Done"];
	[sheet addButtonWithTitle:@"Render"];
	[sheet addButtonWithTitle:@"Play"];
	
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
		case 0: 
		case 1: {
			if ([self gotInternet]) {
				action = buttonIndex ? ACTION_UPLOAD_TO_FACEBOOK : ACTION_UPLOAD_TO_YOUTUBE;
			} else {
				ShareAlert(@"Upload Movie", @"No internet connection.");
				action = ACTION_DONE;
			}

			//action = self.isUploading ? ACTION_DONE : ACTION_UPLOAD_TO_YOUTUBE ;
			//action = self.isUploading ? ACTION_DONE :ACTION_UPLOAD_TO_FACEBOOK;
		} break;
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
			action = ACTION_DONE;
			break;
			
		case 6:
			action = ACTION_RENDER;
			break;
			
		case 7:
			action = ACTION_PLAY;
			break;
			
	}
	
	[self performSelector:@selector(action)];
	
}

- (void)cancel {
	state = STATE_CANCEL;
}

- (void)action {
	
	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate];

	
	switch (state) {
		case STATE_IDLE:
			switch (action) {
				case ACTION_DONE:
					break;
				case ACTION_UPLOAD_TO_YOUTUBE:
				case ACTION_UPLOAD_TO_FACEBOOK:
				case ACTION_ADD_TO_LIBRARY:
				case ACTION_SEND_VIA_MAIL:
				case ACTION_PLAY:
				case ACTION_RENDER:
					if (!self.videoRendered ) {
						state = STATE_RENDER_AUDIO;
						[[appDelegate mainViewController] renderAudio];
						return;
					} 
					break;
				case ACTION_SEND_RINGTONE:
					if (!self.ringtoneExported ) {
						state = STATE_RENDER_AUDIO;
						[[appDelegate mainViewController] renderAudio];
						return;
					} 
					break;
					
				default:
					break;
			}
			
			break;
			
		case STATE_RENDER_AUDIO:
			switch (action) {
				case ACTION_UPLOAD_TO_YOUTUBE:
				case ACTION_UPLOAD_TO_FACEBOOK:
				case ACTION_ADD_TO_LIBRARY:
				case ACTION_SEND_VIA_MAIL:
				case ACTION_PLAY:
				case ACTION_RENDER:
					state = STATE_RENDER_VIDEO;
					[[appDelegate mainViewController] renderVideo];
					return;
					break;
				case ACTION_SEND_RINGTONE:
					state = STATE_EXPORT_AUDIO;
					[[appDelegate mainViewController] exportRingtone];
					return;
					break;
				default:
					break;
			}
			break;
			
		case STATE_RENDER_VIDEO:
			[self setVideoRendered];
			break;
			
		case STATE_EXPORT_AUDIO: 
			[self setRingtoneExported];
			break;
			
		case STATE_CANCEL:
			return;
			break;

		default:
			break;
	}
	
	
	
		
	
	switch (action)
	{
		case ACTION_UPLOAD_TO_YOUTUBE: {
			
			YouTubeUploadViewController *controller = [[YouTubeUploadViewController alloc] initWithNibName:@"YouTubeUploadViewController" bundle:nil];
			[appDelegate pushViewController:controller];
			controller.uploader = appDelegate.shareManager.youTubeUploader;
			controller.videoTitle = [self getVideoTitle];
			controller.additionalText = kMilgromURL;
			controller.descriptionView.text = @"testing";
			controller.videoPath = [[self getVideoPath] stringByAppendingPathExtension:@"mov"];
			
			[controller release];
		}	break;
			
		case ACTION_UPLOAD_TO_FACEBOOK: {
			
			[facebookUploader login];
			FacebookUploadViewController * controller = [[FacebookUploadViewController alloc] initWithNibName:@"FacebookUploadViewController" bundle:nil];
			
			[appDelegate pushViewController:controller];
			controller.uploader = appDelegate.shareManager.facebookUploader;
			controller.videoTitle = [self getVideoTitle];
			controller.additionalText = kMilgromURL;
			controller.descriptionView.text = @"testing";
			controller.videoPath = [[self getVideoPath]  stringByAppendingPathExtension:@"mov" ];
			[controller release];
			
		}	break;
			
		case ACTION_ADD_TO_LIBRARY:
			[appDelegate mainViewController].view.userInteractionEnabled = YES; 
			[self exportToLibrary];
			break;
			
		case ACTION_SEND_VIA_MAIL: 
		{
			
			NSData *myData = [NSData dataWithContentsOfFile:[[self getVideoPath]  stringByAppendingPathExtension:@"mov"]];
			[self sendViaMailWithSubject:[self getVideoTitle] withData:myData withMimeType:@"video/mov" 
							withFileName:[[self getVideoName] stringByAppendingPathExtension:@"mov"]];
		} break;
			
		case ACTION_SEND_RINGTONE: 
		{
			
			NSData *myData = [NSData dataWithContentsOfFile:[[self getVideoPath]  stringByAppendingPathExtension:@"m4r"]];
			[self sendViaMailWithSubject:[self getVideoTitle] withData:myData withMimeType:@"audio/m4r" 
							withFileName:[[self getVideoName] stringByAppendingPathExtension:@"m4r"]];
		} break;
			
		case ACTION_PLAY:
			[appDelegate playURL:[NSURL fileURLWithPath:[[self getVideoPath] stringByAppendingPathExtension:@"mov"]]];
			break;
			
		case ACTION_DONE:
		case ACTION_RENDER:
			[appDelegate mainViewController].view.userInteractionEnabled = YES; 
			break;

	}	
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
												ShareAlert(@"Library", @"The video has been saved to your library");
										
											}
										});
										
									}];
	}
	[library release];
}



@end
