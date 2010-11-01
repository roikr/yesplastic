//
//  MainViewController.mm
//  YesPlastic
//
//  Created by Roee Kremer on 2/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"


#include "Constants.h"
#include "testApp.h"

#import "MilgromInterfaceAppDelegate.h"
#import "MilgromViewController.h"
#import "TouchView.h"
#import "MilgromMacros.h"
#import "SaveViewController.h"
#import "Song.h"
#import "CustomImageView.h"
#import "ShareManager.h"
#import "OpenGLTOMovie.h"


@interface MainViewController() 

- (void) fadeOutRecordButton;
- (void) fadeInRecordButton;

- (void)renderAudio;
- (void)updateRenderProgress;
- (void)renderAudioDidFinish;
- (void)render;


@end

@implementation MainViewController

@synthesize playButton;
@synthesize stopButton;
@synthesize recordButton;
@synthesize menuButton;
@synthesize setMenuButton;
@synthesize saveButton;
@synthesize shareButton;
@synthesize infoButton;
@synthesize triggersView;
@synthesize loopsView;
@synthesize bandLoopsView;
@synthesize bandHelp;
@synthesize soloHelp;
@synthesize bShowHelp;
@synthesize renderView;
@synthesize interactionView;


//@synthesize triggerButton;
//@synthesize loopButton;
@synthesize saveViewController;
@synthesize shareProgressView;
@synthesize renderProgressView;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
		
	
	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
	OFSAptr = appDelegate.OFSAptr;
	
	[(TouchView*)self.view  setViewController:self];
	bShowHelp = NO;
	bAnimatingRecord = NO;
	
	self.shareProgressView.image =  [UIImage imageNamed:@"SHARE_B_BACKGROUND.png"];
	self.renderProgressView.image =  [UIImage imageNamed:@"CELL1_PROGRESS.png"];
	
	//[self.view addSubview:menuController.view];
	//menuController.view.hidden = YES;
	
	/*
	for (unsigned i = 0; i < 3; i++) {
		PlayerMenu *controller = [playerControllers objectAtIndex:i];
		[self.view addSubview:controller.view];
		controller.view.hidden = YES;
	} 
	 */
	 
	
	
	for (int i=0; i<8; i++) {
		//[[NSBundle mainBundle] loadNibNamed:@"LoopButton" owner:self options:nil];
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		[button addTarget:self action:@selector(loop:) forControlEvents:UIControlEventTouchDown];
		//self.loopButton = nil;
		[loopsView addSubview:button];
		
		//CGRect frame = button.frame;
		CGRect frame;
		frame.origin.x = (i % 4)*80+5;
		frame.origin.y = (int)(i/4) * 60;
		frame.size.width = 70;
		frame.size.height = 60;
		button.frame = frame;
		button.tag = i;
	}
	
	for (int i=0; i<8; i++) {
		//[[NSBundle mainBundle] loadNibNamed:@"TriggerButton" owner:self options:nil];
		//UIButton *button = triggerButton;
		//self.triggerButton = nil;
		
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		[button addTarget:self action:@selector(trigger:) forControlEvents:UIControlEventTouchDown];
		[triggersView addSubview:button];
		
		//CGRect frame = button.frame;
		CGRect frame;
		frame.origin.x = (i % 4)*80+5;
		frame.origin.y = (int)(i/4) * 60;
		frame.size.width = 70;
		frame.size.height = 60;
		button.frame = frame;
		button.tag = i;
	}
	
	
	
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
	//!bMenuMode
	return YES;	
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	switch (toInterfaceOrientation) {
		case UIInterfaceOrientationPortrait:
		case UIInterfaceOrientationPortraitUpsideDown:
			
			OFSAptr->setState(SOLO_STATE);
			break;
		case UIInterfaceOrientationLandscapeRight:
		case UIInterfaceOrientationLandscapeLeft:
			OFSAptr->setState(BAND_STATE);
			break;
		default:
			break;
	}
	
	triggersView.hidden = YES;
	loopsView.hidden = YES;
	bandLoopsView.hidden = YES;
	menuButton.hidden = YES;
	setMenuButton.hidden = YES;
	bandHelp.hidden = YES;
	soloHelp.hidden = YES;
	
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	[self updateViews];
	
}




- (void)updateViews {
	
	if (self.navigationController.topViewController != self) {
		return;
	}
	
	playButton.hidden = YES;
	recordButton.hidden = YES;
	stopButton.hidden = YES;
	menuButton.hidden = YES;
	setMenuButton.hidden = YES;
	saveButton.hidden = YES;
	loopsView.hidden = YES;
	triggersView.hidden = YES;
	bandLoopsView.hidden = YES;
	bandHelp.hidden = YES;
	soloHelp.hidden = YES;
	recordButton.selected = OFSAptr->getSongState() == SONG_TRIGGER_RECORD || OFSAptr->getSongState() == SONG_RECORD;
	shareButton.hidden = YES;
	infoButton.hidden = YES;
	renderView.hidden = YES;
	
	if (![[(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] shareManager] isUploading]) {
		[self setShareProgress:1.0f];
	}
	
	if (!OFSAptr->isInTransition()) {
		switch (OFSAptr->getSongState()) {
			case SONG_IDLE:
			case SONG_RECORD:
			case SONG_TRIGGER_RECORD:
				playButton.hidden = NO;
				
				
				switch (OFSAptr->getState()) {
					case SOLO_STATE: {
						setMenuButton.hidden = OFSAptr->getSongState() != SONG_IDLE;
						NSString *setButton = [NSString stringWithFormat:@"%@_SET_B.png",[NSString stringWithCString:OFSAptr->getPlayerName(OFSAptr->controller).c_str() encoding:NSASCIIStringEncoding]];
						[setMenuButton setImage:[UIImage imageNamed:setButton] forState:UIControlStateNormal];
						
						switch (OFSAptr->getMode(OFSAptr->controller)) {
							case LOOP_MODE: {
								loopsView.hidden = NO;
								NSString *selected = [NSString stringWithFormat:@"%@_LOOP_P.png",[NSString stringWithCString:OFSAptr->getPlayerName(OFSAptr->controller).c_str() encoding:NSASCIIStringEncoding]];
								
								UIButton *button;
								for (int i=0; i<[loopsView.subviews count]; i++) {
									button = (UIButton*)[loopsView.subviews objectAtIndex:i];
									
									NSString *normal = [NSString stringWithFormat:@"%@_LOOP_%i.png",[NSString stringWithCString:OFSAptr->getPlayerName(OFSAptr->controller).c_str() encoding:NSASCIIStringEncoding],i+1];
									[button setImage:[UIImage imageNamed:normal] forState:UIControlStateNormal];
									[button setImage:[UIImage imageNamed:selected] forState:UIControlStateSelected];

									button.selected = button.tag == OFSAptr->getCurrentLoop(OFSAptr->controller);
								}
								
							} break;
							case MANUAL_MODE: {
								triggersView.hidden = NO;
								
								UIButton *button;
								for (int i=0; i<[triggersView.subviews count]; i++) {
									button = (UIButton*)[triggersView.subviews objectAtIndex:i];
									
									NSString *normal = [NSString stringWithFormat:@"%@_TB_%i.png",[NSString stringWithCString:OFSAptr->getPlayerName(OFSAptr->controller).c_str() encoding:NSASCIIStringEncoding],i+1];
									[button setImage:[UIImage imageNamed:normal] forState:UIControlStateNormal];
									NSString *highlighted = [NSString stringWithFormat:@"%@_TB_%i_P.png",[NSString stringWithCString:OFSAptr->getPlayerName(OFSAptr->controller).c_str() encoding:NSASCIIStringEncoding],i+1];
									[button setImage:[UIImage imageNamed:highlighted] forState:UIControlStateHighlighted];
									
								}
							} break;
							default:
								break;
						}
						
						soloHelp.hidden = !bShowHelp;
						
					} break;
					case BAND_STATE: {
						menuButton.hidden = NO;
						bandLoopsView.hidden = NO;
						bandHelp.hidden = !bShowHelp;
					} break;
					default:
						break;
				}
				
								
				break;	
				
			case SONG_PLAY:
		
				stopButton.hidden = NO;
				
				break;
			
				
			case SONG_RENDER_VIDEO:
			case SONG_RENDER_AUDIO:
				renderView.hidden = NO;
				break;
			default:
				break;
		
		}
		
		saveButton.hidden = ![(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] canSave];
		shareButton.hidden = ![(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] canShare];

		recordButton.hidden = NO;
		infoButton.hidden = NO; // OFSAptr->getSongState() != SONG_IDLE;
		
		if (!bAnimatingRecord && OFSAptr->getSongState() == SONG_RECORD) {
			bAnimatingRecord = YES;
			[self fadeOutRecordButton];
		}
		
	}
		
}



- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}






- (void) menu:(id)sender {
	
	if (OFSAptr->getSongState()==SONG_RECORD ) {
		OFSAptr->setSongState(SONG_IDLE);
	}
	
	switch (OFSAptr->getState()) {
		case SOLO_STATE: 
			[(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] pushSetMenu]; 
			break;
			
		case BAND_STATE: {
			OFSAptr->stopLoops();
			[(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] popViewController]; 
			//[self.navigationController popViewControllerAnimated:YES];
			//[self presentModalViewController:menuController animated:YES];
			//menuController.view.hidden = NO;
		} break;

		default:
			break;
	}
	
}



- (void) play:(id)sender {
	
		
	if (recordButton.selected) {
		[self stop:nil];
	}
		
	if (OFSAptr->isSongValid()) {
		OFSAptr->setSongState(SONG_PLAY);
	}
	
	
	
}

- (void) stop:(id)sender {
	
	OFSAptr->setSongState(SONG_IDLE);
}

- (void) record:(id)sender {
	
	
	if (playButton.hidden) 
		return;
	
	
	if (recordButton.selected) {
		[self stop:nil];
	}
	else {
		OFSAptr->setSongState(SONG_TRIGGER_RECORD);
		
	}
}

- (void) fadeOutRecordButton {
	if (OFSAptr->getSongState() == SONG_RECORD) {
		//[UIView animateWithDuration:0.2 animations:^{recordButton.alpha = 0.0;} completion:^(BOOL finished){ [self fadeInRecordButton]; }];
		[UIView animateWithDuration:0.1 delay:0.5 
							options: UIViewAnimationOptionTransitionNone | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction// UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse |
						 animations:^{recordButton.imageView.alpha = 0.0;} 
						 completion:^(BOOL finished){ [self fadeInRecordButton]; }];
		
		
	} else {
		bAnimatingRecord = NO;
	}

	
}

- (void) fadeInRecordButton {
	if (OFSAptr->getSongState() != SONG_RECORD) {
		recordButton.imageView.alpha = 1.0;
		bAnimatingRecord = NO;
	} else {
		[UIView animateWithDuration:0.1 delay:0.5 
						options: UIViewAnimationOptionTransitionNone | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction// UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse |
					 animations:^{recordButton.imageView.alpha = 1.0;} 
					 completion:^(BOOL finished){ [self fadeOutRecordButton]; }];
	}
}

- (void) save:(id)sender {
	
	OFSAptr->setSongState(SONG_IDLE);
	
	
	if (self.saveViewController == nil) {
		self.saveViewController = [[SaveViewController alloc] initWithNibName:@"SaveViewController" bundle:nil];
		saveViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	}
	
	
	[(MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate] presentModalViewController:self.saveViewController animated:YES];
	
}



	




		
/*
- (void) updateTables {
	//[menuController.tableView reloadData]; // TODO:  what is this ? uncomment !
	
	for (unsigned i = 0; i < 3; i++) {
		PlayerMenu *controller = [PlayerMenu objectAtIndex:i];
		[controller.tableView reloadData];
	}
	
}
*/

- (void) trigger:(id)sender {
	
	UIButton *button = (UIButton*)sender;
	OFSAptr->buttonPressed(button.tag);
	
	
	
//	if (button.tag == 7) {
//		triggersView.hidden = YES;
//		loopsView.hidden = NO;
//	}
		
}

- (void) loop:(id)sender {
	UIButton *button;
//	for (int i=0; i<[loopsView.subviews count]; i++) {
//		button = (UIButton*)[loopsView.subviews objectAtIndex:i];
//		button.selected = NO;
//	}
	button = (UIButton*)sender;
	OFSAptr->buttonPressed(button.tag);
	
//	if (button.tag == 7) {
//		triggersView.hidden = NO;
//		loopsView.hidden = YES;
//	}
	
}

//- (void)updateLoops:(id)sender {
//	UIButton *button = (UIButton*)sender;
//	
//	button.selected = YES;
//}

- (void) nextLoop:(id)sender {
	
	UIButton *button = (UIButton*)sender;
	OFSAptr->nextLoop(button.tag);
	
}

- (void) prevLoop:(id)sender {
	
	UIButton *button = (UIButton*)sender;
	OFSAptr->prevLoop(button.tag);
}


- (void) showHelp:(id)sender {
	switch (OFSAptr->getSongState()) {
		case SONG_IDLE:
			bShowHelp = YES;
			self.interactionView.userInteractionEnabled = NO;
			[self updateViews];
			break;
		case SONG_RECORD:
			bShowHelp = YES;
			self.interactionView.userInteractionEnabled = NO;
			OFSAptr->setSongState(SONG_IDLE);
			
			break;
		default:
			break;
	}
	
	
}

- (void)hideHelp {
	
	
	bShowHelp = NO;
	self.interactionView.userInteractionEnabled = YES;
	[self updateViews];
	
}

- (void) moreHelp:(id)sender {
	[self hideHelp];
	[(MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate] help];
}


- (void)dealloc {
	[saveViewController release];
    [super dealloc];
}




- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	MilgromLog(@"MainViewController::viewDidAppear");
    [self becomeFirstResponder];
	
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	MilgromLog(@"MainViewController::viewWillAppear");
	[self updateViews];
}



- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	MilgromLog(@"shake began");
	shakeStartTime = [NSDate timeIntervalSinceReferenceDate];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
	NSTimeInterval diff = [NSDate timeIntervalSinceReferenceDate]-shakeStartTime;
	MilgromLog(@"shake ended: %2.2f",diff);
	if ( diff > 0.5 && diff < 1.0) {
		OFSAptr->playRandomLoop();
	}
}

#pragma mark Render && Share

- (void) setShareProgress:(float) progress {
	[shareProgressView setRect:CGRectMake(0, 1.0-progress, 1.0f,progress)];
}

- (void)share:(id)sender {
	
	[[(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] shareManager] prepare];
	OFSAptr->setSongState(SONG_IDLE);
	[self renderAudio];
	// BUG FIX: this is very important: don't present from milgromViewController as it will result in crash when returning to BandView after share
	
}


- (void) setRenderProgress:(float) progress {
	[renderProgressView setRect:CGRectMake(0.0f, 0.0f,progress,1.0f)];
}


- (void)renderAudio {
	[self setRenderProgress:0.0f];
	
	dispatch_queue_t myCustomQueue;
	myCustomQueue = dispatch_queue_create("renderAudioQueue", NULL);
	
	//[milgromViewController stopAnimation];
	OFSAptr->soundStreamStop();
	
	dispatch_async(myCustomQueue, ^{
		
		OFSAptr->renderAudio();
		
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self renderAudioDidFinish];
		});
		
		
	});
	
	dispatch_release(myCustomQueue);
	
	NSArray *modes = [[[NSArray alloc] initWithObjects:NSDefaultRunLoopMode, UITrackingRunLoopMode, nil] autorelease];
	[self performSelector:@selector(updateRenderProgress) withObject:nil afterDelay:0.1 inModes:modes];
	
}

- (void)updateRenderProgress
{
	
	if (OFSAptr->getSongState()==SONG_RENDER_AUDIO) {
		float progress = OFSAptr->getRenderProgress();
		[self setRenderProgress:progress];
		NSLog(@"export audio, progrss: %2.2f",progress);
		
		NSArray *modes = [[[NSArray alloc] initWithObjects:NSDefaultRunLoopMode, UITrackingRunLoopMode, nil] autorelease];
		[self performSelector:@selector(updateRenderProgress) withObject:nil afterDelay:0.1 inModes:modes];
	}
}


- (void)renderAudioDidFinish {
	
	OFSAptr->setSongState(SONG_IDLE);
	OFSAptr->soundStreamStart();
	//[milgromViewController startAnimation];
	[[(MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate] shareManager] menuWithView:self.view];
	
}






- (void)render {
	
	[self setRenderProgress:0.0f];
	
	MilgromInterfaceAppDelegate * appDelegate = (MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate];
	MilgromViewController * milgromViewController = appDelegate.milgromViewController;
	ShareManager *shareManager = [appDelegate shareManager];
	
	[milgromViewController stopAnimation];
	OFSAptr->soundStreamStop();
	OFSAptr->setSongState(SONG_RENDER_VIDEO);
	
	
	dispatch_queue_t myCustomQueue;
	myCustomQueue = dispatch_queue_create("renderQueue", NULL);
	
	dispatch_async(myCustomQueue, ^{
		
		//OFSAptr->renderAudio();
		
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		[OpenGLTOMovie writeToVideoURL:[NSURL fileURLWithPath:[shareManager getVideoPath]] withAudioURL:[NSURL fileURLWithPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"temp.wav"]] WithSize:CGSizeMake(480, 320) 
		 
						 withDrawFrame:^(int frameNum) {
							 //NSLog(@"rendering frame: %i",frameNum);
							 OFSAptr->seekFrame(frameNum);
							 
							 [milgromViewController renderFrame];
							 [self setRenderProgress:OFSAptr->getRenderProgress()];
							 // TODO: playhead is only by DRM
							 
						 }
		 
						 withDidFinish:^(int frameNum) {
							 
							 int res = (int)(OFSAptr->getSongState()!=SONG_RENDER_VIDEO);
							 NSLog(@"writing video, progrss: %2.2f, frame: %i, finished: %i",OFSAptr->getRenderProgress(),frameNum,res);
							 return res;
						 }
		 
				 withCompletionHandler:^ {
					 NSLog(@"write completed");
					 
					 OFSAptr->setSongState(SONG_IDLE);
					 OFSAptr->soundStreamStart();
					 [milgromViewController startAnimation];
					 [shareManager setRendered];
					 [shareManager action];
					 
					 
					 //renderingView.hidden = YES;
					 //[self action];
					 
				 }];
	});
	
	
	dispatch_release(myCustomQueue);
	
}

				   

@end
