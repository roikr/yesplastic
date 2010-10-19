//
//  FacebookUploadViewController.m
//  Milgrom
//
//  Created by Roee Kremer on 10/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FacebookUploadViewController.h"


@implementation FacebookUploadViewController

@synthesize facebookController;
@synthesize videoName;
@synthesize path;
@synthesize activityIndicatorView;

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
		
	
	
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[videoName release];
	[path release];
	[facebookController release];
    [super dealloc];
}

- (void) uploadWithVideoName:(NSString *)theVideoName andPath:(NSString *)thePath {
	
	if (self.facebookController == nil) {
		self.facebookController = [[FacebookUploadController alloc] initWithDelegate:self];
	}
	
	
	self.videoName = theVideoName;
	self.path = thePath;
	[facebookController login];
	[activityIndicatorView stopAnimating];
	
}

- (void) facebookControllerDidLogin:(FacebookUploadController *)theController {
	[facebookController uploadVideoWithVideoName:videoName andPath:path];
}

- (void) facebookControllerDidFail:(FacebookUploadController *)theController {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) facebookControllerDidStartUploading:(FacebookUploadController *)theController {
	[activityIndicatorView startAnimating];
}

- (void) facebookControllerDidFinishUploading:(FacebookUploadController *)theController {
	[activityIndicatorView stopAnimating];
	[self.navigationController popViewControllerAnimated:YES];
	
}

@end
