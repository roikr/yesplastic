//
//  PlayerMenu.h
//  MilgromInterface
//
//  Created by Roee Kremer on 7/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SetsTable;
@class CustomSlider;

@interface PlayerMenu : UIViewController {
	SetsTable *setsTable;
	UIView *setsView;
	
	CustomSlider *volumeSlider;
	CustomSlider *bpmSlider;
}

@property (nonatomic,retain) SetsTable *setsTable;
@property (nonatomic,retain) IBOutlet UIView *setsView;
@property (nonatomic,retain ) IBOutlet CustomSlider *volumeSlider;
@property (nonatomic,retain) IBOutlet CustomSlider *bpmSlider;

- (void)exit:(id)sender;
- (void)volumeChanged:(id)sender ;
- (void)bpmChanged:(id)sender;
@end
