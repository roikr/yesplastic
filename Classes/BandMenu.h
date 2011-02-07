//
//  BandMenu.h
//  MilgromInterface
//
//  Created by Roee Kremer on 7/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SongsTable;

@interface BandMenu : UIViewController {
	SongsTable *songsTable;
	UIView *songsView;
	UIActivityIndicatorView *activityIndicator;
	UIButton *editButton;
	UITextView *firstLaunchView;
	UIImageView *background;
	

	
}

@property (nonatomic,retain) SongsTable *songsTable;
@property (nonatomic,retain ) IBOutlet UIView *songsView;
@property (nonatomic,retain ) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic,retain) IBOutlet UIButton *editButton;
@property (nonatomic, retain) IBOutlet UITextView *firstLaunchView;
@property (nonatomic,retain) IBOutlet UIImageView *background;


- (void)edit:(id)sender;
- (void)help:(id)sender;
- (void)link:(id)sender;
- (void)cancelEdit;

@end
