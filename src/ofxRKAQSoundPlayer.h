#pragma once

#import <AudioToolbox/AudioToolbox.h>

#include <stdio.h>
#include <vector>
#include <map>
#include <string>
#include <sstream>  //for ostringsream

struct audioQueue {
	AudioQueueRef					mQueue;
	AudioQueueBufferRef				mBuffer;
	//NSMutableData					* mData;
	
	bool busy;
	UInt64 playTime;
	int note;
	bool bPlaying;
};


struct buffer {
	void * data;
	UInt64 bufferByteSize;
	AudioStreamBasicDescription		mDataFormat;
	bool bChokeGroup;
	float velocity;
	
};


using namespace std; 

class ofxRKAQSoundPlayer
{
public:
	
	
	void	loadSound(string filename,int midiNote,int velocity,bool bChokeGroup=false);
	void	init(int numQueues, bool bMulti);
	void	release();
	void	unloadSounds();

	
	static void SetBPM(int bpm,int currentTick=0);		
	static void	Start();
	static void	Stop();
	
	void update();
	
	
	
	void queueNote(int tick,int midiNote,int velocity);
	void play(int note,int velocity);
		
		
	
private:
	
	static UInt64 startHostTime;
	static int startTick;
	static Float64 clocksPerTick;
	static bool bStarted;
	
	bool bMulti;
	
	
	vector<audioQueue*> queues;
	vector<buffer*> buffers;
	
	
	audioQueue * lastQueued;
	
	UInt32 maxBufferByteSize;
	
	map<int,int>midiNotesMap;
	
};

