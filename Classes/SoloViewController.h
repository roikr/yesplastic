//
//  SoloViewController.h
//  YesPlastic
//
//  Created by Roee Kremer on 5/01/11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


class testApp;
@class CustomFontTextField;
@class CustomImageView;

@interface SoloViewController : UIViewController<UINavigationControllerDelegate> {

	UIView *soloHelp;
	UIView *interactionView;
	UIButton *stateButton;
	UIButton *playButton;
	UIButton *stopButton;
	UIButton *recordButton;
	UIButton *shareButton;
	UIButton *setMenuButton;
	UIButton *saveButton;
	UIButton *infoButton;
	UIView *triggersView;
	UIView *loopsView;
	
	NSArray *playerControllers;
	
	UIView *slides;
	
	testApp *OFSAptr;
	
	BOOL bShowHelp;
	BOOL bAnimatingRecord;
	
	CustomImageView *shareProgressView;
	
	int loopChanges[3];
	int triggers[3];
}

@property (nonatomic, retain) IBOutlet UIView *interactionView;
@property (nonatomic,retain ) IBOutlet UIButton *stateButton;
@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UIButton *stopButton;
@property (nonatomic, retain) IBOutlet UIButton *recordButton;
@property (nonatomic, retain) IBOutlet UIButton *menuButton;
@property (nonatomic, retain) IBOutlet UIButton *setMenuButton;
@property (nonatomic, retain) IBOutlet UIButton *saveButton;
@property (nonatomic, retain) IBOutlet UIButton *shareButton;
@property (nonatomic, retain) IBOutlet UIButton *infoButton;
@property (nonatomic, retain) IBOutlet UIView *triggersView;
@property (nonatomic, retain) IBOutlet UIView *loopsView;


@property (nonatomic, retain) IBOutlet UIView *soloHelp;

@property (nonatomic, retain) NSArray *playerControllers;

@property (nonatomic, retain) IBOutlet UIView *slides;

@property (nonatomic,retain ) IBOutlet CustomImageView *shareProgressView;

@property BOOL bShowHelp;

- (void) toggle:(id)sender;
- (void) menu:(id)sender;
- (void) play:(id)sender;
- (void) stop:(id)sender;
- (void) record:(id)sender;
- (void) save:(id)sender;
- (void) share:(id)sender;
- (void) setShareProgress:(float) progress;
- (void) trigger:(id)sender;
//- (void) triggerTest:(id)sender;
- (void) loop:(id)sender;
- (void) updateViews;


- (void) showHelp:(id)sender;
- (void) hideHelp;
- (void) replayTutorial:(id)sender;

- (void) updateAnalytics;
@end



