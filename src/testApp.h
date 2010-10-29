#pragma once


#include "ofMain.h"
//#include "ofxMultiTouch.h"
//#include "ofxAccelerometer.h"
#include "PlayerController.h"


#include "ofxXmlSettings.h"
//#include "ofxOsc.h"
#include "ofxRKTexture.h"
#include "ofxSndFile.h"


struct measure {
	int x;
	int y;
	int t;
};

class testApp : public ofSimpleApp  {
	
public:
	testApp() {
		bInitialized = false;
		bChangeSet = false;
	}
	
	void setup();
	void update();
	void nextFrame();
	void draw();
	void exit();
	
	void seekFrame(int frame); // for video rendering
	void audioRequested( float * output, int bufferSize, int nChannels );
	
	void buttonPressed(int button);
	void nextLoop(int player);
	void prevLoop(int player);
	int getCurrentLoop(int player);
	
	
	int getMode(int player);
	void setMode(int player,int mode);
	void stopLoops();
	
	void setState(int state);
	int	getState();
		
	void touchDown(float x, float y, int touchId);
	void touchMoved(float x, float y, int touchId);
	void touchUp(float x, float y, int touchId);
	
	void moveBack();
		
	void threadedFunction();
	
	float getVolume();
	void setVolume(float vol);
	
	int getBPM();
	void setBPM(int bpm);
	
	void getTrans(int state,int controller,float &tx,float &ty,float &ts);
	
	bool isSongValid();
	bool isSongOverwritten();
	bool canRenderSong();
	void saveSong(string songName);
	void setSongState(int songState);
	int  getSongState();
	bool getIsPlaying();
	
	void renderAudio() ;
	
	bool isInTransition();
	
	bool isSongAvailiable(string song,int playerNum=0);
	void loadSong(string songName,bool bDemo);
	void changeSoundSet(string nextSoundSet);
	
	string getCurrentSoundSetName(int playerNum);
	string getPlayerName(int playerNum); // using to build SoundSet name from Song name and for loop and triggers buttons

	
	int lastFrame;
	
	int controller;
	PlayerController player[3];
	bool bMenu;
	
	void playRandomLoop();
	
	void soundStreamSetup();
	void soundStreamStart();
	void soundStreamStop();
	void soundStreamClose();
	
	float getProgress();
	float getPlayhead();
	
	
	bool bNeedDisplay; // refresh the control layer due to changes in state, mode, etc
	
	
private:
	
	bool bIsSongOverwritten;
	bool bIsSongValid;
	int startRecordingTime;
	
	void startRecording();
	
		
	float scale;
	
	ofxRKTexture background;
	
//	ofxRKTexture buttons;
//	bool bButtonDown;
//	int button;
		
	
	bool bPush;
	
	ofTrueTypeFont	verdana;
		
	ofxXmlSettings xml;
		
	int state;
	int songState;
	
	map<string,int>oscMap;
	//ofxOscReceiver receiver;
	
	int bChangeSet; // //TODO: is it realy needed ?  to delay change video set to next update (so draw wont change)
	string nextSoundSet;
	
	
	float alpha;
	bool bTrans;  // I believe it is the transtion between BAND and SOLO states
	int animStart;
		
	bool bMove; // dragging around
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
	
	ofxSndFile song; // just for saving
		
	bool bInitialized;
	bool bInTransition;
	
	int currentBlock;    //using to seekFrame for rendering video;
	int totalBlocks; // calculating by renderAudio before rendering video
};



