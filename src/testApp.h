#pragma once


#include "ofMain.h"
//#include "ofxMultiTouch.h"
//#include "ofxAccelerometer.h"
#include "PlayerController.h"

#include "MidiTrack.h"
#include "ofxXmlSettings.h"
//#include "ofxOsc.h"
#include "ofxRKThread.h"
#include "ofxRKTexture.h"


struct measure {
	int x;
	int y;
	int t;
};

class testApp : public ofSimpleApp, public ofxRKThread  {
	
public:
	void setup();
	void update();
	void draw();
	void exit();
	
	void setMode(int player,int mode);
	void setState(int state);
		
	void touchDown(float x, float y, int touchId);
	void touchMoved(float x, float y, int touchId);
	void touchUp(float x, float y, int touchId);
	
	void moveBack();
		
	void threadedFunction();
	
	void updateAudio();
	
	float getVolume();
	void setVolume(float vol);
	
	float getBPM();
	void setBPM(float bpm);
	
	void getTrans(int state,int controller,float &tx,float &ty,float &ts);
	
	void play();
	bool getIsPlaying();
	bool getIsSongDone();
	void stop();
	void record();
	
	void saveMidi();
	
	bool isInTransition();
	bool isSoundSetAvailiable(string soundSet);
	void changeSoundSet(string nextSoundSet, bool bChangeAll);
	
	int lastFrame;
	
	int controller;
	PlayerController player[3];
	
	float scale;
	
	ofxRKTexture background;
	
	ofxRKTexture buttons;
	bool bButtonDown;
	int button;
		
		
	ofTrueTypeFont	verdana;
		
	ofxXmlSettings xml;
		
	int state;
	
	map<string,int>oscMap;
	//ofxOscReceiver receiver;
	
	int bChangeSet; // to delay change video set to next update (so draw wont change)
	string nextSoundSet;
	bool bChangeAll;
	
	float alpha;
	bool bTrans;
	int animStart;
		
	bool bMove;
	int moveTime;
	float sx;
	
	vector<measure> measures;
	int nextLoop;
	float vx;
	
	bool bMenu;
	
	
	
};



