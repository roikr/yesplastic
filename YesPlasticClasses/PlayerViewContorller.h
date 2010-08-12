//
//  PlayerViewContorller.h
//  YesPlastic
//
//  Created by Roee Kremer on 2/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainViewController;
@interface PlayerViewContorller : UITableViewController {
	MainViewController *mainController;
	//NSTimer *timer; // use to exit from player menu
	UISlider *volumeSlider;
	UISlider *bpmSlider;
	UIButton *doneButton;
	
}

@property (nonatomic,retain) MainViewController *mainController;
//@property (nonatomic,retain ) NSTimer *timer;
@property (nonatomic,retain ) IBOutlet UISlider *volumeSlider;
@property (nonatomic,retain) IBOutlet UISlider *bpmSlider;
@property (nonatomic,retain) IBOutlet UIButton *doneButton;

//- (void)touchDown:(id)sender;
//- (void)touchUp:(id)sender;
- (void)volumeChanged:(id)sender ;
- (void)bpmChanged:(id)sender;
- (void)show;
- (void)done:(id)sender;


@end
