//
//  FacebookUploadViewController.m
//  Milgrom
//
//  Created by Roee Kremer on 10/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FacebookUploadViewController.h"
#import "FacebookUploader.h"

@interface FacebookUploadViewController ()
- (void)registerForKeyboardNotifications;

-(void)scroll;
@end

@implementation FacebookUploadViewController

@synthesize titleField;
@synthesize descriptionView;
@synthesize videoPath;
@synthesize activeView;
@synthesize scrollView;


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
	[self registerForKeyboardNotifications];
	viewIsScrolled = NO;
	keyboardShown = NO;
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

- (void) touchDown:(id)sender {
	NSLog(@"touchDown");
	for (UIView *view in [self.scrollView subviews]) {  
        if ([view isFirstResponder]) {  
            [view resignFirstResponder];
			break;
        }
    }   
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}



- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	activeView = textView;
	
	if (keyboardShown && !viewIsScrolled) {
		[self scroll];
	}
	
	return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
	activeView = nil;
	return YES;
}

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification object:nil];
	
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification object:nil];
}

-(void)scroll {
	
	CGSize contentSize = scrollView.contentSize;
	contentSize.height+=kbHeight;
	scrollView.contentSize = contentSize;
	
    [scrollView setContentOffset:CGPointMake(0.0, activeView.frame.origin.y) animated:YES];
	
    viewIsScrolled = YES;
}



// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWillShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
	kbHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
	
	
	if (!viewIsScrolled && activeView==descriptionView) {
		[self scroll];
	}
	
	keyboardShown = YES;
	
   
}


// Called when the UIKeyboardDidHideNotification is sent
- (void)keyboardWillHide:(NSNotification*)aNotification
{
	if (viewIsScrolled) {
		
		[scrollView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
		viewIsScrolled = NO;
	}
	
	keyboardShown = NO;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)theScrollView {
	CGSize contentSize = theScrollView.contentSize;
	contentSize.height-=kbHeight;
	theScrollView.contentSize = contentSize;
}


- (void) upload:(id)sender {
	
	if (uploader!=nil) {
		[uploader uploadVideoWithTitle:titleField.text withDescription:descriptionView.text andPath:videoPath];
	}
}

- (void) cancel:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) logout:(id)sender {
	
	if (uploader!=nil) {
		if ([uploader isConnected]) {
			[uploader logout];
		} else {
			[uploader login];
		}

	}
}


- (void) facebookUploaderStateChanged:(FacebookUploader *)theUploader {
	NSLog(@"new state: %i",theUploader.state);
	switch ([theUploader state]) {
		case FACEBOOK_UPLOADER_STATE_UPLOADING:
			[self.navigationController popViewControllerAnimated:YES];
			break;
		default:
			break;
	}
}

@end
