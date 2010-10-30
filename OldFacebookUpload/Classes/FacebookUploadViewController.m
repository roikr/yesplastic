//
//  FacebookUploadViewController.m
//  Milgrom
//
//  Created by Roee Kremer on 10/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FacebookUploadViewController.h"
#import "FacebookUploader.h"


@implementation FacebookUploadViewController

@synthesize titleField;
@synthesize descriptionView;
@synthesize videoPath;


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
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

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
	[videoPath release];
	[uploader release];
    [super dealloc];
}

-(void)setUploader:(FacebookUploader *) theUploader {
	uploader = theUploader;
	[theUploader addDelegate:self];
}

-(FacebookUploader *)uploader {
	return uploader;
}


-(void) setVideoTitle:(NSString *) title{
	titleField.text = title;
}

-(NSString *)videoTitle {
	return titleField.text;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return NO;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
	[textView resignFirstResponder];
	return YES;
}


- (void) upload:(id)sender {
	
	if (uploader!=nil) {
		[uploader uploadVideoWithTitle:titleField.text withDescription:descriptionView.text andPath:videoPath];
	}
		
	[self.navigationController popViewControllerAnimated:YES];

}

- (void) cancel:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) logout:(id)sender {
	if (uploader!=nil && [uploader isConnected]) {
		[uploader logout];
	}
}


- (void) facebookUploaderStateChanged:(FacebookUploader *)theUploader {
	NSLog(@"new state: %i",theUploader.state);
}

@end