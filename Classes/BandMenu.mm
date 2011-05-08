//
//  BandMenu.m
//  MilgromInterface
//
//  Created by Roee Kremer on 7/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BandMenu.h"
#import "SongsTable.h"
#import "MilgromInterfaceAppDelegate.h"
#import "MilgromMacros.h"

#import "MainViewController.h"
#import "EAGLView.h"


#ifdef _FLURRY
#import "FlurryAPI.h"
#endif



@implementation BandMenu

@synthesize songsTable;
@synthesize activityIndicator;
@synthesize editButton;
@synthesize firstLaunchView;
@synthesize background;
@synthesize milgromView,lofiView,menuView,songsView;
@synthesize appButton;


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
	MilgromLog(@"BandView::viewDidLoad");
	
	
	
	if (self.songsTable == nil) {
		self.songsTable = [[SongsTable alloc] initWithNibName:@"SongsTable" bundle:nil];
		CGRect frame = songsView.frame;
#ifdef FREE_APP
		frame.size.height-=appButton.frame.size.height;
#endif
		songsTable.view.frame = frame;
	} else {
		[firstLaunchView removeFromSuperview];
		[milgromView removeFromSuperview];
		[lofiView removeFromSuperview];
		menuView.alpha = 1.0;
	}
	
	//CGAffineTransform rotateTransform = ;
	
	//set point of rotation
	//background.center = CGPointMake(240.0, 160.0);
	background.transform = CGAffineTransformRotate(CGAffineTransformIdentity,-M_PI/2.0);
	

	
	[self.menuView addSubview:songsTable.view];
	[self.menuView insertSubview:songsTable.view aboveSubview:songsView];
	
#ifndef FREE_APP
	[self.appButton removeFromSuperview];
#endif
	
	[songsView removeFromSuperview];
		
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return interfaceOrientation == UIInterfaceOrientationLandscapeRight ;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	self.editButton = nil;
	self.activityIndicator = nil;
	self.songsView = nil;
	//[songsTable release];
	//self.songsTable = nil;
    [super viewDidUnload];
	//self.songsTable = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	
	[songsTable release]; // TODO: need to check ?
	//[help release];
    [super dealloc];
}

- (void)updateEditMode {
	if ([songsTable anySongs]) {
		editButton.hidden = NO;
	} else {
		editButton.hidden = YES;
		if (editButton.selected) {
			editButton.selected = NO;
			[self.songsTable setEditing:NO animated:YES];
		}
	}

	
}

- (void)edit:(id)sender {
	UIButton *button = (UIButton*)sender;
	if (button.selected) {
		[self.songsTable setEditing:NO animated:YES];
	} else {
		[self.songsTable setEditing:YES animated:YES];
	}
	
	
	button.selected = !button.selected;
	
	if (button.selected) {
		[self.songsTable scrollToSongs];
	}
}

- (void)cancelEdit {
	if (editButton.selected) {
		[self edit:editButton];
	}
}


- (void)help:(id)sender {
	[self cancelEdit];
	[((MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate]) helpWithTransition:UIModalTransitionStyleFlipHorizontal];
}

- (void)link:(id)sender {
	[self cancelEdit];
	UIButton *button = (UIButton *)sender;
	
	switch (button.tag) {
		case 0:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.mmmilgrom.com"]];
//			[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.youtube.com/watch?v=ClR7aADV0Zs"]];
			break;
		case 1:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.youtube.com/mmmilgrom"]];
			break;
		case 2:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.myspace.com/milgromband"]];
			break;
		case 3:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.mmmilgrom.com/fb"]];
//			[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.facebook.com/pages/Milgrom/137470506285895?ref=ts"]];
			break;
		default:
			break;
	}
	
}

- (void)appStore:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.mmmilgrom.com/appstore"]];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	MilgromLog(@"BandView::viewWillAppear");
	MilgromLog(@"BandView orientation: %u, parent: %u",[self interfaceOrientation],[self.navigationController interfaceOrientation]);
	
	//	MilgromInterfaceAppDelegate * appDelegate = (MilgromInterfaceAppDelegate*)[[UIApplication sharedApplication] delegate];
	//[self rotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight duration:0 completion:NULL];
#ifdef _FLURRY
	[FlurryAPI logEvent:@"MENU"];
#endif	
}


- (void)viewDidAppear:(BOOL)animated {
	MilgromLog(@"BandView::viewDidAppear");
	[super viewDidAppear:animated];
	self.view.userInteractionEnabled = YES;
}
 



- (void)viewDidDisappear:(BOOL)animated {
	MilgromLog(@"BandView::viewDidDisappear");
    [super viewDidDisappear:animated];
	[songsTable viewDidDisappear:animated];
}




@end
