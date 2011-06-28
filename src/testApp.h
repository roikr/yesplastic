#pragma once


#include "ofMain.h"
//#include "ofxMultiTouch.h"
//#include "ofxAccelerometer.h"
#include "PlayerController.h"


#include "ofxXmlSettings.h"
//#include "ofxOsc.h"
#include "ofxRKTexture.h"
#include "ofxAudioFile.h"
#include "ofxPincher.h"
#include "ofxSlider.h"



class testApp : public ofSimpleApp  {
	
public:
	
	testApp();
	
	void setup();
	void update();
	void transitionLoop();
	void draw();
	void release();
	
	void resume();
	void suspend();
	
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
	void touchDoubleTap(int x, int y, int touchId);
	
	void moveBack();
		
	float getVolume();
	void setVolume(float vol);
	
	int getBPM();
	void setBPM(int bpm);
	
	void getTrans(int state,int controller,ofPoint &pnt,float &ts);
	
	int getSongVersion();
	void saveSong(string songName);
	void setSongState(int songState);
	int  getSongState();
	bool getIsPlaying();
	
	void renderAudio() ;
	void cancelRenderingAudio();
	
	//void getVideoTrans(int state,int controller,float &tx,float &ty,float &ts);
	void render();
	
	bool isInTransition();
	
	bool isSongAvailiable(string song,int playerNum=0);
	void loadSong(string songName,bool bDemo);
	void changeSoundSet(string nextSoundSet);
	
	string getCurrentSoundSetName(int playerNum);
	string getPlayerName(int playerNum); // using to build SoundSet name from Song name and for loop and triggers buttons

	int controller;
	PlayerController player[3];
//	bool bMenu;
	
	void playRandomLoop();
	
	
	void soundStreamStart();
	void soundStreamStop();
	
	
	float getProgress();
	float getRenderProgress();
	
	
	bool bNeedDisplay; // refresh the control layer due to changes in state, mode, etc
	
	
	
	
	
private:
	void soundStreamClose();
	
	int startTime;
	int currentFrame;
	
	int songVersion;
	int startRecordingTime;
	
	void startRecording();
	
	//float scale;
	
	ofxRKTexture background;
	
	
	
	//ofTrueTypeFont	verdana;
		
	ofxXmlSettings xml;
		
	int state;
	int songState;
	
	map<string,int>oscMap;
	//ofxOscReceiver receiver;
	
	//int bChangeSet; // //TODO: is it realy needed ?  to delay change video set to next update (so draw wont change)
	string nextSoundSet;
	
	float alpha;
	bool bTrans;  // I believe it is the transtion between BAND and SOLO states
	int animStart;
		
	float *buffer;
	int nChannels;
	
	int sampleRate;
	int blockLength;
	
	float bpm;
	
	ofxAudioFile song; // just for saving
		
	bool bInitialized;
	bool bInTransition;
	
	float duration;
	int currentBlock;    //using to seekFrame and renderAudio for rendering video & audio;
	int totalBlocks; // calculating by renderAudio before rendering video - 
	// because we don't use midi instrument while video rendering, we need to know when the last sample occured...
	
	ofxSlider slider;
	bool bPush;
	
	ofxPincher pincher;
	int pincherStart; //  start frame for animating scaling
	int lastRenderedFrame;
	
};



