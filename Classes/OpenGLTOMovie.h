//
//  OpenGLTOMovie.h
//  ConvertToVideo
//
//  Created by Roee Kremer on 8/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>



@class AVAssetExportSession;

@interface OpenGLTOMovie : NSObject {

	
}

+ (void)writeToVideoURL:(NSURL*)videoURL WithSize:(CGSize)size withDrawFrame:(void (^)(int))drawFrame withDidFinish:(int (^)(int))didFinish withCompletionHandler:(void (^)(void))completionHandler;
+ (AVAssetExportSession *)exportToURL:(NSURL*)url withVideoURL:(NSURL*) videoURL withAudioURL:(NSURL*)audioURL 
					withProgressHandler:(void (^)(float))progressHandler withCompletionHandler:(void (^)(void))completionHandler;



@end
