//
//  MilgromInterfaceAppDelegate.h
//  MilgromInterface
//
//  Created by Roee Kremer on 7/22/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class MainViewController;
@class MilgromViewController;

@interface MilgromInterfaceAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UINavigationController *viewController;
	
	NSManagedObjectContext *managedObjectContext_;
	NSManagedObjectModel *managedObjectModel_;
	NSPersistentStoreCoordinator *persistentStoreCoordinator_;
	
	MilgromViewController *milgromViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *viewController;
@property (nonatomic, retain) IBOutlet MilgromViewController *milgromViewController;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,retain,readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSString *)applicationDocumentsDirectory;
- (void)saveContext;



@end

