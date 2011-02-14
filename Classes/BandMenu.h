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
	
	UIActivityIndicatorView *activityIndicator;
	UIButton *editButton;
	UITextView *firstLaunchView;
	UIImageView *background;
	
	UIView *milgromView;
	UIView *lofiView;
	UIView *menuView;
	UIView *songsView;
	
	BOOL firstTime;

	
}

@property (nonatomic,retain) SongsTable *songsTable;
@property (nonatomic,retain ) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic,retain) IBOutlet UIButton *editButton;
@property (nonatomic, retain) IBOutlet UITextView *firstLaunchView;
@property (nonatomic,retain) IBOutlet UIImageView *background;


@property (nonatomic,retain ) IBOutlet UIView *milgromView;
@property (nonatomic,retain ) IBOutlet UIView *lofiView;
@property (nonatomic, retain) IBOutlet UIView *menuView;
@property (nonatomic,retain ) IBOutlet UIView *songsView;


- (void)edit:(id)sender;
- (void)help:(id)sender;
- (void)link:(id)sender;
- (void)cancelEdit;

- (void) swapView:(UIView *)firstView with:(UIView *)secondView completion:(void (^)(BOOL finished))completion;

@end
