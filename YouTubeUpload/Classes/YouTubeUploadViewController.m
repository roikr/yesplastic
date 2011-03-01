//
//  YouTubeUploadViewController.m
//  YouTubeUpload
//
//  Created by Roee Kremer on 9/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "YouTubeUploadViewController.h"

@interface YouTubeUploadViewController (PrivateMethods)

- (void)unsave;
- (void)registerForKeyboardNotifications;

@end

@implementation YouTubeUploadViewController



@synthesize username;
@synthesize password;
@synthesize titleField;
@synthesize descriptionView;
@synthesize videoPath;
@synthesize scrollView;
@synthesize activeView;
@synthesize additionalText;



/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	username.text = [defaults objectForKey:@"YTUsername"];
	password.text = [defaults objectForKey:@"YTPassword"];
	
	[self registerForKeyboardNotifications];
	viewIsScrolled = NO;
	keyboardShown = NO;
	additionalText = @"";
		
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
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[videoPath release];
	[uploader release];
    [super dealloc];
}


-(void)setUploader:(YouTubeUploader *) theUploader {
	uploader = theUploader;
	[theUploader addDelegate:self];
}

-(YouTubeUploader *)uploader {
	return uploader;
}

-(void) setVideoTitle:(NSString *) title{
	titleField.text = title;
}

-(NSString *)videoTitle {
	return titleField.text;
}



- (void)unsave {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObjectForKey:@"YTUsername"];
	[defaults removeObjectForKey:@"YTPassword"];
	[defaults synchronize];
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	
	if (textField==username) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		if (username.text!=@"") {
			[defaults setObject:username.text forKey:@"YTUsername"];
		} else {
			[defaults removeObjectForKey:@"YTUsername"];
		}
		
		[defaults synchronize];
		
	}
	
	if (textField==password) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		if (password.text!=@"") {
			[defaults setObject:password.text forKey:@"YTPassword"];
		} else {
			[defaults removeObjectForKey:@"YTPassword"];
		}
		
		[defaults synchronize];
		
	}
	
	
	return NO;
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	activeView = textField;
	
	return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	activeView = nil;
	
	return YES;
	
}


- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	
	activeView = textView;
	
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
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidHide:)
												 name:UIKeyboardDidHideNotification object:nil];
}



// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWillShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
	float kbHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
	
	CGSize contentSize = scrollView.contentSize;
	contentSize.height+=kbHeight;
	scrollView.contentSize = contentSize;
	
	
	if (!viewIsScrolled && (activeView==descriptionView || activeView==titleField)) {
		//[scrollView setContentOffset:CGPointMake(0.0, activeView.frame.origin.y-30) animated:YES];
		[scrollView setContentOffset:CGPointMake(0.0, titleField.frame.origin.y-7) animated:YES];
		
		viewIsScrolled = YES;
	}
	
	keyboardShown = YES;
	
	
}


// Called when the UIKeyboardDidHideNotification is sent
- (void)keyboardWillHide:(NSNotification*)aNotification
{
	
		
	[scrollView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
	viewIsScrolled = NO;
	
	keyboardShown = NO;
}

// Called when the UIKeyboardDidHideNotification is sent
- (void)keyboardDidHide:(NSNotification*)aNotification
{
	NSDictionary* info = [aNotification userInfo];
	float kbHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
	
	
	CGSize contentSize = scrollView.contentSize;
	contentSize.height-=kbHeight;
	scrollView.contentSize = contentSize;
	
}


//- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)theScrollView {
//	CGSize contentSize = theScrollView.contentSize;
//	contentSize.height-=kbHeight;
//	theScrollView.contentSize = contentSize;
//}



- (void) upload:(id)sender {

	
	if (uploader!=nil) {
		uploader.username = username.text;
		uploader.password = password.text;
		[uploader uploadVideoWithTitle:titleField.text withDescription:descriptionView.text andPath:videoPath]; //[descriptionView.text stringByAppendingString:additionalText]
	}
}

- (void) cancel:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}


- (void) youTubeUploaderStateChanged:(YouTubeUploader *)theUploader {
	
	switch (theUploader.state) {
		case YOUTUBE_UPLOADER_STATE_INCORRECT_CREDENTIALS: {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"YouTube Upload eror" 
															message:@"your username or password are incorrect"
														   delegate:nil 
												  cancelButtonTitle:@"OK" 
												  otherButtonTitles: nil];
			[alert show];
			[alert release];
		} break;
			
		case YOUTUBE_UPLOADER_STATE_UPLOADING: 
			[self.navigationController popViewControllerAnimated:YES];
			break;
		default:
			break;
	}
	
	
	
	
}



@end
