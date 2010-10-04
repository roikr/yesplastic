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

@class MilgromViewController;
@class Song;
@class MainViewController;
@class ShareViewController;
@class YouTubeUploadViewController;
@class BandMenu;
@class AVPlayerDemoPlaybackViewController;
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
	ShareViewController *shareViewController;
	YouTubeUploadViewController *youTubeViewController;
	
	AVPlayerDemoPlaybackViewController* mPlaybackViewController;
	
}

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

@property (nonatomic,retain ) ShareViewController *shareViewController;
@property (nonatomic,retain ) YouTubeUploadViewController *youTubeViewController;

- (NSString *)applicationDocumentsDirectory;
- (void)saveContext;
- (void)loadSong:(Song*)song;
-(BOOL)canSave:(NSString *)songName;
- (void)saveSong:(NSString *)songName;
- (void)pushSetMenu;
- (void)pushMain;
- (void)pop;
- (void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated;
- (void)dismissModalViewControllerAnimated:(BOOL)animated;
- (void)share;
- (void)youTubeUpload;
- (void)play;
+ (void)alertWithTitle:(NSString *)title withMessage:(NSString *)msg withCancel:(NSString *)cancel;
@end

