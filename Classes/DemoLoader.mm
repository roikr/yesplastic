//
//  DemoLoader.m
//  Milgrom
//
//  Created by Roee Kremer on 8/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DemoLoader.h"
#import "Song.h"
#import "SoundSet.h"
#import "VideoSet.h"
#import "MilgromMacros.h"
#import "MilgromInterfaceAppDelegate.h"


@interface NSObject (PrivateMethods)
- (void) update;
@end

@implementation DemoLoader

@synthesize song;
@synthesize delegate;

- (id) initWithSong:(Song *)theSong delegate:(id<DemoLoaderDelegate>)theDelegate {
	// currentSet = 0;
	
	if (self = [super init]) {
		self.delegate = theDelegate;
		self.song = theSong;
		[self update];
	}
	
	return self;
}

- (void)update {
		
	if (![song.bReady boolValue]) { 
		
		MilgromLog(@"Song: %@",[song songName]);
		NSArray *soundSets = [song.soundSets allObjects];
		while (currentSet/2 < [soundSets count] )  {
			MilgromLog(@"currentSet: %i",currentSet);
			SoundSet *soundSet = [soundSets objectAtIndex:currentSet/2];
			if (![soundSet.bReady boolValue]) {
				MilgromLog(@"%i: SoundSet: %@ is not ready",currentSet,[soundSet setName]);
								[[AssetLoader alloc] initWithSet:soundSet delegate:self];
				
				return; 
			} else {
				currentSet++;
				VideoSet *videoSet = [soundSet videoSet];
				if (![videoSet.bReady boolValue]) {
					
					MilgromLog(@"%i: VideoSet: %@ is not ready",currentSet,[videoSet setName]);
					
					
					[[AssetLoader alloc] initWithSet:videoSet delegate:self];
					
					return;
				} else {
					currentSet++;
				}
				
				
			}
			
		}
		
		[song setBReady:[NSNumber numberWithBool:YES]];
		
		[(MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
		[self.delegate loaderDidFinish:self];
		
		
	} 
	
}

#pragma mark -
#pragma mark AssetLoader methods

- (void) loaderDidFail:(AssetLoader *)theLoader {
	Set *set = theLoader.set;
	MilgromLog(@"loading Set: %@ faild, trying agagin",[set setName]);
	[self update];
}

- (void) loaderDidFinish:(AssetLoader *)theLoader {
	
	Set *set = theLoader.set;
	MilgromLog(@"Set: %@ is ready",[set setName]);
	[set setBReady:[NSNumber numberWithBool:YES]];
	[(MilgromInterfaceAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
	[self update];
	
	
}

- (void) loaderProgress:(NSNumber *)theProgress {
	
	//frame.size.width = ;
	float totalProgress = ((float)currentSet + [theProgress floatValue] )/6.0;
	
	MilgromLog(@"loaderProgress: %3f, total: %3f",[theProgress floatValue] *100,totalProgress*100);
	[self.delegate loader:self withProgress:totalProgress];
}



@end
