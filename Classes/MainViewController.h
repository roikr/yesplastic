//
//  MainViewController.h
//  YesPlastic
//
//  Created by Roee Kremer on 2/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

class testApp;
@class EAGLView;
@class TouchView;
@class CustomFontTextField;
@class SaveViewController;
@class CustomImageView;

@interface MainViewController : UIViewController<UINavigationControllerDelegate> {

	UIView *bandHelp;
	UIView *soloHelp;
	
	UIButton *playButton;
	UIButton *stopButton;
	UIButton *recordButton;
	UIButton *shareButton;
	UIButton *menuButton;
	UIButton *setMenuButton;
	UIButton *saveButton;
	UIButton *infoButton;
	UIView *triggersView;
	UIView *loopsView;
	UIView *bandLoopsView;
	UIView *renderView;
	
	
	testApp *OFSAptr;
	
	
	
	
	//UIButton *triggerButton;
	//UIButton *loopButton;
	
	SaveViewController *saveViewController;
	
	BOOL bShowHelp;
	
	BOOL bAnimatingRecord;
	NSTimeInterval shakeStartTime;
	
	CustomImageView *shareProgressView;
	CustomImageView *renderProgressView;
	
}


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
@property (nonatomic, retain) IBOutlet UIView *bandLoopsView;
@property (nonatomic, retain) IBOutlet UIView *bandHelp;
@property (nonatomic, retain) IBOutlet UIView *soloHelp;
@property (nonatomic, retain) IBOutlet UIView *renderView;


@property (nonatomic, retain) SaveViewController *saveViewController;
@property (nonatomic,retain ) IBOutlet CustomImageView *shareProgressView;
@property (nonatomic,retain ) IBOutlet CustomImageView *renderProgressView;

@property BOOL bShowHelp;


- (void) menu:(id)sender;
- (void) play:(id)sender;
- (void) stop:(id)sender;
- (void) record:(id)sender;
- (void) save:(id)sender;
- (void) share:(id)sender;
- (void) setShareProgress:(float) progress;
- (void) trigger:(id)sender;
- (void) loop:(id)sender;
- (void) nextLoop:(id)sender;
- (void) prevLoop:(id)sender;
- (void) updateViews;
- (void) showHelp:(id)sender;
- (void) hideHelp;
- (void) moreHelp:(id)sender;

- (void) fadeOutRecordButton;
- (void) fadeInRecordButton;

- (void)render;


@end
