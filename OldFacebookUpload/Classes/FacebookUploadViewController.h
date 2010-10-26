//
//  FacebookUploadViewController.h
//  Milgrom
//
//  Created by Roee Kremer on 10/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FacebookUploader.h"


@interface FacebookUploadViewController : UIViewController<FacebookUploaderDelegate> {
	FacebookUploader *uploader;
	
	UITextField *titleField;
	UITextView *descriptionView;
	
	NSString *videoPath;
	
}

@property (nonatomic, retain) FacebookUploader *uploader;
@property (nonatomic, retain) IBOutlet UITextField *titleField;
@property (nonatomic, retain) IBOutlet UITextView *descriptionView;

@property (nonatomic,retain ) NSString *videoTitle;
@property (nonatomic,retain) NSString* videoPath;

- (void) upload:(id)sender;
- (void) cancel:(id)sender;
- (void) logout:(id)sender;


@end
