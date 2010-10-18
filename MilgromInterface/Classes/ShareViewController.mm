//
//  ShareViewController.mm
//  Milgrom
//
//  Created by Roee Kremer on 8/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "ShareViewController.h"
#import "MilgromInterfaceAppDelegate.h"
#import "MilgromViewController.h"

#import "testApp.h"
#import "Constants.h"


//#import "ActionCell.h"
//#import "CustomFontLabel.h"
#import "CustomImageView.h"
#import "MilgromMacros.h"
#import "Song.h"

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

@interface ShareViewController ()
//- (void) export;	
//- (void)exportDidFinish;
//- (void)updateExportProgress:(AVAssetExportSession *)theSession;
- (void)render;
- (void)action;
- (void)sendViaMail;
@end

@implementation ShareViewController


@synthesize progressView;
@synthesize renderingView;



/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder: decoder]) {
		
		
	}
	
	return self;
}
 */

- (void)prepare {
	
	isTemporary =  [(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] isSongTemporary];

	if (isTemporary) {
		_didUploadToYouTube = NO;
		_didUploadToFacebook = NO;
		_hasBeenRendered = NO;
		
	}
}

- (BOOL)hasBeenRendered {
	if (isTemporary) {
		return _hasBeenRendered;
	} else {
		Song * song = [(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] currentSong];
		return [song.bExported boolValue];
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



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.progressView.image =  [UIImage imageNamed:@"CELL1_PROGRESS.png"];
	self.navigationController.delegate = self;
	
	//self.dataSourceArray = [NSArray arrayWithObjects: @"Email",@"YouTube",@"FaceBook",@"Play",@"Render",@"Done",nil];
								
	
}

/*
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	MilgromLog(@"ShareViewController - navigationController didShowViewController");
	
}
*/
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated]; 
	MilgromLog(@"ShareViewController::viewWillAppear");
	
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated]; 
	MilgromLog(@"ShareViewController::viewDidAppear");
	[self menu];
	
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;//interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	//self.dataSourceArray = nil;	// this will release and set to nil
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	//[dataSourceArray release];
	
    [super dealloc];
}

- (NSNumber *)progress {
	return [NSNumber numberWithFloat:0];
}

- (void) setProgress:(NSNumber *)theProgress {
	[progressView setRect:CGRectMake(0, 0, [theProgress floatValue],1.0f)];
}



- (void)render {
	
	[self setProgress:[NSNumber numberWithFloat:0.0f]];
	
	
	[self action];

	
}

/*
- (void) export {
	
	self.progress = [NSNumber numberWithFloat:0.0f];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *exportPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"video.mov"];
	
	NSError *error;
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath]) {
		if (![[NSFileManager defaultManager] removeItemAtPath:exportPath error:&error]) {
			NSLog(@"removeItemAtPath error: %@",[error description]);
		}
	}
	
	AVAssetExportSession * session = [OpenGLTOMovie exportToURL:[NSURL fileURLWithPath:exportPath]
				  withVideoURL:[NSURL fileURLWithPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"temp.mov"]] 
				  withAudioURL: [NSURL fileURLWithPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"temp.wav"]] //[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"temp" ofType:@"wav"]]
	 
		   withProgressHandler:nil
	 
//			^(float progress) {
//			   dispatch_async(dispatch_get_main_queue(),^{
//				   [self setProgress:[NSNumber numberWithFloat:progress]];
//				   NSLog(@"progress: %f",progress);
//			   });
//			}
		 withCompletionHandler:^ {
			 [self exportDidFinish];
		 }
	 ];
	
	NSArray *modes = [[[NSArray alloc] initWithObjects:NSDefaultRunLoopMode, UITrackingRunLoopMode, nil] autorelease];
	[self performSelector:@selector(updateExportProgress:) withObject:session	afterDelay:0.1 inModes:modes];
	
	NSLog(@"export end");
	
}


- (void)updateExportProgress:(AVAssetExportSession *)theSession
{
	
	if ([theSession status]==AVAssetExportSessionStatusExporting) {
		
		self.progress = [NSNumber numberWithFloat:[theSession progress]];
		NSArray *modes = [[[NSArray alloc] initWithObjects:NSDefaultRunLoopMode, UITrackingRunLoopMode, nil] autorelease];
		[self performSelector:@selector(updateExportProgress:) withObject:theSession afterDelay:0.1 inModes:modes];
	} else {
		self.progress = [NSNumber numberWithFloat:1.0f];
	}
	
	
	
}

- (void)exportDidFinish {
	MilgromViewController * milgromViewController = ((MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate]).milgromViewController;
	testApp *OFSAptr = ((MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate]).OFSAptr;
	
	OFSAptr->setSongState(SONG_IDLE);
	OFSAptr->soundStreamStart();
	[milgromViewController startAnimation];
	
	
	NSLog(@"exportDidFinish");
	
}
*/
- (void)menu {
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
	
	[sheet showInView:self.view];
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
			state = !self.didUploadToYouTube ? ACTION_UPLOAD_TO_YOUTUBE : ACTION_POST_ON_FACEBOOK;
			break;
		case 1:
			state = ACTION_UPLOAD_TO_FACEBOOK;
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
			[(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] popViewController];
			break;
		
		default:
			if (!self.hasBeenRendered ) {
				[self performSelector:@selector(render)];
			} else {
				[self performSelector:@selector(action)];
			}

			break;
	}

}


							
- (void)action {
	
	switch (state)
	{
		case ACTION_UPLOAD_TO_YOUTUBE:
			
						
			break;
	
		case ACTION_UPLOAD_TO_FACEBOOK:
			break;
		
		case ACTION_SEND_VIA_MAIL:
			[self sendViaMail];
			break;
	
		case ACTION_PLAY:
			[(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] play];
			break;
		default: 
			[self menu];
			break;
	}	
}


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


/*
// to determine which UITableViewCell to be used on a given row.
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
		
	
	static NSString *CellIdentifier = @"Cell";
    
	
	ActionCell *cell = (ActionCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"ActionCell" owner:self options:nil];
        cell = tmpCell;
        self.tmpCell = nil;
    }
	
	cell.label.text = [self.dataSourceArray objectAtIndex: indexPath.row];

	
	return cell;
}
*/



@end
