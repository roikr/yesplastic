//
//  MilgromInterfaceAppDelegate.h
//  MilgromInterface
//
//  Created by Roee Kremer on 7/22/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


extern NSString * const kCacheFolder;
extern NSString * const kMilgromURL;

@class MilgromViewController;
@class Song;
class testApp;



@interface MilgromInterfaceAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    
	
	NSManagedObjectContext *managedObjectContext_;
	NSManagedObjectModel *managedObjectModel_;
	NSPersistentStoreCoordinator *persistentStoreCoordinator_;
	
	MilgromViewController *milgromViewController;
	
	testApp *OFSAptr;
	
	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MilgromViewController *milgromViewController;


@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain,readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property testApp *OFSAptr;


- (NSString *)applicationDocumentsDirectory;
- (void)saveContext;
- (void)loadSong:(Song*)song;
- (void)saveSong:(NSString *)songName;



@end

