#ifndef _PLAYER_CONTROLLER
#define _PLAYER_CONTROLLER


class ofxXmlSettings;
class TexturesPlayerBase;
class ofxMidiInstrument;



#include "ofxRKTexture.h"
#include "TexturesPlayer.h"
#include "ofxMidiLooper.h"
#include "ofxMidiTrack.h"
#include "ofxSndFile.h"

#include <map>
#include <set>

class PlayerController  {

public:
	PlayerController();
	void setup(int playerNum);
	void update();
	void nextFrame();
	void translate();
	void draw();
	
	void exit();
	
	string getName();
	
	//void touchDown(float x, float y);
	//void keyPressed(int key);
	void play(int num);
		
	
	void loadSet(string soundSet,string songName="");
	void changeSet(string soundSet);
		
	string getCurrentSoundSet();
	
	void setPush(bool bPush);
	void setState(int state);
	float getScale();
	bool isInTransition();
		
	
	
	void sync();
	void setMode(int mode);
	int getMode();
	
	int getCurrentLoop();
	void changeLoop(int loopNum);
	
	void processWithBlocks(float *left,float *right);
	void processForVideo();
	
	void setVolume(float volume); //  0.0 to 1.0
	float getVolume();
	
	void setBPM(int bpmVal);
	
	void setSongState(int songState);
	int  getSongState();
	
	void saveSong(string filename);
	
	bool getIsRecording();
	bool getIsPlaying();
	
	float getProgress();
	float getDuration();
	float getPlayhead();
	
	
private:
	bool bInitialized;
	int transitionState;
	
	float progress;
	
	void unloadVideoSet();
	
	void loadSoundSet();
	void loadVideoSet();
	
	void loadSong();
	
	TexturesPlayer *createTexturePlayer(string soundSet,string videoSet);
		
	TexturesPlayer *previousPlayer;
	TexturesPlayer *currentPlayer;
	TexturesPlayer *nextPlayer;
	
	ofxMidiInstrument *midiInstrument;
		
	string soundSet;
	int playerNum;
	
	string videoSet;
	string nextVideoSet;
	
	//string soundSetPath;
	bool bFramesDriverPlayer;
	
	
	// came from MidiTrack
	
	
	
	ofxMidiLooper looper;

	//string prefix;
	
	vector<int> midiNotes;
	map<int,int> keyToMidi;
	map<int,int> midiToSample;
	
	void loadLoop(string filename);
	
	float volume;
	
	int mode;
	
	int currentLoop;
	
	int songState;
	
	string songName;
	ofxMidiTrack song;
	vector<event> recordEvents;
		
	bool bVisible;
	bool bAnimatedTransition;
	
	bool bMulti;
	
	ofxSndFile switchSound;
	bool bPlaySwitchSound;
	int switchStart;
};

#endif