//
//  MilgromInterfaceAppDelegate.h
//  MilgromInterface
//
//  Created by Roee Kremer on 7/22/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "DemoLoader.h"

extern NSString * const kCacheFolder;
extern NSString * const kMilgromURL;

@class EAGLContext;
@class MilgromViewController;
@class Song;
@class SoundSet;
@class MainViewController;
@class BandMenu;
@class AVPlayerDemoPlaybackViewController;
@class ShareManager;
class testApp;



@interface MilgromInterfaceAppDelegate : NSObject <UIApplicationDelegate,DemoLoaderDelegate> {
    UIWindow *window;
	
	NSManagedObjectContext *managedObjectContext_;
	NSManagedObjectModel *managedObjectModel_;
	NSPersistentStoreCoordinator *persistentStoreCoordinator_;
	
	MilgromViewController *milgromViewController;
	
	testApp *OFSAptr;
	
	NSMutableArray *queuedDemos;
	
	BandMenu *bandMenu;
	NSArray *playerControllers;
	MainViewController *mainViewController;
	
	AVPlayerDemoPlaybackViewController* mPlaybackViewController;
	
	Song *currentSong;
	
	ShareManager *shareManager;
	
	//BOOL rendering;
}

@property (nonatomic, retain,readonly) EAGLContext *context;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MilgromViewController *milgromViewController;

@property (nonatomic, retain) BandMenu *bandMenu;
@property (nonatomic,retain ) MainViewController *mainViewController;
@property (nonatomic, retain) NSArray *playerControllers;


@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain,readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property testApp *OFSAptr;
@property (nonatomic, retain) NSMutableArray *queuedDemos;
@property (nonatomic, retain) Song *currentSong;

@property (nonatomic, retain) ShareManager *shareManager;
//@property BOOL rendering;

- (NSString *)applicationDocumentsDirectory;
- (void)saveContext;
- (void)loadSong:(Song*)song;
- (SoundSet*)getCurrentSoundSet;
- (Song*)getDemoForCurrentSoundSet;
- (BOOL)loadSoundSetByDemo:(Song*)demo;
- (BOOL)canSaveSongName:(NSString *)songName;
- (BOOL)canSave;
- (BOOL)canShare;
- (BOOL)isSongTemporary;
- (void)saveSong:(NSString *)songName;
- (void)pushSetMenu;
- (void)pushMain;
- (void)pushViewController:(UIViewController *)controller;
- (void)popViewController;
- (void)help;
- (void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated;
- (void)dismissModalViewControllerAnimated:(BOOL)animated;
- (void)play;
+ (void)alertWithTitle:(NSString *)title withMessage:(NSString *)msg withCancel:(NSString *)cancel;

@end

