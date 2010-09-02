//
//  OpenGLTOMovie.m
//  ConvertToVideo
//
//  Created by Roee Kremer on 8/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreVideo/CoreVideo.h>
#import <AVFoundation/AVFoundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "OpenGLTOMovie.h"


@implementation OpenGLTOMovie


//+ (void)converter {
//	return [[[OpenGLTOMovie alloc] init] autorelease];
//}

+ (void)writeToVideoURL:(NSURL*)videoURL WithSize:(CGSize)size withDrawFrame:(void (^)(int))drawFrame withDidFinish:(int (^)(int))didFinish withCompletionHandler:(void (^)(void))completionHandler{
	
	
	NSDictionary *pixelBufferAttributes;
	AVAssetWriterInputPixelBufferAdaptor *adaptor;
	AVAssetWriterInput *input;
	AVAssetWriter *writer;



	NSDictionary* videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey, 
								   [NSNumber numberWithUnsignedInt:size.width],AVVideoWidthKey,
								   [NSNumber numberWithUnsignedInt:size.height],AVVideoHeightKey,nil];
	
	input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
	input.expectsMediaDataInRealTime = NO;
	
	
	
	pixelBufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], kCVPixelBufferOpenGLCompatibilityKey, 
								  [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA],(NSString*)kCVPixelBufferPixelFormatTypeKey,
								  /*[NSNumber numberWithUnsignedInt:size.width],(NSString*)kCVPixelBufferWidthKey,
								  [NSNumber numberWithUnsignedInt:size.height],(NSString*)kCVPixelBufferHeightKey,*/nil];
	adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:input sourcePixelBufferAttributes:pixelBufferAttributes];
	
		
	NSError *error;
	
	NSString *videoPath = [videoURL path];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:videoPath]) {
		if (![[NSFileManager defaultManager] removeItemAtPath:videoPath error:&error]) {
			NSLog(@"removeItemAtPath error: %@",[error description]);
		}
	}
	
	
	
	writer = [AVAssetWriter assetWriterWithURL:videoURL fileType:(NSString*)kUTTypeQuickTimeMovie error:&error];
	if (error) {
		NSLog(@"AVAssetWriter: %@",[error description]);
	}
	BOOL test = [writer canAddInput:input];
	NSLog(@"can add input: %i",test);
	[writer addInput:input];
	
	[writer startWriting];
	[writer startSessionAtSourceTime:kCMTimeZero] ;//CMTimeAdd(kCMTimeZero, CMTimeMultiply(CMTimeMake(1, 25), frameNum))];
	//NSLog(@"Writing Started");
	
		
	//NSLog(@"video session started");
	int frameNum = 0;
	
	do if([input isReadyForMoreMediaData])
	{
							// create pixel buffer
		CVPixelBufferRef pixelBuffer;
		CVReturn theError = CVPixelBufferCreate(kCFAllocatorDefault, size.width, size.height, kCVPixelFormatType_32BGRA, (CFDictionaryRef)pixelBufferAttributes, &pixelBuffer);
		if (theError!=0) {
			NSLog(@"CVPixelBufferCreate: %i",theError );
		}
		
		
		theError = CVPixelBufferLockBaseAddress(pixelBuffer,0); 
		if (theError!=0) {
			NSLog(@"CVPixelBufferLockBaseAddress: %i", theError);
		}
		
	
		uint8_t *baseAddress  = (uint8_t *)CVPixelBufferGetBaseAddress(pixelBuffer);
		
		dispatch_sync(dispatch_get_main_queue(), ^{
			drawFrame(frameNum);
		
			GLenum err = glGetError();
			if (err != GL_NO_ERROR)
			{
				NSLog(@"frame: %i, glError: 0x%04X",frameNum, err);
			}
			
			
			glReadPixels(0, 0, size.width, size.height, GL_BGRA, GL_UNSIGNED_BYTE, baseAddress);
			
			err = glGetError();
			if (err != GL_NO_ERROR)
			{
				NSLog(@"frame: %i, glError: 0x%04X",frameNum, err);
			}
		});
	
						
				   
								  
		theError = CVPixelBufferUnlockBaseAddress(pixelBuffer,0); 
		if (theError!=0) {
			NSLog(@"CVPixelBufferUnlockBaseAddress: %i", theError);
		}
		
		
		[adaptor appendPixelBuffer:pixelBuffer withPresentationTime:CMTimeAdd(kCMTimeZero, CMTimeMultiply(CMTimeMake(1, 25), frameNum))];
		CVPixelBufferRelease(pixelBuffer); 
		frameNum++;
		
				
											   
	} while (!didFinish(frameNum));
	[input markAsFinished];
	[writer endSessionAtSourceTime:CMTimeAdd(kCMTimeZero, CMTimeMultiply(CMTimeMake(1, 25), frameNum-1))];
	[writer finishWriting];
	NSLog(@"Writing finished with status: %i",[writer status]);
	
	dispatch_async(dispatch_get_main_queue(), ^{
		completionHandler();
	});
	

}
	
	 

+ (AVAssetExportSession *)exportToURL:(NSURL*)url withVideoURL:(NSURL*)videoURL withAudioURL:(NSURL*)audioURL 
					withProgressHandler:(void (^)(float))progressHandler withCompletionHandler:(void (^)(void))completionHandler {
	

	AVMutableComposition *composition = [AVMutableComposition composition];
	
	AVMutableCompositionTrack *compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
	AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
	
	NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],AVURLAssetPreferPreciseDurationAndTimingKey,nil];
	AVURLAsset *video = [AVURLAsset URLAssetWithURL:videoURL options:options];
	AVURLAsset *audio = [AVURLAsset URLAssetWithURL:audioURL options:options];
	// TODO: the options is key issue because it get you duration synchrouniously so the session can finish asynch
		
	CMTimeRange audioTimeRangeInAsset = CMTimeRangeMake(kCMTimeZero, [audio duration]);
	CMTimeRange videoTimeRangeInAsset = CMTimeRangeMake(kCMTimeZero, [video duration]);
	
	//CMTimeRange timeRange = CMTimeRangeGetIntersection(audioTimeRangeInAsset, videoTimeRangeInAsset);
	
	NSError *error;
	NSArray *videoTracks = [video tracksWithMediaType:AVMediaTypeVideo];
	
	AVAssetTrack *clipVideoTrack = [ videoTracks objectAtIndex:0];
	[compositionVideoTrack insertTimeRange:videoTimeRangeInAsset ofTrack:clipVideoTrack atTime:kCMTimeZero error:&error];
	
	
	AVAssetTrack *clipAudioTrack = [[audio tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
	[compositionAudioTrack insertTimeRange:audioTimeRangeInAsset ofTrack:clipAudioTrack atTime:kCMTimeZero error:&error];
	
			
	AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality]; // AVAssetExportPresetPassthrough
		
	session.outputURL = url;
	session.outputFileType = AVFileTypeQuickTimeMovie;
	session.audioMix = nil;
	session.metadata = nil;
	session.videoComposition = nil;
	session.timeRange = audioTimeRangeInAsset;
	
	
	
	//session.videoComposition = videoComposition;
	
	[session exportAsynchronouslyWithCompletionHandler:^
	{
		
		//NSLog(@"export did finished with status: %i",[session status]);
		dispatch_async(dispatch_get_main_queue(), ^{
			completionHandler();
		});
		 
	 }];
	
	/*
	dispatch_queue_t myCustomQueue;
	myCustomQueue = dispatch_queue_create("exportQueue", NULL);
	
	dispatch_async(myCustomQueue, ^{
		while ([session status] != AVAssetExportSessionStatusCompleted) {
			progressHandler([session progress]);
			//[NSThread sleepForTimeInterval:0.04f];
		}
	});
	
	
	dispatch_release(myCustomQueue);
	 */
	
	return session ;
	
}



		 //	AVAssetWriterInput *audioInput;
		 //	AVAssetReader *reader;
		 //	AVURLAsset *asset;
		 //	AVAssetReaderTrackOutput *output;
		 //	
		 //	asset = [AVURLAsset URLAssetWithURL:url options:nil];
		 //	
		 //	NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeAudio];
		 //	
		 //	
		 //	output = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:[tracks objectAtIndex:0] outputSettings:nil];
		 //	
		 //	NSLog(@"AVAssetReaderTrackOutput mediaType: %@",[output mediaType]);
		 //	
		 //	NSError *error;
		 //	
		 //	reader = [AVAssetReader assetReaderWithAsset:asset error:&error];
		 //	
		 //	if (error) {
		 //		NSLog(@"AVAssetReader: %@",[error description]);
		 //	}
		 //	
		 //	BOOL test = [reader canAddOutput:output];
		 //	NSLog(@"can add output: %i",test);
		 //	[reader addOutput:output];
		 //	
		 //	AudioChannelLayout layout;
		 //	layout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo   ;
		 //	
		 //	
		 //	id keys[5], values[5];
		 //    keys[0] = AVFormatIDKey; values[0] = [[NSNumber alloc] initWithInt: kAudioFormatMPEG4AAC ];
		 //    keys[1] = AVSampleRateKey; values[1] = [[NSNumber alloc] initWithFloat: 44100. ];
		 //    keys[2] = AVNumberOfChannelsKey; values[2] = [[NSNumber alloc] initWithInt: 2 ];
		 //    keys[3] = AVEncoderBitRateKey; values[3] = [[NSNumber alloc] initWithInt: 128000 ];
		 //    keys[4] = AVChannelLayoutKey; values[4] = [NSData dataWithBytes:&layout length:sizeof(AudioChannelLayout)];
		 //	
		 //    // Create the dictionary
		 //    NSMutableDictionary* audioSettings = [[NSMutableDictionary alloc] initWithObjects: values 
		 //                                                                         forKeys: keys 
		 //                                                                           count: 5 ];
		 //	 
		 //	
		 //	audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioSettings];
		 //	audioInput.expectsMediaDataInRealTime = NO;
		 //	
		 //		
		 //	dispatch_queue_t myInputSerialQueue = dispatch_queue_create("renderqueue",NULL);
		 //	
		 //	
		 //	void (^audioBlock)(void)= ^(void) {
		 //		NSLog(@"audio block started");
		 //		while ([audioInput isReadyForMoreMediaData])
		 //		{
		 //			CMSampleBufferRef nextSampleBuffer = [output copyNextSampleBuffer];
		 //			if (nextSampleBuffer)
		 //			{
		 //				[audioInput appendSampleBuffer:nextSampleBuffer];
		 //				CFRelease(nextSampleBuffer);
		 //			}
		 //			else
		 //			{
		 //				[audioInput markAsFinished];
		 //				NSLog(@"writing audio finished");
		 //				break;
		 //			}
		 //		}
		 //		NSLog(@"audio block finished");
		 //	};
		 //	
		 //	[audioInput requestMediaDataWhenReadyOnQueue:myInputSerialQueue usingBlock:audioBlock];
		 
		 
		 
		 




@end
