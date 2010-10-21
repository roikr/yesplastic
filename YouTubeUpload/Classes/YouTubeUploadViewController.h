//
//  YouTubeUploadViewController.h
//  YouTubeUpload
//
//  Created by Roee Kremer on 9/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class YouTubeUploader;
@interface YouTubeUploadViewController : UIViewController {
	YouTubeUploader *uploader;
	
	UITextField *username;
	UITextField *password;
	UITextField *videoTitle;
	UITextView *description;
		
	
	
	NSString *videoName;
	NSString *path;
	
	UIView *inputView;
	UIView *uploadView;
}

@property (nonatomic,retain) YouTubeUploader *uploader;

@property (nonatomic,retain) IBOutlet UITextField *username;
@property (nonatomic,retain) IBOutlet UITextField *password;
@property (nonatomic,retain) IBOutlet UITextField *titleField;
@property (nonatomic,retain) IBOutlet UITextView *descriptionView;

@property (nonatomic,retain ) NSString *videoTitle;
@property (nonatomic,retain) NSString* videoPath;

- (void) upload:(id)sender;
- (void) cancel:(id)sender;

@end

