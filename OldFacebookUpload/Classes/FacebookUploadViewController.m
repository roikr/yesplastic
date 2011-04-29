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

@end

@implementation FacebookUploadViewController

@synthesize titleField;
@synthesize descriptionView;
@synthesize videoPath;
@synthesize activeView;
@synthesize scrollView;
@synthesize additionalText;


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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[videoPath release];
	[uploader release];
    [super dealloc];
}

-(void)setDelegate:(id<FacebookUploadViewControllerDelegate>)theDelegate {
	delegate = theDelegate;
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
	
	if (!viewIsScrolled && activeView==descriptionView ) {
		[scrollView setContentOffset:CGPointMake(0.0, activeView.frame.origin.y-30) animated:YES];
		
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
		[uploader uploadVideoWithTitle:titleField.text withDescription:[descriptionView.text stringByAppendingString:additionalText] andPath:videoPath];
	}
}

- (void) cancel:(id)sender {
	[delegate FacebookUploadViewControllerDone:self];
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
	NSLog(@"new state: %i, app state: %i",theUploader.state,[UIApplication sharedApplication].applicationState );
	if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
		return;
	}
	
	switch ([theUploader state]) {
		case FACEBOOK_UPLOADER_STATE_UPLOADING:
		case FACEBOOK_UPLOADER_STATE_UPLOAD_CANCELED:
			[delegate FacebookUploadViewControllerDone:self];
			break;
		default:
			break;
	}
}

@end
