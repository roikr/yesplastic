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
@class MenuViewController;

@interface MainViewController : UIViewController {

	EAGLView *glView;
	
	UIButton *playButton;
	UIButton *recordButton;
	UIButton *menuButton;
	UIButton *playerMenuButton;
	UIView *topMenu;
	UIToolbar *actionToolBar;
	testApp *OFSAptr;
	
	MenuViewController *menuController;
	
	NSArray *playerControllers;
	
}

@property (nonatomic, retain) IBOutlet EAGLView *glView;
@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UIButton *recordButton;
@property (nonatomic, retain) IBOutlet UIButton *menuButton;
@property (nonatomic, retain) IBOutlet UIButton *playerMenuButton;
@property (nonatomic, retain) IBOutlet UIView *topMenu;
@property (nonatomic, retain) IBOutlet UIToolbar *actionToolBar;
@property (nonatomic, retain) MenuViewController *menuController;
@property (nonatomic, retain) NSArray *playerControllers;

@property testApp *OFSAptr;

- (void) setupMenus;
- (void) bringMenu:(id)sender;
- (void) dismissMenu:(id)sender;
- (void) bringPlayerMenu:(id)sender;
- (void) dismissPlayerMenu:(id)sender;
- (void) checkSong:(id)sender;
- (void) play:(id)sender;
- (void) record:(id)sender;
- (void) updateTables;

@end
