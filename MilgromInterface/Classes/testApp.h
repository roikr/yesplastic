#pragma once


//#include "ofMain.h"
#include <string>
using namespace std;



class testApp   {
	
public:
	void setup();
	void update();
	void draw();
	void exit();
	
		
	
	void buttonPressed(int button);
	void nextLoop(int player);
	void prevLoop(int player);
	int getCurrentLoop(int player);
	
	void setMode(int player,int mode);
	int getMode(int player);
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
	
	float getBPM();
	void setBPM(float bpm);
	
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

	
	void playRandomLoop();
	void soundStreamStart();
	void soundStreamStop();	
	
	float getProgress();
	
	bool bNeedDisplay; // refresh the control layer due to changes in state, mode, etc
	
	
	int lastFrame;
	
	int controller;
	//PlayerController player[3];
	bool bMenu;
	
private:
	float volume;
	float bpm;
	int state;
	int songState;
		
	
	
	
	
};



