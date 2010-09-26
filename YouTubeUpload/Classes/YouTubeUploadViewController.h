//
//  YouTubeUploadViewController.h
//  YouTubeUpload
//
//  Created by Roee Kremer on 9/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GDataServiceTicket;

@interface YouTubeUploadViewController : UIViewController {
	UITextField *username;
	UITextField *password;
	UITextField *videoTitle;
	UITextView *description;
	UIProgressView *mUploadProgressIndicator;
	
	GDataServiceTicket *mUploadTicket;
}

@property (nonatomic,retain) IBOutlet UITextField *username;
@property (nonatomic,retain) IBOutlet UITextField *password;
@property (nonatomic,retain) IBOutlet UITextField *videoTitle;
@property (nonatomic,retain) IBOutlet UITextView *description;
@property (nonatomic,retain) IBOutlet UIProgressView *mUploadProgressIndicator;

- (void) upload:(id)sender;
- (void) cancel:(id)sender;


@end

