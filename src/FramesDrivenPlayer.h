#ifndef _FRAMES_DRIVEN_PLAYER
#define _FRAMES_DRIVEN_PLAYER

#include "ofMain.h"


#include <map> // for iPhone


#include "ofxRKActor.h"
#include "TexturesPlayer.h"
#include "ofxFramesDriver.h"
#include "ofxOnePointTracks.h"
#include "ofxRKTexture.h"


class FramesDrivenPlayer : public TexturesPlayer{

public:
	FramesDrivenPlayer(string soundSet);
	void setup(string setName);
	
	void update();
	void translate();
	void draw();
	void exit();
	
	void play(int i);
	void setPush(bool bPush);
	void setState(int state);
	void setFont(ofTrueTypeFont * font);
	
	void initIdle();
	void loadIdle();
	void unloadIdle();
	void initIn();
	void loadIn();
	void unloadIn();
	void initSet();
	void loadSet();
	void unloadSet();
	void initOut();
	void loadOut();
	void unloadOut();
	void release();
	
	
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
	string soundSet;
	
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
	
	//string subSoundSet;
	vector<int>sequences; // for samples
	vector<int>specSeqs;
	
	bool bPush;
	int pushWidth;
	int pushHeight;
	ofxRKTexture pushTexture;
	
};

#endif