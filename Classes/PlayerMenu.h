//
//  PlayerMenu.h
//  MilgromInterface
//
//  Created by Roee Kremer on 7/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SetsTable;

@interface PlayerMenu : UIViewController {
	SetsTable *setsTable;
	UIView *setsView;
	
	UIButton *doneButton;
	UIImageView *background;
	
	UISlider *volumeSlider;
	UISlider *bpmSlider;
	NSString * playerName;
	
	//UILabel *volumeLabel;
	UIButton *appButton;
	
	BOOL bpmChanged;
	BOOL volumeChanged;
	
}

@property (nonatomic,retain) SetsTable *setsTable;
@property (nonatomic,retain) IBOutlet UIView *setsView;
@property (nonatomic,retain) IBOutlet UIButton *doneButton;
@property (nonatomic,retain) IBOutlet UIImageView *background;

@property (nonatomic,retain ) IBOutlet UISlider *volumeSlider;
@property (nonatomic,retain) IBOutlet UISlider *bpmSlider;
@property (nonatomic,retain) NSString *playerName;
@property (nonatomic,retain) IBOutlet UIButton *appButton;

//@property (nonatomic,retain) IBOutlet UILabel *volumeLabel;

- (void)exit:(id)sender;
- (void)volumeChanged:(id)sender ;
- (void)bpmChanged:(id)sender;
- (void) loadData; // load the sets list from the store to the table
- (void)appStore:(id)sender;

@end
