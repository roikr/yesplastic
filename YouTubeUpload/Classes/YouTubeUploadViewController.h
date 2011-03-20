//
//  YouTubeUploadViewController.h
//  YouTubeUpload
//
//  Created by Roee Kremer on 9/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YouTubeUploader.h"


@interface YouTubeUploadViewController : UIViewController<YouTubeUploaderDelegate> {
	YouTubeUploader *uploader;
	
	UITextField *username;
	UITextField *password;
	UITextField *titleField;
	UITextView *description;
		
	
	
	NSString *videoName;
	NSString *path;
	
	UIView *inputView;
	UIView *uploadView;
	
	UIScrollView *srcollView;
	BOOL viewIsScrolled;
	BOOL keyboardShown;
	
	UIView *activeView;
	
	NSString *additionalText;
	
	UIView *processView;
	
}

@property (nonatomic,retain) YouTubeUploader *uploader;

@property (nonatomic,retain) IBOutlet UITextField *username;
@property (nonatomic,retain) IBOutlet UITextField *password;
@property (nonatomic,retain) IBOutlet UITextField *titleField;
@property (nonatomic,retain) IBOutlet UITextView *descriptionView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, assign) UIView *activeView;

@property (nonatomic,retain) IBOutlet UIView *processView;

@property (nonatomic,retain ) NSString *videoTitle;
@property (nonatomic,retain) NSString* videoPath;

@property (nonatomic,retain) NSString* additionalText;

- (void) upload:(id)sender;
- (void) cancel:(id)sender;
- (void) touchDown:(id)sender;

@end

