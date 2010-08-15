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
	
	void setMode(int player,int mode);
	int getMode(int player);
	
	void setState(int state);
	int	getState();
		
	void touchDown(float x, float y, int touchId);
	void touchMoved(float x, float y, int touchId);
	void touchUp(float x, float y, int touchId);
	
	void moveBack();
		
	float getVolume();
	void setVolume(float vol);
	
	float getBPM();
	void setBPM(float bpm);
	
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
	//PlayerController player[3];
	bool bMenu;
	
private:
	float volume;
	float bpm;
	int state;
		
	
	
	
	
};



