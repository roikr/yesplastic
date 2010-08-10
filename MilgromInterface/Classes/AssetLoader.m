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
@end

@implementation AssetLoader

@synthesize delegate;
@synthesize filePath;

- (id) initWithURL:(NSURL *)theURL delegate:(id<AssetLoaderDelegate>)theDelegate
{
	if (self = [super init]) {
		
		
		
		self.delegate = theDelegate;
		
		/* create path to cache directory inside the application's Documents directory */
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:kCacheFolder];
		
		
		[filePath release]; /* release previous instance */
		NSString *fileName = [[theURL path] lastPathComponent];
		self.filePath = [[dataPath stringByAppendingPathComponent:fileName] retain];
		
		/* apply daily time interval policy */
		
		/* In this program, "update" means to check the last modified date
		 of the image to see if we need to load a new version. */
		
		
		//[self initUI];
		//[self buttonsEnabled:NO];
		//[self startAnimation];
		
		MilgromLog(@"AssetLoader::initWithURL:%@, dataPath:%@",[theURL absoluteString],dataPath);
		[[URLCacheConnection alloc] initWithURL:theURL delegate:self];
		
		
		
	}
	
	return self;
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
	[self unzipAsset];
	
	
}


- (void) connectionProgress:(NSNumber *)theProgress {
	[self.delegate loaderProgress:theProgress];
	//MilgromLog(@"AssetLoader::connectionProgress: %3.2f",[theProgress floatValue] *100);
}

- (BOOL)doesAssetUnzipped {
	
	return YES;
}

- (void)unzipAsset {
	MilgromLog(@"unzipping started");
	ZipArchive *zip = [[ZipArchive alloc] init];
	[zip UnzipOpenFile:filePath];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	[zip UnzipFileTo:[paths objectAtIndex:0] overWrite:YES];
	[zip UnzipCloseFile];
	//[unzippedAssets addObject:asset.identifier];
	//[self archive];
	MilgromLog(@"unzipping finished");
	[self.delegate loaderDidFinish:self];

	
}



@end
