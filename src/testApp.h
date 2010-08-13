#pragma once


#include "ofMain.h"
//#include "ofxMultiTouch.h"
//#include "ofxAccelerometer.h"
#include "PlayerController.h"


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
	
	void audioRequested( float * output, int bufferSize, int nChannels );
	
	void buttonPressed(int button);
	void nextLoop(int player);
	void prevLoop(int player);
	
	
	
	int getMode(int player);
	void setMode(int player,int mode);
	
	void setState(int state);
	int	getState();
		
	void touchDown(float x, float y, int touchId);
	void touchMoved(float x, float y, int touchId);
	void touchUp(float x, float y, int touchId);
	
	void moveBack();
		
	void threadedFunction();
	
	float getVolume();
	void setVolume(float vol);
	
	float getBPM();
	void setBPM(float bpm);
	
	void getTrans(int state,int controller,float &tx,float &ty,float &ts);
	
	bool loadSong(string songName);
	void playSong();
	bool getIsSongPlaying();
	void stopSong();
	void recordSong();
	void saveSong(string songName);
	
	bool isInTransition();
	
	bool isSongAvailiable(string song,int playerNum=0);
	void changeSoundSet(string nextSoundSet, bool bChangeAll);
	
	
	void didBecomeAcive();
	void willResignActive();
	
	int lastFrame;
	
	int controller;
	PlayerController player[3];
	bool bMenu;
	
private:
	
	string getPlayerName(int playerNum); // using to build SoundSet name from Song name
	
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
	int nextLoopNum;
	float vx;
	
	
	
	float *lBlock;
	float *rBlock;
	
	int sampleRate;
	int blockLength;
	
	float bpm;
	
	
};



