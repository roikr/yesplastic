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
@class CustomFontTextField;
@class CustomImageView;


@interface MainViewController : UIViewController<UINavigationControllerDelegate> {

	UIView *bandHelp;
	UIView *interactionView;
	UIButton *stateButton;
	UIButton *playButton;
	UIButton *stopButton;
	UIButton *recordButton;
	UIButton *shareButton;
	UIButton *menuButton;
	UIButton *saveButton;
	UIButton *infoButton;
	UIView *bandLoopsView;
	UIView *loopsImagesView;
	
	UIView *slides;
	
	testApp *OFSAptr;
	
	BOOL bShowHelp;
	BOOL bAnimatingRecord;
	
	CustomImageView *shareProgressView;
	
	int loopChanges[3];
}

@property (nonatomic, retain) IBOutlet UIView *interactionView;
@property (nonatomic,retain ) IBOutlet UIButton *stateButton;
@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UIButton *stopButton;
@property (nonatomic, retain) IBOutlet UIButton *recordButton;
@property (nonatomic, retain) IBOutlet UIButton *menuButton;
@property (nonatomic, retain) IBOutlet UIButton *saveButton;
@property (nonatomic, retain) IBOutlet UIButton *shareButton;
@property (nonatomic, retain) IBOutlet UIButton *infoButton;
@property (nonatomic, retain) IBOutlet UIView *bandLoopsView;
@property (nonatomic, retain) IBOutlet UIView *loopsImagesView;

@property (nonatomic, retain) IBOutlet UIView *bandHelp;

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
- (void) nextLoop:(id)sender;
- (void) prevLoop:(id)sender;
- (void) updateViews;

- (void) showHelp:(id)sender;
- (void) hideHelp;
- (void) moreHelp:(id)sender;
- (void) replayTutorial:(id)sender;


@end



