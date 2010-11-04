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
#import "ExportManager.h"
#import "testApp.h"

enum {
	STATE_IDLE,
	STATE_RENDER_AUDIO,
	STATE_EXPORT_AUDIO,
	STATE_RENDER_VIDEO,
	STATE_CANCELED
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

@interface ShareManager ()
- (void)action;
- (void)sendViaMailWithSubject:(NSString *)subject withData:(NSData *)data withMimeType:(NSString*) mimeType withFileName:(NSString*)fileName;
- (void)export;
- (void)updateExportProgress:(ExportManager*)manager;
- (void)exportDidFinish;
- (void)exportToLibrary;

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
		
		
	}
	return self;
}

- (void)prepare {
	
}

-(BOOL) isUploading {
	return facebookUploader.state == FACEBOOK_UPLOADER_STATE_UPLOADING || youTubeUploader.state == YOUTUBE_UPLOADER_STATE_UPLOAD_STARTED || youTubeUploader.state == YOUTUBE_UPLOADER_STATE_UPLOADING;
}


- (void)setRendered {
	if (isTemporary) {
		_hasBeenRendered = YES;
	} else {
		MilgromInterfaceAppDelegate * appDelegate = (MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate];
		Song * song = [appDelegate currentSong];
		[song setBRendered:[NSNumber numberWithBool:YES]];
		[appDelegate saveContext];
		
	}
	
}


- (BOOL)hasBeenRendered {
	if (isTemporary) {
		return _hasBeenRendered;
	} else {
		Song * song = [(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] currentSong];
		return [song.bRendered boolValue];
	}
	
}

- (BOOL)didUploadToYouTube {
	if (isTemporary) {
		return _didUploadToYouTube;
	} else {
		//Song * song = [(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] currentSong];
		return NO;
	}
}

- (BOOL)didUploadToFacebook {
	if (isTemporary) {
		return _didUploadToFacebook;
	} else {
		//Song * song = [(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] currentSong];
		return NO;
	}
}



- (NSString *)getVideoName {
	if (isTemporary) {
		return @"milgrom";
	} else {
		Song * song = [(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] currentSong];
		return [song songName];
	}
}

- (NSString *)getVideoPath {
	
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	if (!documentsDirectory) {
		MilgromLog(@"Documents directory not found!");
		return @"";
	}
	
	return [[[paths objectAtIndex:0] stringByAppendingPathComponent:[self getVideoName]] stringByAppendingPathExtension:@"mov"];
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
		
		//[picker setMessageBody:[self getMessage] isHTML:YES];
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
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook upload" 
															message:@"your upload finished"
														   delegate:nil  cancelButtonTitle:@"OK"  otherButtonTitles: nil];
			[alert show];
			[alert release];
		} break;
		case FACEBOOK_UPLOADER_STATE_UPLOADING: {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook upload" message:@"Upload in progress"
														   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
			[alert show];
			[alert release];
			
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
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"YouTube upload" 
															message:[NSString stringWithFormat:@"your upload finished. link: %@",[theUploader.link absoluteString]]
														   delegate:nil  cancelButtonTitle:@"OK"  otherButtonTitles: nil];
			[alert show];
			[alert release];
		} break;
		case YOUTUBE_UPLOADER_STATE_UPLOADING: {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"YouTube upload" message:@"Upload in progress"
														   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
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





#pragma mark actionSheet

- (void)menuWithView:(UIView *)view {
	
	
	isTemporary =  [(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] isSongTemporary];
	
	if (isTemporary) {
		_didUploadToYouTube = NO;
		_didUploadToFacebook = NO;
		_hasBeenRendered = NO;
		
	}
	
	UIActionSheet* sheet = [[[UIActionSheet alloc] init] autorelease];
	
	
	//sheet.title = @"Illustrations";
	sheet.delegate = self;
	
	
	if (!self.didUploadToYouTube) {
		[sheet addButtonWithTitle:@"Upload to YouTube"];
		
	} else {
		[sheet addButtonWithTitle:@"Post on facebook"];
	}
	
	if (!self.didUploadToFacebook) {
		[sheet addButtonWithTitle:@"Upload to FaceBook"];
	}
	
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
	if (self.didUploadToFacebook && buttonIndex>0) { // no more facebook option
		buttonIndex++;
	}
	
	if (!canSendMail && buttonIndex>3) { // skip send mail result (2)
		buttonIndex+=2;
	}
	
	
	switch (buttonIndex)
	{
		case 0: 
			
			action = self.isUploading ? ACTION_DONE : ACTION_UPLOAD_TO_YOUTUBE ;
			break;
		case 1:
			action = self.isUploading ? ACTION_DONE :ACTION_UPLOAD_TO_FACEBOOK;
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
			action = ACTION_DONE;
			break;
			
		case 6:
			
			break;
			
		case 7:
			action = ACTION_PLAY;
			break;
			
	}
	
	[self performSelector:@selector(action)];
	
}

- (void)cancel {
	state = STATE_CANCELED;
}

- (void)action {
	
	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate];

	
	switch (state) {
		case STATE_IDLE:
			switch (action) {
				case ACTION_DONE:
					break;
				default:
					if (!self.hasBeenRendered ) {
						state = STATE_RENDER_AUDIO;
						[[appDelegate mainViewController] renderAudio];
						return;
					} 
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
					state = STATE_RENDER_VIDEO;
					[[appDelegate mainViewController] renderVideo];
					return;
					break;
				case ACTION_SEND_RINGTONE:
					[self export];
					return;
					break;
				default:
					break;
			}
			break;
			
		case STATE_CANCELED:
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
			controller.videoTitle = [self getVideoName];
			controller.descriptionView.text = @"testing";
			controller.videoPath = [self getVideoPath];
			
			[controller release];
		}	break;
			
		case ACTION_UPLOAD_TO_FACEBOOK: {
			
			[facebookUploader login];
			FacebookUploadViewController * controller = [[FacebookUploadViewController alloc] initWithNibName:@"FacebookUploadViewController" bundle:nil];
			
			[appDelegate pushViewController:controller];
			controller.uploader = appDelegate.shareManager.facebookUploader;
			controller.videoTitle = [self getVideoName];
			controller.descriptionView.text = @"testing";
			controller.videoPath = [self getVideoPath];
			[controller release];
			
		}	break;
			
		case ACTION_ADD_TO_LIBRARY:
			[self exportToLibrary];
			break;
			
		case ACTION_SEND_VIA_MAIL: 
		{
			
			NSData *myData = [NSData dataWithContentsOfFile:[self getVideoPath]];
			[self sendViaMailWithSubject:[self getVideoName] withData:myData withMimeType:@"video/mov" 
							withFileName:[[self getVideoName] stringByAppendingPathExtension:@"mov"]];
		} break;
			
		case ACTION_SEND_RINGTONE: 
		{
			
			NSString *filename = [[self getVideoName] stringByAppendingPathExtension:@"m4r"];
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSData *myData = [NSData dataWithContentsOfFile:[[paths objectAtIndex:0] stringByAppendingPathComponent:filename]];
			[self sendViaMailWithSubject:[self getVideoName] withData:myData withMimeType:@"audio/m4r" 
							withFileName:filename];
		} break;
			
		case ACTION_PLAY:
			[appDelegate play];
			break;
	}	
}


- (void)export {
	
	//renderingView.hidden = NO;
	//[self setRenderProgress:0.0f];
	
	((MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate]).OFSAptr->soundStreamStop();
	
	//ShareManager *shareManager = [(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] shareManager];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	ExportManager *manager = [ExportManager  exportAudio:[NSURL fileURLWithPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"temp.wav"]]
							  
												   toURL:[NSURL fileURLWithPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:[[self getVideoName] stringByAppendingPathExtension:@"m4r"]]]
							  
							  
								   withCompletionHandler:^ {
									   NSLog(@"export completed");
									   
									   [self exportDidFinish];
								   }];
	
	NSArray *modes = [[NSArray alloc] initWithObjects:NSDefaultRunLoopMode, UITrackingRunLoopMode, nil];
	[self performSelector:@selector(updateExportProgress:) withObject:manager afterDelay:0.5 inModes:modes];
	
	
}



- (void)updateExportProgress:(ExportManager*)manager
{
	
	if (!manager.didFinish) {
		//[self setRenderProgress:manager.progress];
		NSLog(@"export audio, progrss: %2.2f",manager.progress);
		
		NSArray *modes = [[[NSArray alloc] initWithObjects:NSDefaultRunLoopMode, UITrackingRunLoopMode, nil] autorelease];
		[self performSelector:@selector(updateExportProgress:) withObject:manager afterDelay:0.5 inModes:modes];
	}
}


- (void)exportDidFinish {
	((MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate]).OFSAptr->soundStreamStart();
	[self action];
	//[[(MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate] shareManager] menuWithView:self.view];
	
}



- (void)exportToLibrary
{
	NSURL *outputURL = [NSURL fileURLWithPath:[self getVideoPath]];
	ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
	if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
		[library writeVideoAtPathToSavedPhotosAlbum:outputURL
									completionBlock:^(NSURL *assetURL, NSError *error){
										dispatch_async(dispatch_get_main_queue(), ^{
											if (error) {
												NSLog(@"writeVideoToAssestsLibrary failed: %@", error);
												UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
																									message:[error localizedRecoverySuggestion]
																								   delegate:nil
																						  cancelButtonTitle:@"OK"
																						  otherButtonTitles:nil];
												[alertView show];
												[alertView release];
											}
											else {
												//_showSavedVideoToAssestsLibrary = YES;
												
											}
										});
										
									}];
	}
	[library release];
}



@end
