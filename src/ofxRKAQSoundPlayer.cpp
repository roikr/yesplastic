/*
 *  ofxRKAQSoundPlayer.cpp
 *  openframeworks
 *
 *  Created by Roee Kremer on 16/8/09.
 *  Copyright 2008. All rights reserved.
 *
 */
//#include "ofMain.h"

#include "ofxRKAQSoundPlayer.h"

#include <stdio.h>
#include <iostream>
using namespace std;

#include "CAHostTimeBase.h"
#define GetCurrentTime()  CAHostTimeBase::GetCurrentTime()
#define GetFrequency()  CAHostTimeBase::GetFrequency()


/*
#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudio.h>
#define GetCurrentTime() AudioGetCurrentHostTime() 
#define GetFrequency() AudioGetHostClockFrequency() 
*/

int ofxRKAQSoundPlayer::startTick;
UInt64 ofxRKAQSoundPlayer::startHostTime;
Float64 ofxRKAQSoundPlayer::clocksPerTick;
bool ofxRKAQSoundPlayer::bStarted;

static void HandleOutputBuffer (void *aqData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer ) 
{ 
	audioQueue *pAqData = (audioQueue *) aqData;  
	
	AudioQueueStop (pAqData->mQueue, true );
	pAqData->busy = false;
	pAqData->bPlaying = false;
} 


	
void ofxRKAQSoundPlayer::loadSound(string filename,int midiNote,int velocity,bool bChokeGroup) {
	
	buffer * buf = new buffer;
	
	CFStringRef fileName = CFStringCreateWithCString(NULL,filename.c_str(),kCFStringEncodingASCII);
	CFURLRef audioFileURL =CFURLCreateWithString(NULL,fileName,NULL);
	AudioFileID						mAudioFile;
	OSStatus result = AudioFileOpenURL ( audioFileURL, kAudioFileReadPermission,  kAudioFileCAFType ,&mAudioFile );  //0x01/*fsRdPerm*/
	CFRelease (audioFileURL);           
	
	/*
	CFErrorRef error = CFErrorCreate (NULL,kCFErrorDomainOSStatus,result,NULL);
	CFStringRef errorDesc = CFErrorCopyDescription(error);	
	CFStringRef errorReason = CFErrorCopyFailureReason(error);
	CFStringRef errorRecovery = CFErrorCopyRecoverySuggestion(error);
	 */
	
	UInt64 mNumPacketsToRead;
	UInt32 packetCountSize = sizeof(mNumPacketsToRead);
	result  = AudioFileGetProperty(mAudioFile, kAudioFilePropertyAudioDataPacketCount, &packetCountSize, &mNumPacketsToRead);
	//std::cout << mNumPacketsToRead;
		
	UInt32 byteCountSize = sizeof(buf->bufferByteSize);
	result = AudioFileGetProperty(mAudioFile, kAudioFilePropertyAudioDataByteCount, &byteCountSize, &(buf->bufferByteSize));
	
	//NSUInteger length = buf->bufferByteSize;
	//buf->data  = [[NSMutableData dataWithLength:length] retain];
	buf->data = calloc( buf->bufferByteSize,1);
	
	UInt32 dataFormatSize = sizeof (buf->mDataFormat);     
	AudioFileGetProperty ( mAudioFile,kAudioFilePropertyDataFormat,&dataFormatSize, &(buf->mDataFormat));
	
	UInt32 numBytesReadFromFile;                               
    UInt32 numPackets = mNumPacketsToRead;       
    AudioFileReadPackets (mAudioFile, false, &numBytesReadFromFile, NULL, 0, &numPackets, buf->data); 
	
	AudioFileClose (mAudioFile); 
	
	if (numBytesReadFromFile!=buf->bufferByteSize)
		printf("error: audio length (%u) != length of bytes read (%u) \n",buf->bufferByteSize,numBytesReadFromFile);

	buf->velocity = (float)velocity/127.0;
	buf->bChokeGroup = bChokeGroup;
	midiNotesMap[midiNote] = buffers.size(); // (midiNote-12) % 24
	buffers.push_back(buf);
	if (buf->bChokeGroup)
		cout << filename << " in choke group\n";
	
}

void ofxRKAQSoundPlayer::init(int numQueues, bool bMulti) {
	this->bMulti = bMulti;
	maxBufferByteSize = 0;
	for (vector<buffer*>::iterator iter = buffers.begin();iter!=buffers.end();iter++)
		maxBufferByteSize = (*iter)->bufferByteSize> maxBufferByteSize ? (*iter)->bufferByteSize : maxBufferByteSize;
	
	
	for (int i=0;i<numQueues;i++) {
		audioQueue * que = new audioQueue;
		
		AudioQueueNewOutput (&((*(buffers.begin()))->mDataFormat), HandleOutputBuffer, que, NULL,NULL, 0, &(que->mQueue) ); 
		//AudioQueueNewOutput (&((*(buffers.begin()))->mDataFormat), HandleOutputBuffer, que, CFRunLoopGetCurrent (), kCFRunLoopCommonModes, 0, &(que->mQueue) ); 
		
		AudioQueueAllocateBuffer ( que->mQueue, maxBufferByteSize, &(que->mBuffer)); 
		que->busy = false;
		//que->mData=[NSMutableData dataWithBytesNoCopy:que->mBuffer->mAudioData length:maxBufferByteSize freeWhenDone:NO];
		queues.push_back(que);
	}
	
	ofxRKAQSoundPlayer::bStarted = false;
	lastQueued = 0;
	
}




void ofxRKAQSoundPlayer::release() {
	for (vector<audioQueue*>::iterator iter=queues.begin();iter!=queues.end();iter++) {
		if ((*iter)->busy==true)
			AudioQueueStop((*iter)->mQueue, true);
		AudioQueueDispose((*iter)->mQueue, true);
	}
	
}

void ofxRKAQSoundPlayer::unloadSounds() {
	for (vector<buffer*>::iterator iter=buffers.begin();iter!=buffers.end();iter++)
		free((*iter)->data);
}


void ofxRKAQSoundPlayer::update() {
	
	UInt64 currentTime = GetCurrentTime();
	if (bMulti) {
		UInt64 maxTime = 0;
		audioQueue* lastPlayed = 0;
		
		for (vector<audioQueue*>::iterator iter=queues.begin();iter!=queues.end();iter++) 
			if ((*iter)->busy==true && buffers[(*iter)->note]->bChokeGroup) {
				if (!(*iter)->bPlaying)
					(*iter)->bPlaying = (*iter)->playTime <= currentTime;
				if ((*iter)->bPlaying && (*iter)->playTime > maxTime) {
					lastPlayed = *iter;
					maxTime = lastPlayed->playTime;
				}
			}
		if (lastPlayed) 
			for (vector<audioQueue*>::iterator iter=queues.begin();iter!=queues.end();iter++) 
				if((*iter)->busy==true && buffers[(*iter)->note]->bChokeGroup && (*iter)->bPlaying && (*iter)!=lastPlayed) {
					AudioQueueStop((*iter)->mQueue, true);
					(*iter)->busy = false;
					(*iter)->bPlaying = false;
				}
	} else { 
		if (lastQueued && lastQueued->playTime <= currentTime) 
		{	
			for (vector<audioQueue*>::iterator iter = queues.begin();iter!=queues.end();iter++) 
				if ((*iter)!=lastQueued && (*iter)->busy==true) {
					AudioQueueStop((*iter)->mQueue, true);
					(*iter)->busy = false;
					(*iter)->bPlaying = false;
				}
			lastQueued = 0;
		}
	}
						
	//CFRunLoopRunInMode (kCFRunLoopDefaultMode, 0, true ); // from the static days
}


void ofxRKAQSoundPlayer::Start() {
	 
	
	ofxRKAQSoundPlayer::startHostTime = GetCurrentTime() ;
	ofxRKAQSoundPlayer::bStarted = true;
	ofxRKAQSoundPlayer::startTick = 0;
	cout<<"AQ started - startTime: "<< ofxRKAQSoundPlayer::startHostTime <<"\n";
	
}

void ofxRKAQSoundPlayer::Stop() {
	ofxRKAQSoundPlayer::bStarted = false;
	
}

void ofxRKAQSoundPlayer::SetBPM(int bpm,int currentTick) {
	if (ofxRKAQSoundPlayer::bStarted) {
		ofxRKAQSoundPlayer::startHostTime += (currentTick-ofxRKAQSoundPlayer::startTick) * ofxRKAQSoundPlayer::clocksPerTick;
		ofxRKAQSoundPlayer::startTick = currentTick;
	}
	
	ofxRKAQSoundPlayer::clocksPerTick = GetFrequency()*60/(96*bpm); 
	printf("setBPM - bpm: %u, clocksPerTick: %f\n",bpm,ofxRKAQSoundPlayer::clocksPerTick);

}

void ofxRKAQSoundPlayer::queueNote(int tick,int midiNote,int velocity) {
	//midiNote = (midiNote - 12) % 24;
	
	//cout<<"currentTime: " << GetCurrentTime() ;
	
	vector<audioQueue*>::iterator iter;
	
	for ( iter = queues.begin();iter!=queues.end() ;iter++)
		if ((*iter)->busy==false)
			break;

	
	if (iter!=queues.end()) {
		audioQueue * que = *iter;
		Float32 gain = (float)velocity/127.0;           
		
		AudioQueueSetParameter (que->mQueue, kAudioQueueParam_Volume, gain); 
		(*iter)->note = midiNotesMap[midiNote];
		buffer *buf = buffers[que->note];
		
		memcpy(que->mBuffer->mAudioData,buf->data,buf->bufferByteSize);
		que->mBuffer->mAudioDataByteSize = buf->bufferByteSize;
		//[(*iter)->mData replaceBytesInRange:NSMakeRange(0, buf->bufferByteSize) withBytes:[buf->data mutableBytes] length:buf->bufferByteSize];
		AudioQueueEnqueueBuffer(que->mQueue, que->mBuffer,  0, NULL);
		
		AudioTimeStamp nextStep;
		Float64 accumulatedDelay = (tick-ofxRKAQSoundPlayer::startTick)*ofxRKAQSoundPlayer::clocksPerTick;
		UInt64 hostTime = ofxRKAQSoundPlayer::startHostTime +  accumulatedDelay;
		FillOutAudioTimeStampWithHostTime(nextStep,hostTime);
						
		//cout<<", schedTime: " << nextStep.mHostTime;
		
		if (hostTime>GetCurrentTime() ) {
			AudioQueueStart (que->mQueue, &nextStep);
			(*iter)->busy=true;
			(*iter)->bPlaying = false;
			(*iter)->playTime = hostTime;
			lastQueued = (*iter);
		}
		//else
			//cout << "...skipped";
		
	}
	
	//cout << "\n";
	
}

void ofxRKAQSoundPlayer::play(int midiNote,int velocity) {
	//printf("play - note: %u, velocity: %u\n",note,velocity);
	
	//midiNote = (midiNote - 12) % 24;
	//cout << "midiInstrument play: " << midiNote;
	vector<audioQueue*>::iterator iter;
	for (iter = queues.begin();iter!=queues.end() && (*iter)->busy==true;iter++);
	
	if (iter!=queues.end()) {
		audioQueue * que = *iter;
		Float32 gain = (float)velocity/127.0;           
		AudioQueueSetParameter (que->mQueue, kAudioQueueParam_Volume, gain); 
		(*iter)->note = midiNotesMap[midiNote];
		buffer *buf = buffers[que->note];
		
		memcpy(que->mBuffer->mAudioData,buf->data,buf->bufferByteSize);
		que->mBuffer->mAudioDataByteSize = buf->bufferByteSize;
		//[(*iter)->mData replaceBytesInRange:NSMakeRange(0, buf->bufferByteSize) withBytes:[buf->data mutableBytes] length:buf->bufferByteSize];
		AudioQueueEnqueueBuffer(que->mQueue, que->mBuffer,  0, NULL);
		AudioQueueStart (que->mQueue, NULL);
		que->busy=true;
		(*iter)->playTime = GetCurrentTime();
		(*iter)->bPlaying = true;
		lastQueued = (*iter);
		//printf("playing\n",note,velocity);
		//CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1, false);
	}	
}

