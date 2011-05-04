//
//  PlayerMenu.m
//  MilgromInterface
//
//  Created by Roee Kremer on 7/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PlayerMenu.h"
#import "SetsTable.h"
#import "MilgromInterfaceAppDelegate.h"
#import "SoloViewController.h"
#import "testApp.h"
#import "MilgromMacros.h"

#ifdef _FLURRY
#import "FlurryAPI.h"
#endif

@implementation PlayerMenu

@synthesize setsTable;
@synthesize setsView;
@synthesize doneButton;
@synthesize background;
@synthesize volumeSlider;
@synthesize bpmSlider;
@synthesize playerName;
//@synthesize volumeLabel;


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
#ifndef FREE_APP
	if (self.setsTable == nil) {
		self.setsTable = [[SetsTable alloc] initWithNibName:@"SetsTable" bundle:nil];
		
		//controller.bpmSlider.playerName = controller.playerName;
		//controller.volumeSlider.playerName = controller.playerName;
		setsTable.playerName = playerName;
		
		[self.setsTable loadData];
	}
#endif
		
	NSString *doneButtonName = [NSString stringWithFormat:@"%@_DONE.png",playerName];
	[doneButton setImage:[UIImage imageNamed:doneButtonName] forState:UIControlStateNormal];
	
	NSString *backgroundName = [NSString stringWithFormat:@"%@_SET_BACK.png",playerName];
	[background setImage:[UIImage imageNamed:backgroundName]];
	
			
	
	
	[bpmSlider setMinimumTrackImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_SLIDER_OVER.png",playerName]] forState:UIControlStateNormal];
	[bpmSlider setMaximumTrackImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_SLIDER_BACK.png",playerName]] forState:UIControlStateNormal];
	[bpmSlider setThumbImage: [UIImage imageNamed:[NSString stringWithFormat:@"%@_SLIDER_PIN.png",playerName]] forState:UIControlStateNormal];
	//CGRect frame = bpmSlider.frame;
	//frame.size = minTrack.size;
	//bpmSlider.frame = frame;
	
	
	[volumeSlider setMinimumTrackImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_SLIDER_OVER.png",playerName]] forState:UIControlStateNormal];
	[volumeSlider setMaximumTrackImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_SLIDER_BACK.png",playerName]] forState:UIControlStateNormal];
	[volumeSlider setThumbImage: [UIImage imageNamed:[NSString stringWithFormat:@"%@_SLIDER_PIN.png",playerName]] forState:UIControlStateNormal];
	//CGRect frame = volumeSlider.frame;
	//frame.size = minTrack.size;
	//volumeSlider.frame = frame;
	
	
	//NSArray *array = [NSArray arrayWithObject:self.songsTable.editButtonItem];
#ifndef FREE_APP
	[self.setsView addSubview:setsTable.view];
#endif
	
	
	
	
}

- (void) loadData {
	[self.setsTable loadData];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return interfaceOrientation == UIInterfaceOrientationPortrait ;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	
	self.setsView = nil;
	self.doneButton = nil;
	self.background = nil;
	self.volumeSlider = nil;
	self.bpmSlider = nil;
	//[setsTable release];
	//self.setsTable = nil;
    [super viewDidUnload];
	
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	//[setsTable viewDidAppear:animated];
	MilgromLog(@"PlayerMenu::viewDidAppear");
	   
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	MilgromLog(@"PlayerMenu::viewWillAppear");
#ifndef FREE_APP
	[setsTable viewWillAppear:animated];
#endif
	
	testApp *OFSAptr = ((MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate]).OFSAptr;
	volumeSlider.value = OFSAptr->getVolume();
	//volumeLabel.text = [NSString stringWithFormat:@"%1.3f",((MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate]).OFSAptr->getVolume()];

	//volumeSlider.value = [((MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate]).videoBitrate doubleValue] / (1000.0*1000.0*10.0) ;
	//volumeLabel.text = [NSString stringWithFormat:@"%.0f Kbit",[((MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate]).videoBitrate doubleValue]/1000];
	bpmSlider.value = ((float)OFSAptr->getBPM() - 80.0)/80.0;
	
#ifdef _FLURRY
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithCString:OFSAptr->getPlayerName(OFSAptr->controller).c_str() encoding:NSASCIIStringEncoding],@"PLAYER", nil];
	[FlurryAPI logEvent:@"SET_MENU" withParameters:dictionary];
#endif
	
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	MilgromLog(@"PlayerMenu::viewDidDisappear");
	
}

- (void)volumeChanged:(id)sender {
	testApp *OFSAptr = ((MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate]).OFSAptr;
	OFSAptr->setVolume(volumeSlider.value);

#ifdef _FLURRY
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithCString:OFSAptr->getPlayerName(OFSAptr->controller).c_str() encoding:NSASCIIStringEncoding],@"PLAYER", nil];
	[FlurryAPI logEvent:@"CHANGE_VOLUME" withParameters:dictionary];
#endif
	//volumeLabel.text = [NSString stringWithFormat:@"%1.3f",((MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate]).OFSAptr->getVolume()];

	//((MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate]).videoBitrate = [NSNumber numberWithDouble:volumeSlider.value * (1000.0*1000.0*10.0)];
	//volumeLabel.text = [NSString stringWithFormat:@"%.0f Kbit",[((MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate]).videoBitrate doubleValue]/1000];
	
	
}

- (void) bpmChanged:(id)sender {
	
	//ofClamp(bpm*150.0+50.0,50,200)
	testApp *OFSAptr = ((MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate]).OFSAptr;
	OFSAptr->setBPM(bpmSlider.value * 80.0 + 80);
#ifdef _FLURRY
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithCString:OFSAptr->getPlayerName(OFSAptr->controller).c_str() encoding:NSASCIIStringEncoding],@"PLAYER", nil];
	[FlurryAPI logEvent:@"CHANGE_BPM" withParameters:dictionary];
#endif	
}

- (void)exit:(id)sender {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
	

}


- (void)dealloc {
#ifndef FREE_APP
	[setsTable release];
#endif
    [super dealloc];
}


@end
