//
//  AssetLoader.m
//  MilgromInterface
//
//  Created by Roee Kremer on 8/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AssetLoader.h"
#import "ZipArchive.h"
#import "MilgromInterfaceAppDelegate.h"
#import "MilgromMacros.h"
#import "Set.h"
#import "SoundSet.h"
#import "VideoSet.h"

@interface NSObject (PrivateMethods)

/*
- (void) initUI;
- (void) startAnimation;
- (void) stopAnimation;
- (void) buttonsEnabled:(BOOL)flag;
- (void) getFileModificationDate;
- (void) displayImageWithURL:(NSURL *)theURL;
- (void) displayCachedImage;
- (void) initCache;
- (void) clearCache;
*/
- (void)unzipAsset;
- (void) unzipAssetDidFinish;
@end

@implementation AssetLoader

@synthesize delegate;
@synthesize filePath;
@synthesize set;

- (id) initWithSet:(Set *)theSet delegate:(id<AssetLoaderDelegate>)theDelegate
{
	if (self = [super init]) {
		
		
		
		self.delegate = theDelegate;
		self.set = theSet;
		
		/* create path to cache directory inside the application's Documents directory */
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:kCacheFolder];
		
		//[[AssetLoader alloc] initWithURL:] delegate:self];
		
		[filePath release]; /* release previous instance */
		self.filePath = [[dataPath stringByAppendingPathComponent:set.filename] retain];
		
		/* apply daily time interval policy */
		
		/* In this program, "update" means to check the last modified date
		 of the image to see if we need to load a new version. */
		
		
		//[self initUI];
		//[self buttonsEnabled:NO];
		//[self startAnimation];
		
		MilgromLog(@"AssetLoader::initWithSet, dataPath:%@",dataPath);
		
		if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
			
			NSURL *theURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/milgrom/%@",kMilgromFileServerURL,set.filename]];
			MilgromLog(@"Downloading Asset from: %@",[theURL absoluteString]);
			[[URLCacheConnection alloc] initWithURL:theURL delegate:self];
		} else {
			MilgromLog(@"Asset allready Downloaded");
			[self performSelectorInBackground:@selector(unzipAsset) withObject:nil];
			
		}

		
		
		
	}
	
	return self;
}


- (void)dealloc
{
	MilgromLog(@"AssetLoader::dealloc");
	[set release];
	[filePath release];
	[super dealloc];
}

#pragma mark -
#pragma mark URLCacheConnectionDelegate methods

- (void) connectionDidFail:(URLCacheConnection *)theConnection
{
	MilgromLog(@"AssetLoader::connectionDidFail");
	//[self stopAnimation];
	//[self buttonsEnabled:YES];
	[self.delegate loaderDidFail:self];
}


- (void) connectionDidFinish:(URLCacheConnection *)theConnection
{
	
	MilgromLog(@"AssetLoader::connectionDidFinish");
	[[NSFileManager defaultManager] createFileAtPath:filePath contents:theConnection.receivedData  attributes:nil];
	MilgromLog(@"zip file written");
	//[self unzipAsset];
	[self performSelectorInBackground:@selector(unzipAsset) withObject:nil];
	
	
	
}


- (void) connectionProgress:(NSNumber *)theProgress {
	//MilgromLog(@"AssetLoader::connectionProgress");
	[self.delegate loaderProgress:theProgress];
	//MilgromLog(@"AssetLoader::connectionProgress: %3.2f",[theProgress floatValue] *100);
}

- (BOOL)doesAssetUnzipped {
	
	return YES;
}

- (void)unzipAsset {
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	MilgromLog(@"unzipping started");
	ZipArchive *zip = [[ZipArchive alloc] init];
	[zip UnzipOpenFile:filePath];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	
	static NSString *SoundSetPath = @"data/SOUNDS";
	static NSString *VideoSetPath = @"data/VIDEOS";
	
		
	[zip UnzipFileTo:[[paths objectAtIndex:0] stringByAppendingPathComponent:[set isKindOfClass:[SoundSet self]] ? SoundSetPath : VideoSetPath] overWrite:YES];
	[zip UnzipCloseFile];
	//[unzippedAssets addObject:asset.identifier];
	//[self archive];
	MilgromLog(@"unzipping finished");
	
	[self performSelectorOnMainThread:@selector(unzipAssetDidFinish) withObject:nil waitUntilDone:NO];
	[pool release];
	
}

- (void)unzipAssetDidFinish {
	[self.delegate loaderDidFinish:self];
}



@end
