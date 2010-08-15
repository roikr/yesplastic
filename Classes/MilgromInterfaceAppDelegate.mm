//
//  MilgromInterfaceAppDelegate.m
//  MilgromInterface
//
//  Created by Roee Kremer on 7/22/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "MilgromInterfaceAppDelegate.h"
#import "BandMenu.h"
#import "MilgromViewController.h"
#import "URLCacheAlert.h"
#import "MilgromMacros.h"
#import "ZipArchive.h"
#include "testApp.h"
#include "Constants.h"
#include "Song.h"
#include "VideoSet.h"
#include "SoundSet.h"
#include "HelpViewController.h"


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
- (void)addDemo:(NSArray *)theArray download:(BOOL)bDownload;
 
@end

@implementation MilgromInterfaceAppDelegate

@synthesize window;
@synthesize milgromViewController;
@synthesize OFSAptr;
@synthesize help;



#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    
	// Override point for customization after application launch.
	
	if ([MilgromInterfaceAppDelegate unzipPrecache])
		[self addDemos];
	
    // Add the view controller's view to the window and display.
	//[window addSubview:viewController.view]; // need to add before making visible to allow rotation
	//[window addSubview:milgromViewController.view];
	
    [window makeKeyAndVisible];
	
	//[window bringSubviewToFront:viewController.view];
	
	
	//glView.controller = self;
	self.OFSAptr = new testApp;
	OFSAptr->setup();
	OFSAptr->setState(BAND_STATE);
	OFSAptr->lastFrame = 0;
	
	
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

- (void)loadSong:(Song*)song {
	//
	
	string nextSong = [song.songName UTF8String];
	if (  !OFSAptr->isInTransition() && OFSAptr->isSongAvailiable(nextSong)) {
		
		OFSAptr->changeSoundSet(nextSong, true);
	}
	
	[(BandMenu *)[milgromViewController.viewController.viewControllers objectAtIndex:0] exit:nil];
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




- (void)dealloc {
	[managedObjectContext_ release];
	[managedObjectModel_ release];
	[persistentStoreCoordinator_ release];
   
	[milgromViewController release];
    [window release];
    [super dealloc];
}


+ (BOOL)unzipPrecache {
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	if (!documentsDirectory) {
		MilgromLog(@"Documents directory not found!");
		return YES;
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

- (void)addDemos {
	[self addDemo:[NSArray arrayWithObjects:@"HEAT",@"GTR_HEAT",@"GTR_ELECTRO",@"VOC_HEAT",@"VOC_BB",@"DRM_HEAT",@"DRM_ELECTRO",nil] download:NO];
	[self addDemo:[NSArray arrayWithObjects:@"PACIFIST",@"GTR_PACIFIST",@"GTR_FUNK",@"VOC_PACIFIST",@"VOC_POP",@"DRM_PACIFIST",@"DRM_NEOJAZZ",nil] download:YES];
	[self addDemo:[NSArray arrayWithObjects:@"BOY",@"GTR_BOY",@"GTR_ROCK",@"VOC_BOY",@"VOC_HH",@"DRM_BOY",@"DRM_OLDSCHOOL",nil] download:NO];
	[self addDemo:[NSArray arrayWithObjects:@"SALAD",@"GTR_SALAD",@"GTR_SHORTS",@"VOC_SALAD",@"VOC_CORE",@"DRM_SALAD",@"DRM_ROCK",nil] download:NO];
	
	NSError *error;
	if (![managedObjectContext_ save:&error]) {
		MilgromLog(@"%@",[error description]);
	}
	
	//[songsArray addObject:song];
	
	//NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	//[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	//[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
	
	//NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([songsArray count]-1) inSection:0];
	//[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	//[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(void)addDemo:(NSArray *)theArray download:(BOOL)bDownload {
	
	Song *song= (Song *)[NSEntityDescription insertNewObjectForEntityForName:@"Song" inManagedObjectContext:self.managedObjectContext];
	[song setSongName:[theArray objectAtIndex:0]];
	[song setBLocked:[NSNumber numberWithBool:NO]];
	[song setBDemo:[NSNumber numberWithBool:YES]];
	if (!bDownload) {
		[song setBReady:[NSNumber numberWithBool:YES]];  
	}
	
	SoundSet *soundSet;
	VideoSet *videoSet;
	soundSet= (SoundSet *)[NSEntityDescription insertNewObjectForEntityForName:@"SoundSet" inManagedObjectContext:self.managedObjectContext];
	[soundSet setSetName:[theArray objectAtIndex:1]];
	[soundSet setFilename:[NSString stringWithFormat:@"%@.zip",[theArray objectAtIndex:1]]];
	videoSet= (VideoSet *)[NSEntityDescription insertNewObjectForEntityForName:@"VideoSet" inManagedObjectContext:self.managedObjectContext];
	[videoSet setSetName:[theArray objectAtIndex:2]];
	[videoSet setFilename:[NSString stringWithFormat:@"%@.zip",[theArray objectAtIndex:2]]];
	[soundSet setVideoSet:videoSet];
	[song addSoundSetsObject:soundSet];
	
	soundSet= (SoundSet *)[NSEntityDescription insertNewObjectForEntityForName:@"SoundSet" inManagedObjectContext:self.managedObjectContext];
	[soundSet setSetName:[theArray objectAtIndex:3]];
	[soundSet setFilename:[NSString stringWithFormat:@"%@.zip",[theArray objectAtIndex:3]]];
	videoSet= (VideoSet *)[NSEntityDescription insertNewObjectForEntityForName:@"VideoSet" inManagedObjectContext:self.managedObjectContext];
	[videoSet setSetName:[theArray objectAtIndex:4]];
	[videoSet setFilename:[NSString stringWithFormat:@"%@.zip",[theArray objectAtIndex:4]]];
	[soundSet setVideoSet:videoSet];
	[song addSoundSetsObject:soundSet];
	
	
	soundSet= (SoundSet *)[NSEntityDescription insertNewObjectForEntityForName:@"SoundSet" inManagedObjectContext:self.managedObjectContext];
	[soundSet setSetName:[theArray objectAtIndex:5]];
	[soundSet setFilename:[NSString stringWithFormat:@"%@.zip",[theArray objectAtIndex:5]]];
	videoSet= (VideoSet *)[NSEntityDescription insertNewObjectForEntityForName:@"VideoSet" inManagedObjectContext:self.managedObjectContext];
	[videoSet setSetName:[theArray objectAtIndex:6]];
	[videoSet setFilename:[NSString stringWithFormat:@"%@.zip",[theArray objectAtIndex:6]]];
	[soundSet setVideoSet:videoSet];
	[song addSoundSetsObject:soundSet];
	
	
	
	
	
}


- (void)bringHelp {
	
	if (self.help == nil) {
		self.help = [[HelpViewController alloc] initWithNibName:@"HelpViewController" bundle:nil];
		help.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	}
	
	
	[self.milgromViewController presentModalViewController:self.help animated:YES];
}


@end
