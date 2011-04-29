//
//  FacebookUploadViewController.h
//  Milgrom
//
//  Created by Roee Kremer on 10/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FacebookUploader.h"

@protocol FacebookUploadViewControllerDelegate;

@interface FacebookUploadViewController : UIViewController<FacebookUploaderDelegate> {
	FacebookUploader *uploader;
	
	UITextField *titleField;
	UITextView *descriptionView;
	
	NSString *videoPath;
	
	UIScrollView *srcollView;
	BOOL viewIsScrolled;
	BOOL keyboardShown;
	
	UIView *activeView;
	
	NSString *additionalText;
	
	id<FacebookUploadViewControllerDelegate> delegate;
}

@property (nonatomic, retain) FacebookUploader *uploader;
@property (nonatomic, retain) IBOutlet UITextField *titleField;
@property (nonatomic, retain) IBOutlet UITextView *descriptionView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, assign) UIView *activeView;
//@property (nonatomic, retain) IBOutlet UIView *scrollView;

@property (nonatomic,retain ) NSString *videoTitle;
@property (nonatomic,retain) NSString* videoPath;
@property (nonatomic,retain) NSString* additionalText;

-(void)setDelegate:(id<FacebookUploadViewControllerDelegate>)theDelegate;
- (void) upload:(id)sender;
- (void) cancel:(id)sender;
- (void) logout:(id)sender;
- (void) touchDown:(id)sender;
- (void)registerForKeyboardNotifications;


@end

@protocol FacebookUploadViewControllerDelegate<NSObject>

- (void) FacebookUploadViewControllerDone:(FacebookUploadViewController *)controller;

@end