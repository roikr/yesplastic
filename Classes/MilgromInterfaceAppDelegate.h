//
//  MilgromInterfaceAppDelegate.h
//  MilgromInterface
//
//  Created by Roee Kremer on 7/22/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <AVFoundation/AVFoundation.h>

#import "DemoLoader.h"

extern NSString * const kCacheFolder;
extern NSString * const kMilgromFileServerURL;


@class Song;
@class SoundSet;
@class MainViewController;
@class BandMenu;
@class ShareManager;
@class EAGLView;
@class RKUBackgroundTask;
class testApp;



@interface MilgromInterfaceAppDelegate : NSObject <UIApplicationDelegate,DemoLoaderDelegate,AVAudioSessionDelegate> {
    UIWindow *window;
	UINavigationController *viewController;

	NSManagedObjectContext *managedObjectContext_;
	NSManagedObjectModel *managedObjectModel_;
	NSPersistentStoreCoordinator *persistentStoreCoordinator_;
	
	
	testApp *OFSAptr;
	
	NSMutableArray *queuedDemos;
	
	BandMenu *bandMenu;
	NSArray *playerControllers;
	MainViewController *mainViewController;
	
	Song *currentSong;
	
	ShareManager *shareManager;
	NSInteger lastSavedVersion;
	
	EAGLView *eAGLView;
	
//	NSNumber *videoBitrate;
	
	RKUBackgroundTask *loadTask;
	
	UIInterfaceOrientation interfaceOrientation;
	
}


@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *viewController;
@property (nonatomic,retain) IBOutlet EAGLView *eAGLView;
@property (nonatomic, retain) BandMenu *bandMenu;
@property (nonatomic,retain ) MainViewController *mainViewController;
@property (nonatomic, retain) NSArray *playerControllers;


@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain,readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property testApp *OFSAptr;
@property (nonatomic, retain) NSMutableArray *queuedDemos;
@property (nonatomic, retain) Song *currentSong;
@property (nonatomic, retain) RKUBackgroundTask *loadTask;

@property (nonatomic, retain) ShareManager *shareManager;
@property NSInteger lastSavedVersion;
@property UIInterfaceOrientation interfaceOrientation;


//@property (nonatomic, retain) NSNumber *videoBitrate;

- (NSString *)applicationDocumentsDirectory;
- (void)saveContext;
- (void)loadSong:(Song*)song;
- (SoundSet*)getCurrentSoundSet;
- (Song*)getDemoForCurrentSoundSet;
- (BOOL)loadSoundSetByDemo:(Song*)demo;
- (BOOL)canSaveSongName:(NSString *)songName;
- (void)saveSong:(NSString *)songName;
- (void)pushSetMenu;
- (void)pushMain;
- (void)pushViewController:(UIViewController *)controller;
- (void)popViewController;
- (void)help;
- (void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated;
- (void)dismissModalViewControllerAnimated:(BOOL)animated;
- (void)playURL:(NSURL *)url;
+ (void)alertWithTitle:(NSString *)title withMessage:(NSString *)msg withCancel:(NSString *)cancel;

@end

