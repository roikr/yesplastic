#ifndef _FRAMES_DRIVEN_PLAYER
#define _FRAMES_DRIVEN_PLAYER

#include "ofMain.h"


#include <map> // for iPhone


#include "ofxRKActor.h"
#include "TexturesPlayer.h"
#include "ofxFramesDriver.h"
#include "ofxOnePointTracks.h"


class FramesDrivenPlayer : public TexturesPlayer{

public:
	FramesDrivenPlayer(string soundSetPath,string subSoundSet);
	void setup(string setName);
	
	void update();
	void translate();
	void draw();
	void exit();
	
	void play(int i);
	void setState(int state);
	void setFont(ofTrueTypeFont * font);
	
	void initIn();
	void prepareIn();
	void initSet();
	void prepareSet();
	void prepareOut();
	void finishOut();
	void releaseSet();
	
	
	//int sequencesNumber();
	void startTransition(bool bPlayIn);
	bool didTransitionEnd();
	float getScale();
	string displayName;
	

private:
	
	int getCurrentFrame();
	void setDrivenSample(string sampleName);
	
	ofxRKActor lipsActor;
	ofxFramesDriver driver;
	ofxOnePointTracks track;

	
	string setName;
	string soundSetPath;
	
	int x;
	int y;
	int tx;
	int ty;
	
	int lx;
	int ly;
	
	int solo_x;
	int solo_y;
	float solo_scale;
	
	bool enable;
	int state;
	
	int nextSequence;
	bool bChangeSequence;
	
	ofxRKActor actor;
	
	ofTrueTypeFont	*font;
	
	bool bTransitionEnded;
	
	string debugStr;
	
	int currentFrame;
	
	string subSoundSet;
	vector<int>sequences; // for samples
	vector<int>specSeqs;
	
};

#endif