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



@interface MainViewController : UIViewController {

	EAGLView *glView;
	
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
	BOOL bMenuMode;
	
}

@property (nonatomic, retain) IBOutlet EAGLView *glView;
@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UIButton *recordButton;
@property (nonatomic, retain) IBOutlet UIButton *menuButton;
@property (nonatomic, retain) IBOutlet UIButton *setMenuButton;
@property (nonatomic, retain) IBOutlet UIButton *saveButton;
@property (nonatomic, retain) IBOutlet UIView *triggersView;
@property (nonatomic, retain) IBOutlet UIView *loopsView;
@property (nonatomic, retain) IBOutlet UIView *bandLoopsView;

@property (nonatomic, retain) NSArray *playerControllers;

@property testApp *OFSAptr;

- (void) bringMenu:(id)sender;
- (void) checkState:(id)sender;
- (void) play:(id)sender;
- (void) record:(id)sender;
- (void) save:(id)sender;

//- (void) updateTables;

@end
