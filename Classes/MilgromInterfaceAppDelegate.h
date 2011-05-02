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
@class SoloViewController;
@class SaveViewController;
@class ShareViewController;
@class HelpViewController;
@class BandMenu;
@class ShareManager;
@class SlidesManager;
@class EAGLView;
@class RKUBackgroundTask;
class testApp;



@interface MilgromInterfaceAppDelegate : NSObject <UIApplicationDelegate,DemoLoaderDelegate,AVAudioSessionDelegate> {
    UIWindow *window;
	UINavigationController *navigationController;

	NSManagedObjectContext *managedObjectContext_;
	NSManagedObjectModel *managedObjectModel_;
	NSPersistentStoreCoordinator *persistentStoreCoordinator_;
	
	
	testApp *OFSAptr;
	
	NSMutableArray *queuedDemos;
	
	BandMenu *bandMenu;
	MainViewController *mainViewController;
	SoloViewController *soloViewController;
	SaveViewController *saveViewController;
	ShareViewController *shareViewController;
	HelpViewController *helpViewController;
	
	Song *currentSong;
	
	ShareManager *shareManager;
	SlidesManager *slidesManager;
	NSInteger lastSavedVersion;
	
	EAGLView *eAGLView;
	
//	NSNumber *videoBitrate;
	
	RKUBackgroundTask *loadTask;
	
	
}


@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic,retain) IBOutlet EAGLView *eAGLView;
@property (nonatomic, retain) BandMenu *bandMenu;
@property (nonatomic,retain ) MainViewController *mainViewController;
@property (nonatomic,retain ) SoloViewController *soloViewController;
@property (nonatomic,retain) SaveViewController *saveViewController;
@property (nonatomic,retain) ShareViewController *shareViewController;
@property (nonatomic,retain) HelpViewController *helpViewController;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain,readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property testApp *OFSAptr;
@property (nonatomic, retain) NSMutableArray *queuedDemos;
@property (nonatomic, retain) Song *currentSong;
@property (nonatomic, retain) RKUBackgroundTask *loadTask;

@property (nonatomic, retain) ShareManager *shareManager;
@property (nonatomic, retain) SlidesManager *slidesManager;
@property NSInteger lastSavedVersion;



//@property (nonatomic, retain) NSNumber *videoBitrate;

- (NSString *)applicationDocumentsDirectory;
- (void)saveContext;
- (void)loadSong:(Song*)song;
- (SoundSet*)getCurrentSoundSet;
- (Song*)getDemoForCurrentSoundSet;
- (BOOL)loadSoundSetByDemo:(Song*)demo;
- (void)main;
- (void)soloAnimated:(BOOL)animated;
- (void)share;
- (void)save;
- (BOOL)canSaveSongName:(NSString *)songName;
- (void)saveSong:(NSString *)songName;
- (void)pushViewController:(UIViewController *)controller;
- (void)helpWithTransition:(UIModalTransitionStyle)transition;
- (void)playURL:(NSURL *)url;
+ (void)alertWithTitle:(NSString *)title withMessage:(NSString *)msg withCancel:(NSString *)cancel;

@end

