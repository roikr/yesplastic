//
//  BandMenu.h
//  MilgromInterface
//
//  Created by Roee Kremer on 7/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SongsTable;
@class MainViewController;

@interface BandMenu : UIViewController {
	SongsTable *songsTable;
	UIView *songsView;
	MainViewController *mainViewController;
	
}

@property (nonatomic,retain) SongsTable *songsTable;
@property (nonatomic,retain ) IBOutlet UIView *songsView;
@property (nonatomic,retain ) MainViewController *mainViewController;

- (void)edit:(id)sender;
- (void)exit:(id)sender;
- (void)help:(id)sender;
- (void)link:(id)sender;



@end
