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
#import "Song.h"
#import "MilgromMacros.h"
#import "YouTubeUploadViewController.h"
#import "FacebookUploadViewController.h"

enum {
	ACTION_NONE,
	ACTION_UPLOAD_TO_YOUTUBE,
	ACTION_POST_ON_FACEBOOK,
	ACTION_UPLOAD_TO_FACEBOOK,
	ACTION_SEND_VIA_MAIL,
	ACTION_DONE,
	ACTION_RENDER,
	ACTION_PLAY
};

@interface ShareManager ()
- (void)action;
- (void)sendViaMail;
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
		
	}
	return self;
}

-(BOOL) isUploading {
	return facebookUploader.state == FACEBOOK_UPLOADER_STATE_UPLOAD_REQUESTED || facebookUploader.state == FACEBOOK_UPLOADER_STATE_UPLOADING || youTubeUploader.state == YOUTUBE_UPLOADER_STATE_UPLOAD_STARTED || youTubeUploader.state == YOUTUBE_UPLOADER_STATE_UPLOADING;
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
	
	return [[[paths objectAtIndex:0] stringByAppendingPathComponent:[self getVideoName]] stringByAppendingPathExtension:@".mov"];
}



#pragma mark mailClass


- (void)sendViaMail {
	
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil)
	{
		// We must always check whether the current device is configured for sending emails
		if ([mailClass canSendMail])
		{
			MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
			picker.mailComposeDelegate = self;
			
			[picker setSubject:[self getVideoName]];
			
			// Attach an video to the email
			//NSString *path = [[NSBundle mainBundle] pathForResource:@"video" ofType:@"png"];
			NSData *myData = [NSData dataWithContentsOfFile:[self getVideoPath]];
			[picker addAttachmentData:myData mimeType:@"video/mov" fileName:[[self getVideoName] stringByAppendingPathExtension:@"mov"]];
			
			
			
			
			//[picker setMessageBody:[self getMessage] isHTML:YES];
			[(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] presentModalViewController:picker animated:YES];
			//[self presentModalViewController:picker animated:YES];
			[picker release];
			
			
		}
		
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
	
	
	
	[sheet addButtonWithTitle:@"Send via mail"];
	
	
	
	[sheet addButtonWithTitle:@"Done"];
	[sheet addButtonWithTitle:@"Render"];
	[sheet addButtonWithTitle:@"Play"];
	
	sheet.actionSheetStyle = UIActionSheetStyleDefault;
	
	[sheet showInView:view];
	//sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
	
}


- (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	
	
	// Change the navigation bar style, also make the status bar match with it
	if (self.didUploadToFacebook && buttonIndex>0) { // no more facebook option
		buttonIndex++;
	}
	
	state = ACTION_NONE;
	
	
	
	switch (buttonIndex)
	{
		case 0: 
			
			state = self.isUploading ? ACTION_DONE : !self.didUploadToYouTube ? ACTION_UPLOAD_TO_YOUTUBE : ACTION_POST_ON_FACEBOOK;
			break;
		case 1:
			state = self.isUploading ? ACTION_DONE :ACTION_UPLOAD_TO_FACEBOOK;
			break;
			
		case 2:
			state = ACTION_SEND_VIA_MAIL;
			break;
			
		case 3:
			state = ACTION_DONE;
			break;
			
		case 4:
			
			break;
			
		case 5:
			state = ACTION_PLAY;
			break;
			
	}
	
	switch (state) {
		case ACTION_DONE:
			//			[(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] popViewController];
			break;
			
		default:
			if (!self.hasBeenRendered ) {
				[[(MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate] mainViewController] performSelector:@selector(render)];
			} else {
				[self performSelector:@selector(action)];
			}
			
			break;
	}
	
}



- (void)action {
	
	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	
	switch (state)
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
			
			
			FacebookUploadViewController * controller = [[FacebookUploadViewController alloc] initWithNibName:@"FacebookUploadViewController" bundle:nil];
			
			[appDelegate pushViewController:controller];
			controller.uploader = appDelegate.shareManager.facebookUploader;
			controller.videoTitle = [self getVideoName];
			controller.descriptionView.text = @"testing";
			controller.videoPath = [self getVideoPath];
			[controller release];
			
		}	break;
			
		case ACTION_SEND_VIA_MAIL:
			[self sendViaMail];
			break;
			
		case ACTION_PLAY:
			[appDelegate play];
			break;
	}	
}



@end
