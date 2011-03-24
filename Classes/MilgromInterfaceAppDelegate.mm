//
//  MilgromInterfaceAppDelegate.m
//  MilgromInterface
//
//  Created by Roee Kremer on 7/22/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "MilgromInterfaceAppDelegate.h"
#import "BandMenu.h"
#import "SongsTable.h"
#import "URLCacheAlert.h"
#import "MilgromMacros.h"
#import "ZipArchive.h"
#include "testApp.h"
#include "Constants.h"
#include "Song.h"
#include "VideoSet.h"
#include "SoundSet.h"
#import "MainViewController.h"
#import "HelpViewController.h"
#include "PlayerMenu.h"
#import "AVPlayerDemoPlaybackViewController.h"
#import <CoreMedia/CoreMedia.h>

#import "ShareManager.h"
#import <OpenGLES/EAGL.h>
#import "EAGLView.h"
#import "RKUBackgroundTask.h"


NSString * const kMilgromFileServerURL=@"roikr.com";
NSString * const kCacheFolder=@"URLCache";

@interface NSObject (PrivateMethods)

/*
 - (void) initUI;
 - (void) buttonsEnabled:(BOOL)flag;
 - (void) getFileModificationDate;
 - (void) displayImageWithURL:(NSURL *)theURL;
 - (void) displayCachedImage;
*/
- (void) swapView:(UIView *)firstView with:(UIView *)secondView completion:(void (^)(BOOL finished))completion;
- (void) continueLaunching;
 - (void) initCache;
 - (void) clearCache;
+ (void)unzipPrecache;
- (void)addDemos;
- (void)addDemo:(NSArray *)theArray bpm:(NSInteger)bpm download:(BOOL)bDownload;
- (void)loadDemos;
- (void) play;
+ (void)alertWithTitle:(NSString *)title withMessage:(NSString *)msg withCancel:(NSString *)cancel;
- (void) loadSongLoop;
//- (void) loadSoundSetLoop;
@end

@implementation MilgromInterfaceAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize eAGLView;


@synthesize mainViewController;
@synthesize bandMenu;
@synthesize playerControllers;
@synthesize OFSAptr;
@synthesize queuedDemos;


@synthesize currentSong;
@synthesize loadTask;
@synthesize lastSavedVersion;
@synthesize shareManager;

//@synthesize videoBitrate;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    
	// Override point for customization after application launch.
	
		
//	self.videoBitrate = [NSNumber numberWithDouble:350.0*1000.0]; // 350.0*1024.0
	self.OFSAptr = new testApp;
	self.shareManager = [ShareManager shareManager];
	
	
	// implicitly initializes your audio session
	AVAudioSession *session = [AVAudioSession sharedInstance];
	session.delegate = self;
	
	//self.mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
	
	
//	if (self.milgromViewController == nil) { // this check use in case of loading after warning message...
//		self.milgromViewController = [[MilgromViewController alloc] initWithNibName:@"MilgromViewController" bundle:nil];
//	}
//	
//	window.rootViewController = milgromViewController;
	[window makeKeyAndVisible]; // we access OFSAptr in start animation...
	self.bandMenu = (BandMenu *)viewController.visibleViewController; 
	
	
	[self performSelectorInBackground:@selector(unzipPrecache) withObject:nil];
	//[self performSelector:@selector(unzipPrecache) withObject:nil];
	
    return YES;
}


-(void)addDemo:(NSArray *)theArray bpm:(NSInteger)bpm download:(BOOL)bDownload {
	
	Song *song= (Song *)[NSEntityDescription insertNewObjectForEntityForName:@"Song" inManagedObjectContext:self.managedObjectContext];
	[song setSongName:[theArray objectAtIndex:0]];
	[song setBLocked:[NSNumber numberWithBool:NO]];
	[song setBDemo:[NSNumber numberWithBool:YES]];
	if (!bDownload) {
		[song setBReady:[NSNumber numberWithBool:YES]];  
	}
	[song setBpm:[NSNumber numberWithInteger:bpm]];
	
	SoundSet *soundSet;
	VideoSet *videoSet;
	soundSet= (SoundSet *)[NSEntityDescription insertNewObjectForEntityForName:@"SoundSet" inManagedObjectContext:self.managedObjectContext];
	[soundSet setDemo:song];
	[soundSet setSetName:[theArray objectAtIndex:1]];
	[soundSet setFilename:[NSString stringWithFormat:@"%@.zip",[theArray objectAtIndex:1]]];
	videoSet= (VideoSet *)[NSEntityDescription insertNewObjectForEntityForName:@"VideoSet" inManagedObjectContext:self.managedObjectContext];
	[videoSet setSetName:[theArray objectAtIndex:2]];
	[videoSet setFilename:[NSString stringWithFormat:@"%@.zip",[theArray objectAtIndex:2]]];
	[soundSet setVideoSet:videoSet];
	[soundSet setPlayerNum:[NSNumber numberWithInt:0]];
	[song addSoundSetsObject:soundSet];
	
	soundSet= (SoundSet *)[NSEntityDescription insertNewObjectForEntityForName:@"SoundSet" inManagedObjectContext:self.managedObjectContext];
	[soundSet setDemo:song];
	[soundSet setSetName:[theArray objectAtIndex:3]];
	[soundSet setFilename:[NSString stringWithFormat:@"%@.zip",[theArray objectAtIndex:3]]];
	videoSet= (VideoSet *)[NSEntityDescription insertNewObjectForEntityForName:@"VideoSet" inManagedObjectContext:self.managedObjectContext];
	[videoSet setSetName:[theArray objectAtIndex:4]];
	[videoSet setFilename:[NSString stringWithFormat:@"%@.zip",[theArray objectAtIndex:4]]];
	[soundSet setVideoSet:videoSet];
	[soundSet setPlayerNum:[NSNumber numberWithInt:1]];
	[song addSoundSetsObject:soundSet];
	
	
	soundSet= (SoundSet *)[NSEntityDescription insertNewObjectForEntityForName:@"SoundSet" inManagedObjectContext:self.managedObjectContext];
	[soundSet setDemo:song];
	[soundSet setSetName:[theArray objectAtIndex:5]];
	[soundSet setFilename:[NSString stringWithFormat:@"%@.zip",[theArray objectAtIndex:5]]];
	videoSet= (VideoSet *)[NSEntityDescription insertNewObjectForEntityForName:@"VideoSet" inManagedObjectContext:self.managedObjectContext];
	[videoSet setSetName:[theArray objectAtIndex:6]];
	[videoSet setFilename:[NSString stringWithFormat:@"%@.zip",[theArray objectAtIndex:6]]];
	[soundSet setVideoSet:videoSet];
	[soundSet setPlayerNum:[NSNumber numberWithInt:2]];
	[song addSoundSetsObject:soundSet];
	
}

- (void)addDemos {
	[self addDemo:[NSArray arrayWithObjects:@"BOY",@"GTR_BOY",@"GTR_ROCK",@"VOC_BOY",@"VOC_CORE",@"DRM_BOY",@"DRM_OLDSCHOOL",nil] bpm:136 download:NO];
	[self addDemo:[NSArray arrayWithObjects:@"BUNNY",@"GTR_BUNNY",@"GTR_ROCK",@"VOC_BUNNY",@"VOC_POP",@"DRM_BUNNY",@"DRM_OLDSCHOOL",nil] bpm:160 download:NO];
	[self addDemo:[NSArray arrayWithObjects:@"DOG",@"GTR_DOG",@"GTR_ELECTRO",@"VOC_DOG",@"VOC_BB",@"DRM_DOG",@"DRM_ELECTRO",nil] bpm:131 download:NO ];
	[self addDemo:[NSArray arrayWithObjects:@"HOT",@"GTR_HOT",@"GTR_ROCK",@"VOC_HOT",@"VOC_POP",@"DRM_HOT",@"DRM_ELECTRO",nil] bpm:100 download:NO ];
	[self addDemo:[NSArray arrayWithObjects:@"PACIFIST",@"GTR_PACIFIST",@"GTR_FUNK",@"VOC_PACIFIST",@"VOC_HH",@"DRM_PACIFIST",@"DRM_NEOJAZZ",nil] bpm:146 download:NO];
	[self addDemo:[NSArray arrayWithObjects:@"SALAD",@"GTR_SALAD",@"GTR_SHORTS",@"VOC_SALAD",@"VOC_CORE",@"DRM_SALAD",@"DRM_ROCK",nil] bpm:160 download:NO];
	[self addDemo:[NSArray arrayWithObjects:@"SUMMER",@"GTR_SUMMER",@"GTR_SHORTS",@"VOC_SUMMER",@"VOC_POP",@"DRM_SUMMER",@"DRM_ROCK",nil] bpm:92 download:NO];
	[self addDemo:[NSArray arrayWithObjects:@"PLASTIC",@"GTR_PLASTIC",@"GTR_FUNK",@"VOC_PLASTIC",@"VOC_BB",@"DRM_PLASTIC",@"DRM_NEOJAZZ",nil] bpm:118 download:NO];
	
	[self saveContext];
	
	
	//[songsArray addObject:song];
	
	//NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	//[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	//[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
	
	//NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([songsArray count]-1) inSection:0];
	//[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	//[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


- (void)unzipPrecache {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	if (!documentsDirectory) {
		MilgromLog(@"Documents directory not found!");
		return;
	}
	
	
	
	// if (![[NSFileManager defaultManager] fileExistsAtPath:[documentsDirectory stringByAppendingPathComponent:@"data"]]) { // roikr: first time run check for release
		
//	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"unzipped"];
	
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"unzipped"]) {
		
		RKUBackgroundTask *task = [RKUBackgroundTask backgroundTask];
		
		NSString * precache = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"zip" inDirectory:@"precache"];
		
		if (precache) {
			MilgromLog(@"unzipping precache");
			[bandMenu.activityIndicator startAnimating];
			bandMenu.firstLaunchView.hidden = NO;
			ZipArchive *zip = [[ZipArchive alloc] init];
			[zip UnzipOpenFile:precache];
			[zip UnzipFileTo:[paths objectAtIndex:0] overWrite:YES];
			[zip UnzipCloseFile];
			
			
		} 
		
		[self addDemos];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"unzipped"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[task finish];
		
		while ([UIApplication sharedApplication].applicationState != UIApplicationStateActive); // stay here while in background
	}
	
	
	[self performSelectorOnMainThread:@selector(continueLaunching) withObject:nil waitUntilDone:NO];
	[pool release];
}

- (void) swapView:(UIView *)firstView with:(UIView *)secondView completion:(void (^)(BOOL finished))completion {
	[UIView animateWithDuration:0.1 delay:2.0 options: UIViewAnimationOptionTransitionNone | UIViewAnimationOptionCurveEaseInOut 
					 animations:^{
						 firstView.alpha = 0.0;
						 secondView.alpha = 1.0;
						 
					 } 
					 completion:^(BOOL finished){ 
						 
						 [firstView removeFromSuperview];
						 completion(YES);}];
}

- (void) continueLaunching {
	
	[self loadDemos];
	[bandMenu.songsTable loadData];
	[bandMenu updateEditMode];
	
	// TODO: move the update loop from here to main view controller
	
	OFSAptr->setup();
	[eAGLView setInterfaceOrientation:UIInterfaceOrientationLandscapeRight duration:0];
	
	if (self.mainViewController == nil) { // this check use in case of loading after warning message...
		self.mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
	}
	
	
	/* turn off the NSURLCache shared cache */
	
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0
                                                            diskCapacity:0
                                                                diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    [sharedCache release];
	
    /* prepare to use our own on-disk cache */
	[self initCache];
	[bandMenu.activityIndicator stopAnimating];
	
	[UIView animateWithDuration:0.1 delay:0.0 options: UIViewAnimationOptionTransitionNone | UIViewAnimationOptionCurveEaseInOut 
		 animations:^{
			 bandMenu.firstLaunchView.alpha = 0.0;
			 bandMenu.milgromView.alpha = 1.0;

			 
		 } 
		 completion:^(BOOL finished){
		 
			[bandMenu.firstLaunchView removeFromSuperview];
			 [self swapView:bandMenu.milgromView with:bandMenu.lofiView 
				 completion:^(BOOL finished){
					 
					 [self swapView:bandMenu.lofiView with:bandMenu.menuView 
						 completion:^(BOOL finished){}]; 
				 }];
		 }];
	
}

- (void)beginInterruption {
	MilgromLog(@"beginInterruption");
	OFSAptr->soundStreamStop();
}

- (void)endInterruptionWithFlags:(NSUInteger)flags {
	MilgromLog(@"endInterruptionWithFlags: %u",flags);
	
	if (flags && AVAudioSessionInterruptionFlags_ShouldResume) {
		NSError *activationError = nil;
		[[AVAudioSession sharedInstance] setActive: YES error: &activationError];
		OFSAptr->soundStreamStart();
		MilgromLog(@"audio session activated");
	}
	
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
	//[UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeRight;
	
	[mainViewController applicationDidEnterBackground];	
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	
	[self saveContext];
	
	[eAGLView stopAnimation];
	
	if (!loadTask) {
		[bandMenu.songsTable deselectCurrentSong];
		self.currentSong = NULL;
		OFSAptr->setSongState(SONG_IDLE);
		OFSAptr->stopLoops();
		OFSAptr->release();
	}
	
	[shareManager applicationDidEnterBackground];
	
	
	
		
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
	MilgromLog(@"applicationWillEnterForeground deviceOrientation: %i",[[UIDevice currentDevice] orientation]);
	MilgromLog(@"applicationWillEnterForeground viewController orientation: %i",viewController.interfaceOrientation);
	MilgromLog(@"applicationWillEnterForeground mainViewController orientation: %i",mainViewController.interfaceOrientation);
	
	[viewController popToRootViewControllerAnimated:NO];
	[viewController dismissModalViewControllerAnimated:NO];
	viewController.view.transform = CGAffineTransformIdentity;
	viewController.view.transform = CGAffineTransformMakeRotation(0.5*M_PI);
//	mainViewController.view.transform = CGAffineTransformMakeRotation(0.5*M_PI);
	[eAGLView setInterfaceOrientation:UIInterfaceOrientationLandscapeRight duration:0];
	
		
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    
	/*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
	
	if (OFSAptr) {
		OFSAptr->soundStreamStart();
	}
	
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
	 [eAGLView stopAnimation];
	[self saveContext];
}


- (void)saveContext {
    
    NSError *error = nil;
    if (managedObjectContext_ != nil) {
        if ([managedObjectContext_ hasChanges] && ![managedObjectContext_ save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			MilgromLog(@"MilgromInterfaceAppDelegate:addSong error: %@",[error description]);
            abort();
        } 
    }
}    

+ (void)alertWithTitle:(NSString *)title withMessage:(NSString *)msg withCancel:(NSString *)cancel {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:cancel otherButtonTitles: nil];	
	[alert show];
	[alert release];
	
}



- (void)dealloc {
	[managedObjectContext_ release];
	[managedObjectModel_ release];
	[persistentStoreCoordinator_ release];
	//TODO: release player controllers
	[mainViewController release];
	[window release];
	[eAGLView release];
	[viewController release];
    [super dealloc];
}

#pragma mark -
#pragma mark URLCache 
- (void) initCache
{
	/* create path to cache directory inside the application's Documents directory */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:kCacheFolder];
	
	/* check for existence of cache directory */
	if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
		return;
	}
	
	 NSError *error = nil;
	
	/* create a new cache directory */
	if (![[NSFileManager defaultManager] createDirectoryAtPath:dataPath
								   withIntermediateDirectories:NO
													attributes:nil
														 error:&error]) {
		URLCacheAlertWithError(error);
		return;
	}
}


/* removes every file in the cache directory */

- (void) clearCache
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:kCacheFolder];
	
	
	NSError *error = nil;	
	/* remove the cache directory and its contents */
	if (![[NSFileManager defaultManager] removeItemAtPath:dataPath error:&error]) {
		URLCacheAlertWithError(error);
		return;
	}
	
	/* create a new cache directory */
	if (![[NSFileManager defaultManager] createDirectoryAtPath:dataPath
								   withIntermediateDirectories:NO
													attributes:nil
														 error:&error]) {
		URLCacheAlertWithError(error);
		return;
	}
	
	//[self initUI];
}



#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext_;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"Milgrom" ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel_;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
     
    NSError *error = nil;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	
	NSURL *milgromStoreURL = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"Milgrom.sqlite"]];
	if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:@"Milgrom" URL:milgromStoreURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
	
	
	
//	NSURL *templatesStoreURL = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"Templates.sqlite"]];
//    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:@"Templates" URL:templatesStoreURL options:nil error:&error]) {
//        /*
//         Replace this implementation with code to handle the error appropriately.
//         
//         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
//         
//         Typical reasons for an error here include:
//         * The persistent store is not accessible;
//         * The schema for the persistent store is incompatible with current managed object model.
//         Check the error message to determine what the actual problem was.
//         
//         
//         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
//         
//         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
//         * Simply deleting the existing store:
//         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
//         
//         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
//         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
//         
//         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
//         
//         */
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }   
	
    
    return persistentStoreCoordinator_;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}




#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
	
}


#pragma mark -
#pragma mark Navigation Stack

- (void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated {
	[self.viewController presentModalViewController:modalViewController animated:animated];
}

- (void)dismissModalViewControllerAnimated:(BOOL)animated {
	[self.viewController dismissModalViewControllerAnimated:animated];
}



- (void)pushMain {
	
	[viewController pushViewController:self.mainViewController animated:YES];
	
	
	
}


- (void)pushSetMenu {
	//TODO: replace with NULL as done in the page controll example
	
	if (self.playerControllers == nil) { // this check use in case of loading after warning message...
		NSMutableArray *controllers = [[NSMutableArray alloc] init];
		for (unsigned i = 0; i < 3; i++) {
			PlayerMenu *controller = [[PlayerMenu alloc] initWithNibName:@"PlayerMenu" bundle:nil];
			controller.playerName = [NSString stringWithCString:OFSAptr->getPlayerName(i).c_str() encoding:NSASCIIStringEncoding];
			
			//PlayerViewContorller *controller = [[PlayerViewContorller alloc] init];
			//controller.mainController = self;
			[controllers addObject:controller];
			[controller release];
		}
		self.playerControllers = [NSArray arrayWithArray:controllers];
		[controllers release];
	}
	
	//topMenu.hidden = YES;
	PlayerMenu *controller = [playerControllers objectAtIndex:OFSAptr->controller];
	
	//[controller show];
	[viewController pushViewController:controller animated:YES];
	//[self presentModalViewController:controller animated:YES];
	//controller.view.hidden = NO;
	//OFSAptr->bMenu=true; // TODO: change upon return
}


- (void)playURL:(NSURL *)url {
	
	AVPlayerDemoPlaybackViewController* mPlaybackViewController = [[[AVPlayerDemoPlaybackViewController allocWithZone:[self zone]] init] autorelease];
	
	[mPlaybackViewController setURL:url]; //[NSURL fileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"video.mov"]]
	[[mPlaybackViewController player] seekToTime:CMTimeMakeWithSeconds(0.0, NSEC_PER_SEC) toleranceBefore:CMTimeMake(1, 2 * NSEC_PER_SEC) toleranceAfter:CMTimeMake(1, 2 * NSEC_PER_SEC)];
	
	//[[mPlaybackViewController player] seekToTime:CMTimeMakeWithSeconds([defaults doubleForKey:AVPlayerDemoContentTimeUserDefaultsKey], NSEC_PER_SEC) toleranceBefore:CMTimeMake(1, 2 * NSEC_PER_SEC) toleranceAfter:CMTimeMake(1, 2 * NSEC_PER_SEC)];
	
	[self presentModalViewController:mPlaybackViewController animated:NO];
}

- (void)pushViewController:(UIViewController *)controller {
	[viewController pushViewController:controller animated:YES];
}

- (void) popViewController {
	[viewController popViewControllerAnimated:YES];
}

- (void)help {
	HelpViewController *helpView = [[HelpViewController alloc] initWithNibName:@"HelpViewController" bundle:nil];
	helpView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	
	[self presentModalViewController:helpView animated:YES];
}

#pragma mark -
#pragma mark Songs Management


-(BOOL)canSaveSongName:(NSString *)songName {
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Song" inManagedObjectContext:self.managedObjectContext];
	[request setEntity:entity];
	
		
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"songName like %@",songName];
							 	
	[request setPredicate:predicate];
	
	
	NSError *error;
	
	NSArray *fetchResults = [self.managedObjectContext executeFetchRequest:request error:&error];
	
	if (fetchResults==nil) {
		return NO;
	}
	
	if ([fetchResults count]) {
	
		Song *song = (Song *)[fetchResults objectAtIndex:0];
		if ([song.bDemo boolValue]) {
			return NO;
		}
	}
	
	return YES;

	
	
}


-(void)saveSong:(NSString *)songName {
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Song" inManagedObjectContext:self.managedObjectContext];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"songName like %@",songName];
	[request setPredicate:predicate];
	
	NSError *error;
	NSArray *fetchResults = [self.managedObjectContext executeFetchRequest:request error:&error];
	[request release];
	request = nil;
	if (fetchResults==nil) {
		return;
	}
	
	
	if ([fetchResults count]) {
		self.currentSong = (Song *)[fetchResults objectAtIndex:0];
		
		
		// if the song allready exist, need to reset it exporting and rendering attribute upon saving
		
		[currentSong setBVideoRendered:[NSNumber numberWithBool:NO]];
		[currentSong setBRingtoneExprted:[NSNumber numberWithBool:NO]];
	}
	else {
		self.currentSong = (Song *)[NSEntityDescription insertNewObjectForEntityForName:@"Song" inManagedObjectContext:self.managedObjectContext];
		[currentSong setSongName:songName];
		
		[currentSong setBReady:[NSNumber numberWithBool:YES]];
		[currentSong setBDemo:[NSNumber numberWithBool:NO]];
		
		[bandMenu.songsTable addCurrentSong]; // TODO: here ?
		
		

	} 
	
	[bandMenu.songsTable selectCurrentSong];
	[bandMenu updateEditMode];

	OFSAptr->saveSong([songName UTF8String]);
	
	lastSavedVersion = OFSAptr->getSongVersion();
	
	
	request = [[NSFetchRequest alloc] init];
	entity = [NSEntityDescription entityForName:@"SoundSet" inManagedObjectContext:self.managedObjectContext];
	[request setEntity:entity];
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:
								[[NSSortDescriptor alloc] initWithKey:@"playerNum" ascending:YES],
									nil];
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptors release];
	
	
		
	predicate = [NSPredicate predicateWithFormat:@"setName like %@ || setName like %@ || setName like %@",
							  [NSString stringWithCString:OFSAptr->getCurrentSoundSetName(0).c_str() encoding:NSASCIIStringEncoding],
							  [NSString stringWithCString:OFSAptr->getCurrentSoundSetName(1).c_str() encoding:NSASCIIStringEncoding],
							  [NSString stringWithCString:OFSAptr->getCurrentSoundSetName(2).c_str() encoding:NSASCIIStringEncoding]];
    
	
	[request setPredicate:predicate];
	
	
	
	fetchResults = [self.managedObjectContext executeFetchRequest:request error:&error];
	
	if (fetchResults == nil) {
	}
	
	[currentSong setSoundSets:[NSSet setWithArray:fetchResults]];
	[currentSong setBpm:[NSNumber numberWithInteger:OFSAptr->getBPM()]];
	[request release];
	
	
	[self saveContext];
	
}

- (void)loadSong:(Song*)song {
	
	bandMenu.view.userInteractionEnabled = NO;
	
	if (currentSong && song ==  currentSong) {
		MilgromLog(@"loadSong::willSelectRowAtIndexPath: Song already selected");

		if (viewController.interfaceOrientation == UIInterfaceOrientationLandscapeRight || viewController.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
			[self pushMain];
		} else {
			bandMenu.view.userInteractionEnabled = YES;
		}

		return;
	}
	
	self.currentSong = song;
	//self.currentSoundSets = nil; // TODO: check if it really frees...
	//self.currentSoundSets = [NSMutableArray arrayWithArray:[song.soundSets allObjects]];
		
	OFSAptr->setSongState(SONG_IDLE); // if there is previous song which is playing there...
	
	string nextSong = [song.songName UTF8String];
	
	self.loadTask = [RKUBackgroundTask backgroundTask];
		
	if ([song.bDemo boolValue]) {
		if (  !OFSAptr->isInTransition() && OFSAptr->isSongAvailiable(nextSong)) {
			
			OFSAptr->loadSong(nextSong,true);
			OFSAptr->setBPM([song.bpm integerValue]);
		}
		
	} else {
		OFSAptr->loadSong([song.songName UTF8String],false);
		OFSAptr->setBPM([song.bpm integerValue]);
	}
	
	lastSavedVersion = OFSAptr->getSongVersion();
		
		//[milgromViewController setContextCurrent];
	
		
	NSArray *modes = [[[NSArray alloc] initWithObjects:NSDefaultRunLoopMode, UITrackingRunLoopMode, nil] autorelease];
	[self performSelector:@selector(loadSongLoop) withObject:nil afterDelay:0.01 inModes:modes];
		 
		
	
	
}

- (void) loadSongLoop {
	
	if (OFSAptr->isInTransition()) {
		OFSAptr->transitionLoop(); // now update is not linked to frame
		[bandMenu.songsTable updateSong:currentSong WithProgress:OFSAptr->getProgress()];
		NSArray *modes = [[[NSArray alloc] initWithObjects:NSDefaultRunLoopMode, UITrackingRunLoopMode, nil] autorelease];
		[self performSelector:@selector(loadSongLoop) withObject:nil afterDelay:0.01 inModes:modes];
	} else {
		
		[bandMenu.songsTable updateSong:currentSong WithProgress:1.0f];
		[loadTask finish];
		self.loadTask = nil;
		
		if (viewController.interfaceOrientation == UIInterfaceOrientationLandscapeRight || viewController.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
			[self pushMain]; // TODO: prevent double push
		} else {
			bandMenu.view.userInteractionEnabled = YES;
			[bandMenu.songsTable hideCurrentSongProgress];
		}

		
	}
	
}

- (SoundSet*)getCurrentSoundSet {
	NSFetchRequest * request = [[NSFetchRequest alloc] init];
	NSEntityDescription * entity = [NSEntityDescription entityForName:@"SoundSet" inManagedObjectContext:self.managedObjectContext];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"setName like %@",
							  [NSString stringWithCString:OFSAptr->getCurrentSoundSetName(OFSAptr->controller).c_str() encoding:NSASCIIStringEncoding]];
    
	
	[request setPredicate:predicate];
	
	NSError *error;
	NSArray * fetchResults = [self.managedObjectContext executeFetchRequest:request error:&error];
	
	if (fetchResults == nil) {
	}
	
	return [fetchResults count] ? [fetchResults objectAtIndex:0] : nil;
}

- (Song*)getDemoForCurrentSoundSet {
	return [[self getCurrentSoundSet] demo];
}

- (BOOL)loadSoundSetByDemo:(Song*)demo {
	
	string nextSong = [demo.songName UTF8String];
	if (OFSAptr->isInTransition() || !OFSAptr->isSongAvailiable(nextSong)) {
		return NO;
	}
	
	//OFSAptr->bMenu=false;
	
	self.loadTask = [RKUBackgroundTask backgroundTask];
	
	OFSAptr->changeSoundSet(nextSong);
	lastSavedVersion = 0;

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		while (OFSAptr->isInTransition()) {
			[eAGLView setSecondaryContextCurrent];
			OFSAptr->transitionLoop(); 
		}
		
		[loadTask finish];
		self.loadTask = nil;
	
	});
	
		
	
	return YES;
	
}



-(void)loadDemos {
	
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Song" inManagedObjectContext:self.managedObjectContext];
	[request setEntity:entity];
	
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:
								[[NSSortDescriptor alloc] initWithKey:@"bDemo" ascending:YES],
								[[NSSortDescriptor alloc] initWithKey:@"songName" ascending:NO]
								,nil];
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptors release];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bDemo == YES AND bReady = NO"]; //  AND bReady == YES AND bLocked == NO
    [request setPredicate:predicate];
	
	NSError *error;
	NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	if (mutableFetchResults == nil) {
	}
	
	[self setQueuedDemos:mutableFetchResults];
	[mutableFetchResults release];
	[request release];
	
	if ([queuedDemos count]) {
		[[DemoLoader alloc] initWithSong:[queuedDemos objectAtIndex:0] delegate:self];
	}
			
	
//	dispatch_queue_t myCustomQueue = dispatch_queue_create("demosQueue", NULL);
//	dispatch_retain(myCustomQueue);
//	
//	dispatch_async(myCustomQueue, ^{
//	});		
		
}






#pragma mark -
#pragma mark DemoLoader methods



- (void) loaderDidFinish:(DemoLoader *)theLoader {
	
	Song *song = theLoader.song;
	MilgromLog(@"Song: %@ is ready",[song songName]);
	
	[queuedDemos removeObject:song];
	
	if ([queuedDemos count]) {
		[[DemoLoader alloc] initWithSong:[queuedDemos objectAtIndex:0] delegate:self];
	}
	/*
	if ([queuedDemos count]) {
				
		dispatch_async(myCustomQueue, ^{
			[[DemoLoader alloc] initWithSong:[queuedDemos objectAtIndex:0] delegate:self];
		});
	
	} else
		dispatch_release(myCustomQueue);
	*/
	// TODO: clean on exit
	
	//[self update];
	
	
}

- (void) loader:(DemoLoader *)theLoader withProgress:(float)theProgress {
	
	Song *song = theLoader.song;
	
	[bandMenu.songsTable updateSong:song WithProgress:theProgress];
	
}




@end
