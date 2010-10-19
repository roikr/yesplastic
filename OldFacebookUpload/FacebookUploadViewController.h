//
//  FacebookUploadViewController.h
//  Milgrom
//
//  Created by Roee Kremer on 10/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookUploadController.h"

@interface FacebookUploadViewController : UIViewController<FacebookControllerDelegate> {
	FacebookUploadController *facebookController;
	UIActivityIndicatorView *activityIndicatorView;
	
	NSString *videoName;
	NSString *path;
	
}

@property (nonatomic, retain) FacebookUploadController *facebookController;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic,retain) NSString *videoName;
@property (nonatomic,retain) NSString *path;

- (void) uploadWithVideoName:(NSString *)theVideoName andPath:(NSString *)thePath;

@end
