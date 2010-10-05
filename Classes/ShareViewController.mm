//
//  ShareViewController.mm
//  Milgrom
//
//  Created by Roee Kremer on 8/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ShareViewController.h"
#import "CustomImageView.h"
#import "OpenGLTOMovie.h"
#import "testApp.h"
#import "Constants.h"
#import "MilgromInterfaceAppDelegate.h"
#import "MilgromViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ActionCell.h"
#import "CustomFontLabel.h"

@interface ShareViewController ()
- (void) export;	
- (void)exportDidFinish;
- (void)updateExportProgress:(AVAssetExportSession *)theSession;
@end

@implementation ShareViewController

@synthesize tmpCell;
@synthesize dataSourceArray;
@synthesize progressView;
@synthesize bRender;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder: decoder]) {
		bRender = NO;
	}
	
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.progressView.image =  [UIImage imageNamed:@"CELL1_PROGRESS.png"];
	self.navigationController.delegate = self;
	
	self.dataSourceArray = [NSArray arrayWithObjects: @"Email",@"YouTube",@"FaceBook",@"Play",@"Render",@"Done",nil];
								
	
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	if (bRender) {
		bRender = NO;
		
		
		bFaceBookUploaded = NO;
		bYouTubeUploaded = NO;
		//[self action];
	}
}
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.dataSourceArray = nil;	// this will release and set to nil
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[dataSourceArray release];
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
	
	MilgromViewController * milgromViewController = ((MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate]).milgromViewController;
	testApp *OFSAptr = ((MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate]).OFSAptr;
	
	[milgromViewController stopAnimation];
	OFSAptr->soundStreamStop();

	dispatch_queue_t myCustomQueue;
	myCustomQueue = dispatch_queue_create("renderQueue", NULL);
	
	dispatch_async(myCustomQueue, ^{
				
		OFSAptr->renderAudio();
		OFSAptr->setSongState(SONG_RENDER_VIDEO);
		
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *videoPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"temp.mov"];
		
		
		
		[OpenGLTOMovie writeToVideoURL:[NSURL fileURLWithPath:videoPath] WithSize:CGSizeMake(480, 320) 
		 
						 withDrawFrame:^(int frameNum) {
							 //NSLog(@"rendering frame: %i",frameNum);
							 [milgromViewController drawFrame];
							 [self setProgress:[NSNumber numberWithFloat:OFSAptr->getPlayhead()]];
							 // TODO: playhead is only by DRM
							 
						 }
		 
						 withDidFinish:^(int frameNum) {
							 return (int)(OFSAptr->getSongState()!=SONG_RENDER_VIDEO);
						 }
		 
				 withCompletionHandler:^ {
					 NSLog(@"write completed");
					 [self export];
					 
				 }];
	});
	
	
	dispatch_release(myCustomQueue);
	
	
}

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

- (void)action {
	UIActionSheet* sheet = [[[UIActionSheet alloc] init] autorelease];
	//sheet.title = @"Illustrations";
	sheet.delegate = self;
	[sheet addButtonWithTitle:@"Email"];
	
	if (bYouTubeUploaded) {
		[sheet addButtonWithTitle:@"Email youtube feed"];
	} else {
		[sheet addButtonWithTitle:@"Upload to YouTube"];
	}
	
	if (bFaceBookUploaded) {
		[sheet addButtonWithTitle:@"Email facebook feed"];
	} else {
		[sheet addButtonWithTitle:@"Upload to FaceBook"];
	}
	
	[sheet addButtonWithTitle:@"Play"];
	[sheet addButtonWithTitle:@"Render"];
	[sheet addButtonWithTitle:@"Done"];
	
	sheet.actionSheetStyle = UIActionSheetStyleDefault;
	
	[sheet showInView:self.view];
	//sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
	
}

- (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Change the navigation bar style, also make the status bar match with it
    switch (buttonIndex)
    {
        case 0:
        {
           
            break;
        }
        case 1:
        {
            if (bYouTubeUploaded) {
				
			} else {
				
			}
            break;
        }
        case 2:
        {
            [(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] youTubeUpload];
            break;
        }
		case 3:
        {
            [(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] play];
            break;
        }
		case 4:
        {
            [self render];
            break;
        }
		case 5:
        {
            
			[(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] pop];
            break;
        }
			
    }
}


- (void)done:(id)sender {
	//[(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] dismissModalViewControllerAnimated:YES];
	[(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] pop];
}

- (void)youTube:(id)sender {
	//[(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] dismissModalViewControllerAnimated:YES];
	[(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] youTubeUpload];
}

- (void)play:(id)sender {
	//[(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] dismissModalViewControllerAnimated:YES];
	[(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] play];
}


#pragma mark -
#pragma mark - UITableView delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.dataSourceArray count];
}



// the table's selection has changed, show the alert or action sheet
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// deselect the current row (don't keep the table selection persistent)
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
	
	
	switch (indexPath.row)
	{
		case 0:
		{
			
			break;
		}
		case 1:
		{
			if (bYouTubeUploaded) {
				
			} else {
				
			}
			break;
		}
		case 2:
		{
			[(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] youTubeUpload];
			break;
		}
		case 3:
		{
			[(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] play];
			break;
		}
		case 4:
		{
			[self render];
			break;
		}
		case 5:
		{
			
			[(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] pop];
			break;
		}
	}
}

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




@end
