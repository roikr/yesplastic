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


@interface MainViewController : UIViewController {

	
	
	UIButton *playButton;
	UIButton *recordButton;
	UIButton *menuButton;
	UIButton *setMenuButton;
	UIButton *saveButton;
	UIView *triggersView;
	UIView *loopsView;
	UIView *bandLoopsView;
	
	testApp *OFSAptr;
	
	NSArray *playerControllers;
	
	
	UIButton *triggerButton;
	UIButton *loopButton;
	
	
	
}

@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UIButton *recordButton;
@property (nonatomic, retain) IBOutlet UIButton *menuButton;
@property (nonatomic, retain) IBOutlet UIButton *setMenuButton;
@property (nonatomic, retain) IBOutlet UIButton *saveButton;
@property (nonatomic, retain) IBOutlet UIView *triggersView;
@property (nonatomic, retain) IBOutlet UIView *loopsView;
@property (nonatomic, retain) IBOutlet UIView *bandLoopsView;

@property (nonatomic,assign) IBOutlet UIButton *triggerButton;
@property (nonatomic,assign )IBOutlet UIButton *loopButton;



@property (nonatomic, retain) NSArray *playerControllers;

- (void) bringMenu:(id)sender;
- (void) checkState:(id)sender;
- (void) play:(id)sender;
- (void) record:(id)sender;
- (void) save:(id)sender;
- (void) trigger:(id)sender;
- (void) loop:(id)sender;
- (void)updateLoops:(id)sender;
- (void) nextLoop:(id)sender;
- (void) prevLoop:(id)sender;
- (void) show;
- (void) hide;

//- (void) updateTables;

@end
