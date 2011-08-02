//
//  ShareViewController.m
//  Milgrom
//
//  Created by Roee Kremer on 4/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShareViewController.h"
#import "MilgromInterfaceAppDelegate.h"
#import "ShareManager.h"
#import "MilgromMacros.h"
#import "SlidesManager.h"

#ifdef _FLURRY
#import "FlurryAPI.h"
#endif


@implementation ShareViewController

@synthesize slides;
@synthesize container;


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
	MilgromInterfaceAppDelegate * appDelegate = (MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate];
    return interfaceOrientation == UIInterfaceOrientationPortrait || (appDelegate.slidesManager.currentTutorialSlide==MILGROM_TUTORIAL_DONE && interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	MilgromLog(@"ShareViewController::viewWillAppear");
#ifdef _FLURRY
	[FlurryAPI logEvent:@"SHARE"];
#endif
	
	MilgromInterfaceAppDelegate * appDelegate = (MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate.slidesManager setTargetView:self.view withSlides:self.slides];
	
	if (!appDelegate.slidesManager.currentView && appDelegate.slidesManager.targetView == self.view) {
		switch (appDelegate.slidesManager.currentTutorialSlide) {
			case MILGROM_TUTORIAL_SHARE:
				[appDelegate.slidesManager addViews];
				[self.view sendSubviewToBack:container];
				container.userInteractionEnabled=NO;
				break;
				
			default:
				container.userInteractionEnabled=YES;

				break;
		}
	}
	
}




- (void)dealloc {
    [super dealloc];
}

- (void) action:(id)sender {
		
	UIButton *button = (UIButton *)sender;
	NSInteger action;
	
	switch (button.tag)
	{
		case 0: 
			action = ACTION_UPLOAD_TO_FACEBOOK;
			break;
		case 1:
			action = ACTION_UPLOAD_TO_YOUTUBE;
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
	}
	
	[self.parentViewController dismissModalViewControllerAnimated:action==ACTION_CANCEL];
	
	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	[appDelegate.shareManager action:action];
}

- (void) tutorialShare {
	[self.parentViewController dismissModalViewControllerAnimated:NO];
	MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate.shareManager action:ACTION_UPLOAD_TO_FACEBOOK];
	
}

@end
