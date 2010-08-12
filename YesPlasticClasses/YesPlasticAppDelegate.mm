//
//  YesPlasticAppDelegate.m
//  YesPlastic
//
//  Created by Roee Kremer on 1/19/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "YesPlasticAppDelegate.h"
#import "MainViewController.h"
#import "EAGLView.h"


#import <StoreKit/StoreKit.h>
#import "ZoozzMacros.h"
extern "C"
{
#import "Utilities.h"
}
#import "LocalStorage.h"
#import "ZoozzResourcesLoader.h"
#import "SoundSet.h"
#import "MenuViewController.h"

#include "testApp.h"

@interface YesPlasticAppDelegate (PrivateMethods)
- (void)parseLibrary;
- (void)threadMain;
- (void)login;
- (void)loadLibraryWithTransaction:(SKPaymentTransaction *)transaction;
@end

@implementation YesPlasticAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize secondaryThread;
@synthesize resourcesLoader;

- (void) applicationDidFinishLaunching:(UIApplication *)application
{
	
	[LocalStorage unzipPrecache];
			
	self.viewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
	[window addSubview:viewController.view];
	[viewController.glView layoutSubviews];
	[viewController.glView startAnimation];
	
	
	if ([CacheResource doesAssetCachedWithResourceType:CacheResourceLibrary withIdentifier:nil]) {
		bFirstParsing = YES;
		[self parseLibrary];
	}
	else {
		ZoozzLog(@"no cached library");
	}
	
	
	//[viewController setupMenus]; // temporal
		
}



-(void) parseLibrary {
	[[XMLParser alloc] parse:[NSData dataWithContentsOfFile:[CacheResource cacheResourcePathWithResourceType:CacheResourceLibrary WithIdentifier:nil]] withDelegate:self];
}


#pragma mark XMLParser delegate methods



- (void) XMLParserDidFail:(XMLParser *)theParser {
	ZoozzLog(@"parser failed");
	[theParser release];
}

- (void) XMLParserDidFinish:(XMLParser *)theParser {
	
	[[LocalStorage localStorage] arrangeAssets:theParser.assets];
	
	[theParser release];
	
	if (bFirstParsing) {
		bFirstParsing = NO;
		[viewController setupMenus];
		
		//self.secondaryThread = [[NSThread alloc] initWithTarget:self selector:@selector(threadMain) object:nil];
		//[secondaryThread start];
	} else {
		
		[viewController updateTables];
		[resourcesLoader pushResources:[LocalStorage localStorage].parsedAssets];
	}
	
	[viewController.menuController updateProducts];
	
}


# pragma mark secondary Thread
- (void)doFireTimer:(NSTimer *)timer {
    
}


- (void)threadMain
{
	// The application uses garbage collection, so no autorelease pool is needed.
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	
	NSRunLoop* myRunLoop = [NSRunLoop currentRunLoop];
	/*
	 // Create a run loop observer and attach it to the run loop.
	 CFRunLoopObserverContext  context = {0, self, NULL, NULL, NULL};
	 CFRunLoopObserverRef    observer = CFRunLoopObserverCreate(kCFAllocatorDefault,
	 kCFRunLoopAllActivities, YES, 0, &myRunLoopObserver, &context);
	 
	 if (observer)
	 {
	 CFRunLoopRef    cfLoop = [myRunLoop getCFRunLoop];
	 CFRunLoopAddObserver(cfLoop, observer, kCFRunLoopDefaultMode);
	 }
	 */
    // Create and schedule the timer.
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(doFireTimer:) userInfo:nil repeats:YES];
	
	
	bLoggingIn = NO;
	resourcesLoader = [[ZoozzResourcesLoader alloc] init];
	resourcesLoader.delegate = self;
	[resourcesLoader pushResources:[LocalStorage localStorage].parsedAssets];
	
	
    BOOL done = NO;
    do
    {
		// Run the run loop 10 times to let the timer fire.
		if (isConnected()) {
			if (![LocalStorage localStorage].bLoggedIn ) {
				if (!bLoggingIn) {
					bLoggingIn = YES;
					[self performSelectorOnMainThread:@selector(login) withObject:nil waitUntilDone:NO];
				}
				
			} else {
				[resourcesLoader process];
			}

		}
		
        [myRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
		
    }
    while (!done);
	
	[pool release];
	ZoozzLog(@"YesPlasticAppDelegate - threadMain had finished");
	
}



	

-(void) login {
	//[self sendEvents]; // we don't send last session events
	[[AuthenticateConnection alloc] initWithDelegate:self];
}



#pragma mark ZoozzResourcesLoader delegate method

- (void)resourceLoaded:(Asset*)asset {
	
	if ([asset isKindOfClass:[SoundSet self]]) {
		[viewController updateTables];
	}
}


#pragma mark AuthenticateConnection delegate methods


- (void) AuthenticateConnectionDidFailLoading:(AuthenticateConnection *)authenticateConnection {
	switch (authenticateConnection.connection.requestType) {
		case ZoozzLogin:
			
			break;
		case ZoozzAuthenticateTransaction:
			//[store purchaseFailed:@"zoozz server connection failed"];
			break;
		default:
			break;
	}
	
	[authenticateConnection release];
}


- (void) AuthenticateConnectionDidFinishLoading:(AuthenticateConnection *)authenticateConnection {
	
	NSInteger statusCode = [authenticateConnection.connection.theResponse statusCode];
	
	switch (authenticateConnection.connection.requestType) {
		case ZoozzLogin:
			[self loadLibraryWithTransaction:nil];
			break;
		case ZoozzAuthenticateTransaction:
		{
			switch (statusCode) {
				case HTTPStatusCodeOK: {
					if (authenticateConnection.transaction) {
						[self loadLibraryWithTransaction:authenticateConnection.transaction];
					}
					
				} break;
				case HTTPStatusCodeNoContent: {
					ZoozzLog(@"AuthenticateConnectionDidFinishLoading - ZoozzAuthenticateTransaction - purchase didn't authorized");
					//[store purchaseFailed:@"zoozz server authentication failed"];
				} break;
			}
		} break;
		case ZoozzAuthenticateTrial: {
			switch (statusCode) {
				case HTTPStatusCodeOK: {
					[self loadLibraryWithTransaction:nil];
					
				} break;
				case HTTPStatusCodeNoContent: {
					ZoozzLog(@"AuthenticateConnectionDidFinishLoading - ZoozzAuthenticateTrial - trial didn't authorized");
				} break;
			}
		} break;
	}
	
	[authenticateConnection release];
}




- (void) applicationWillResignActive:(UIApplication *)application
{
	//[viewController.glView stopAnimation];
	viewController.OFSAptr->willResignActive();
}

- (void) applicationDidBecomeActive:(UIApplication *)application
{
	viewController.OFSAptr->didBecomeAcive();
	//[viewController.glView startAnimation];
}
 

- (void)applicationWillTerminate:(UIApplication *)application
{
	[[LocalStorage localStorage] archive];
	[viewController.glView stopAnimation];
	
}


- (void) dealloc
{
	[window release];
	[viewController release];
	
	[super dealloc];
}


#pragma mark Zoozz application states



- (void)loadLibraryWithTransaction:(SKPaymentTransaction *)transaction {
	/*
	 if (!bDisplayed && [[NSUserDefaults standardUserDefaults] boolForKey:@"precache_library_identifier"]) {
	 NSError * error = nil;
	 NSString * appFile = [CacheResource cacheResourcePathWithResourceType:CacheResourceLibrary WithIdentifier:nil];
	 
	 if ([[NSFileManager defaultManager] fileExistsAtPath:appFile]) {
	 if (![[NSFileManager defaultManager] removeItemAtPath:appFile error:&error]) 
	 ZoozzLog(@"can't delete %@: %@",appFile,[error localizedDescription]);
	 else
	 ZoozzLog(@"%@ deleted",appFile);
	 }
	 
	 [CacheResource copyWithResourceType:CacheResourceLibrary withIdentifier:nil];	
	 if ([CacheResource doesAssetCachedWithResourceType:CacheResourceLibrary withIdentifier:nil]) {
	 [self parseLibrary];
	 return;
	 } else {
	 ZoozzLog(@"could not precache library");
	 }		
	 }
	 */

	/*
#ifdef _SETTINGS
	if (!bDisplayed && [[NSUserDefaults standardUserDefaults] boolForKey:@"clear_library_identifier"]) {
		localStorage.libraryDate = nil;
	}
#endif
	*/
	
	
	[[CacheResource alloc] initWithResouceType:CacheResourceLibrary withObject:transaction delegate:self];
}



#pragma mark CacheResource delegate methods

- (void)CacheResourceDidFailLoading:(CacheResource *)cacheResource {
	switch (cacheResource.resourceType) {
		case CacheResourceLibrary: {
			
		} break;
			
		//case CacheResourceWink: {
//			[cachingWinks removeObject:cacheResource];
//		} break;
		
		default:
			break;
	}
	
	
	ZoozzLog(@"IminentAppDelegate - CacheResourceDidFailLoading");
	
	[cacheResource release];
}

- (void)CacheResourceDidFinishLoading:(CacheResource *)cacheResource {
	
	switch (cacheResource.resourceType) {
		case CacheResourceLibrary: {
			/*
			if (cacheResource.transaction) {
				[[SKPaymentQueue defaultQueue] finishTransaction: cacheResource.transaction];
				if ( cacheResource.transaction.transactionState == SKPaymentTransactionStatePurchased && store) {
					if ([store.productIdentifier isEqualToString:cacheResource.transaction.payment.productIdentifier]) {
						
						SKProduct *product = store.product;
						NSString *cur = [product.priceLocale objectForKey:NSLocaleCurrencyCode];
						[self addEvent:[ZoozzEvent buyWithProduct:store.productIdentifier withTransaction:cacheResource.transaction.transactionIdentifier withCurrency:cur withPrice:product.price]];
						[store purchaseSucceeded];
						
					}
				}
				
			}
			*/
			[self parseLibrary];
			/*
			if ([cacheResource.connection.theResponse statusCode] == HTTPStatusCodeOK)  {
				[self parseLibrary];
			} 
			 */
			
		} break;
			
	
					
		default:
			break;
	}
	
	
	
	[cacheResource release];
}









@end
