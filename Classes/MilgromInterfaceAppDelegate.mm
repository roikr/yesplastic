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
#import "MilgromViewController.h"
#import "URLCacheAlert.h"
#import "MilgromMacros.h"
#import "ZipArchive.h"
#include "testApp.h"
#include "Constants.h"
#include "Song.h"
#include "VideoSet.h"
#include "SoundSet.h"
#import "MainViewController.h"
#include "PlayerMenu.h"
#import "ShareViewController.h"
#import "AVPlayerDemoPlaybackViewController.h"
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>



NSString * const kMilgromURL=@"roikr.com";
NSString * const kCacheFolder=@"URLCache";

@interface NSObject (PrivateMethods)

/*
 - (void) initUI;
 - (void) startAnimation;
 - (void) stopAnimation;
 - (void) buttonsEnabled:(BOOL)flag;
 - (void) getFileModificationDate;
 - (void) displayImageWithURL:(NSURL *)theURL;
 - (void) displayCachedImage;
*/
 - (void) initCache;
 - (void) clearCache;
+ (BOOL)unzipPrecache;
- (void)addDemos;
- (void)addDemo:(NSArray *)theArray bpm:(NSInteger)bpm download:(BOOL)bDownload;
- (void)loadDemos;
- (void) play;
- (void) export;
@end

@implementation MilgromInterfaceAppDelegate

@synthesize window;
@synthesize milgromViewController;
@synthesize mainViewController;
@synthesize playerControllers;
@synthesize OFSAptr;
@synthesize queuedDemos;
@synthesize shareViewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    
	// Override point for customization after application launch.
	
	if ([MilgromInterfaceAppDelegate unzipPrecache])
		[self addDemos];
	
	[self loadDemos]; 
	
    // Add the view controller's view to the window and display.
	//[window addSubview:viewController.view]; // need to add before making visible to allow rotation
	//[window addSubview:milgromViewController.view];
	
   
		
	//[window bringSubviewToFront:viewController.view];
	
	
	//glView.controller = self;
	self.OFSAptr = new testApp;
	self.mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
	
	[window makeKeyAndVisible]; // we access OFSAptr in start animation...
	
	dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
	dispatch_async(aQueue, ^{
		while (1) {
			OFSAptr->threadedFunction();
			if (OFSAptr->bNeedDisplay) {
				if (mainViewController) {
					dispatch_async(dispatch_get_main_queue(), ^{
						[mainViewController updateViews];
					});
					OFSAptr->bNeedDisplay = false;
				}
			}
		}
	});
	
	OFSAptr->setup();
	OFSAptr->setState(BAND_STATE);
	//OFSAptr->lastFrame = 0;
	
	
	
	/* turn off the NSURLCache shared cache */
	
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0
                                                            diskCapacity:0
                                                                diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    [sharedCache release];
	
    /* prepare to use our own on-disk cache */
	[self initCache];
	
    return YES;
}




- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
	 [milgromViewController stopAnimation];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	[self saveContext];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
	[milgromViewController startAnimation];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
	 [milgromViewController stopAnimation];
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


- (void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated {
	[self.milgromViewController presentModalViewController:modalViewController animated:animated];
}

- (void)dismissModalViewControllerAnimated:(BOOL)animated {
	[self.milgromViewController dismissModalViewControllerAnimated:animated];
}




- (void)dealloc {
	[managedObjectContext_ release];
	[managedObjectModel_ release];
	[persistentStoreCoordinator_ release];
	//TODO: release player controllers
	[milgromViewController release];
	[mainViewController release];
    [window release];
    [super dealloc];
}


+ (BOOL)unzipPrecache {
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	if (!documentsDirectory) {
		MilgromLog(@"Documents directory not found!");
		return NO;
	}
	
	
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:[documentsDirectory stringByAppendingPathComponent:@"data"]]) { // roikr: first time run check for release
		NSString * precache = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"zip" inDirectory:@"precache"];
		
		if (precache) {
			MilgromLog(@"unzipping precache");
			
			ZipArchive *zip = [[ZipArchive alloc] init];
			[zip UnzipOpenFile:precache];
			[zip UnzipFileTo:[paths objectAtIndex:0] overWrite:YES];
			[zip UnzipCloseFile];
		} 
		/*
		 else {
		 NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"data"];
		 NSError * error = nil;
		 if (![[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]) {
		 URLCacheAlertWithError(error);
		 return;
		 }
		 
		 
		 }
		 */
		return YES;
		
	}
	return NO;
}

-(void)saveSong:(NSString *)songName {
	OFSAptr->saveSong([songName UTF8String]);
	
	Song *song= (Song *)[NSEntityDescription insertNewObjectForEntityForName:@"Song" inManagedObjectContext:self.managedObjectContext];
	[song setSongName:songName];
	
	[song setBReady:[NSNumber numberWithBool:YES]];
	[song setBDemo:[NSNumber numberWithBool:NO]];
	
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"SoundSet" inManagedObjectContext:self.managedObjectContext];
	[request setEntity:entity];
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:
								[[NSSortDescriptor alloc] initWithKey:@"playerNum" ascending:YES],
									nil];
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptors release];
	
	
		
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"setName like %@ || setName like %@ || setName like %@",
							  [NSString stringWithCString:OFSAptr->getCurrentSoundSetName(0).c_str() encoding:NSASCIIStringEncoding],
							  [NSString stringWithCString:OFSAptr->getCurrentSoundSetName(1).c_str() encoding:NSASCIIStringEncoding],
							  [NSString stringWithCString:OFSAptr->getCurrentSoundSetName(2).c_str() encoding:NSASCIIStringEncoding]];
    
	
	[request setPredicate:predicate];
	
	
	
	NSError *error;
	
	NSArray *fetchResults = [self.managedObjectContext executeFetchRequest:request error:&error];
	
	if (fetchResults == nil) {
	}
	
	[song setSoundSets:[NSSet setWithArray:fetchResults]];
	[song setBpm:[NSNumber numberWithInteger:OFSAptr->getBPM()]];
	[request release];
	
	
	[self saveContext];
	
	BandMenu *bandMenu = (BandMenu *)[milgromViewController.viewController.viewControllers objectAtIndex:0];
	
	[bandMenu.songsTable addSong:song];
	
	
}


- (void)loadSong:(Song*)song {
	//
	
	string nextSong = [song.songName UTF8String];
	if ([song.bDemo boolValue]) {
		if (  !OFSAptr->isInTransition() && OFSAptr->isSongAvailiable(nextSong)) {
			
			OFSAptr->loadSong(nextSong,true);
			OFSAptr->setBPM([song.bpm integerValue]);
		}
		
	} else {
		OFSAptr->loadSong([song.songName UTF8String],false);
		OFSAptr->setBPM([song.bpm integerValue]);
	}
	
	
	//[(BandMenu *)[milgromViewController.viewController.viewControllers objectAtIndex:0] back:nil];
}

- (void)addDemos {
	[self addDemo:[NSArray arrayWithObjects:@"HEAT",@"GTR_HEAT",@"GTR_ELECTRO",@"VOC_HEAT",@"VOC_BB",@"DRM_HEAT",@"DRM_ELECTRO",nil] bpm:126 download:NO ];
	[self addDemo:[NSArray arrayWithObjects:@"PACIFIST",@"GTR_PACIFIST",@"GTR_FUNK",@"VOC_PACIFIST",@"VOC_POP",@"DRM_PACIFIST",@"DRM_NEOJAZZ",nil] bpm:146 download:NO];
	[self addDemo:[NSArray arrayWithObjects:@"BOY",@"GTR_BOY",@"GTR_ROCK",@"VOC_BOY",@"VOC_HH",@"DRM_BOY",@"DRM_OLDSCHOOL",nil] bpm:136 download:NO];
	[self addDemo:[NSArray arrayWithObjects:@"SALAD",@"GTR_SALAD",@"GTR_SHORTS",@"VOC_SALAD",@"VOC_CORE",@"DRM_SALAD",@"DRM_ROCK",nil] bpm:160 download:NO];
	
	[self saveContext];
	
	
	//[songsArray addObject:song];
	
	//NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	//[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	//[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
	
	//NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([songsArray count]-1) inSection:0];
	//[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	//[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
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
	[soundSet setSetName:[theArray objectAtIndex:1]];
	[soundSet setFilename:[NSString stringWithFormat:@"%@.zip",[theArray objectAtIndex:1]]];
	videoSet= (VideoSet *)[NSEntityDescription insertNewObjectForEntityForName:@"VideoSet" inManagedObjectContext:self.managedObjectContext];
	[videoSet setSetName:[theArray objectAtIndex:2]];
	[videoSet setFilename:[NSString stringWithFormat:@"%@.zip",[theArray objectAtIndex:2]]];
	[soundSet setVideoSet:videoSet];
	[soundSet setPlayerNum:[NSNumber numberWithInt:0]];
	[song addSoundSetsObject:soundSet];
	
	soundSet= (SoundSet *)[NSEntityDescription insertNewObjectForEntityForName:@"SoundSet" inManagedObjectContext:self.managedObjectContext];
	[soundSet setSetName:[theArray objectAtIndex:3]];
	[soundSet setFilename:[NSString stringWithFormat:@"%@.zip",[theArray objectAtIndex:3]]];
	videoSet= (VideoSet *)[NSEntityDescription insertNewObjectForEntityForName:@"VideoSet" inManagedObjectContext:self.managedObjectContext];
	[videoSet setSetName:[theArray objectAtIndex:4]];
	[videoSet setFilename:[NSString stringWithFormat:@"%@.zip",[theArray objectAtIndex:4]]];
	[soundSet setVideoSet:videoSet];
	[soundSet setPlayerNum:[NSNumber numberWithInt:1]];
	[song addSoundSetsObject:soundSet];
	
	
	soundSet= (SoundSet *)[NSEntityDescription insertNewObjectForEntityForName:@"SoundSet" inManagedObjectContext:self.managedObjectContext];
	[soundSet setSetName:[theArray objectAtIndex:5]];
	[soundSet setFilename:[NSString stringWithFormat:@"%@.zip",[theArray objectAtIndex:5]]];
	videoSet= (VideoSet *)[NSEntityDescription insertNewObjectForEntityForName:@"VideoSet" inManagedObjectContext:self.managedObjectContext];
	[videoSet setSetName:[theArray objectAtIndex:6]];
	[videoSet setFilename:[NSString stringWithFormat:@"%@.zip",[theArray objectAtIndex:6]]];
	[soundSet setVideoSet:videoSet];
	[soundSet setPlayerNum:[NSNumber numberWithInt:2]];
	[song addSoundSetsObject:soundSet];
	
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
#pragma mark View Controller Stack Management

- (void)pushMain {
	if (self.mainViewController == nil) { // this check use in case of loading after warning message...
		self.mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
		//self.menuController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		
		
		//self.menuController = [[MenuViewController alloc] init];
		
		//menuController.mainController = self; // TODO: move testApp to app delegate
	}
	
	[milgromViewController.viewController pushViewController:self.mainViewController animated:YES];
	
	//[self dismissModalViewControllerAnimated:YES];
	//MilgromInterfaceAppDelegate *appDelegate = (MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate];
	//[appDelegate.viewController dismissMenu:self];
	
	
}

- (void)pushSetMenu {
	//TODO: replace with NULL as done in the page controll example
	
	if (self.playerControllers == nil) { // this check use in case of loading after warning message...
		NSMutableArray *controllers = [[NSMutableArray alloc] init];
		for (unsigned i = 0; i < 3; i++) {
			PlayerMenu *controller = [[PlayerMenu alloc] initWithNibName:@"PlayerMenu" bundle:nil];
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
	[milgromViewController.viewController pushViewController:controller animated:YES];
	//[self presentModalViewController:controller animated:YES];
	//controller.view.hidden = NO;
	OFSAptr->bMenu=true; // TODO: change upon return
}


- (void) pop {
	[milgromViewController.viewController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark ShareViewController methods

- (void)share {
	
	if (self.shareViewController == nil) {
		self.shareViewController = [[ShareViewController alloc] initWithNibName:@"ShareViewController" bundle:nil];
		shareViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	}
	
	[self presentModalViewController:self.shareViewController animated:YES]; 
	// BUG FIX: this is very important: don't present from milgromViewController as it will result in crash when returning to BandView after share
	// not so
	//[shareViewController setProgress:[NSNumber numberWithFloat:0.5f]];
	[shareViewController render];
}

- (void)play {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	
	AVPlayerDemoPlaybackViewController * mPlaybackViewController = [[AVPlayerDemoPlaybackViewController allocWithZone:[self zone]] init];
	
	[mPlaybackViewController setURL:[NSURL fileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"video.mov"]]]; 
	[[mPlaybackViewController player] seekToTime:CMTimeMakeWithSeconds(0.0, NSEC_PER_SEC) toleranceBefore:CMTimeMake(1, 2 * NSEC_PER_SEC) toleranceAfter:CMTimeMake(1, 2 * NSEC_PER_SEC)];
	
	[self presentModalViewController:mPlaybackViewController animated:NO];
	
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

- (void) loader:(DemoLoader *)theLoader withProgress:(NSNumber *)theProgress {
	
	Song *song = theLoader.song;
	BandMenu *bandMenu = (BandMenu *)[milgromViewController.viewController.viewControllers objectAtIndex:0];
	
	[bandMenu.songsTable updateSong:song withProgress:theProgress];
	
}




@end
