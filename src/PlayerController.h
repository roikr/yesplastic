#ifndef _PLAYER_CONTROLLER
#define _PLAYER_CONTROLLER


class ofxXmlSettings;
class TexturesPlayerBase;
class ofxMidiInstrument;



#include "ofxRKTexture.h"
#include "TexturesPlayer.h"
#include "ofxMidiLooper.h"
#include "ofxMidiTrack.h"
#include <map>
#include <set>


class PlayerController  {

public:
	PlayerController();
	void setup(int playerNum);
	void update();
	void translate();
	void draw();
	
	void exit();
	
	//void touchDown(float x, float y);
	//void keyPressed(int key);
	void play(int num);
		
	
	void loadSet(string soundSet,string songName="");
	void changeSet(string soundSet);
		
	string getCurrentSoundSet();
	
	void threadedFunction();
	
	void setPush(bool bPush);
	void setState(int state);
	float getScale();
	bool isInTransition();
	bool isEnabled();
	
	bool enable;
	int transitionState;
	
	void sync();
	void setMode(int mode);
	int getMode();
	
	int getCurrentLoop();
	void changeLoop(int loopNum);
	
	void processWithBlocks(float *left,float *right);
	
	void setVolume(float volume); //  0.0 to 1.0
	float getVolume();
	
	void setBPM(int bpmVal);
	
	void setSongState(int songState);
	int  getSongState();
	
	void saveSong(string filename);
	
	bool getIsRecording();
	bool getIsPlaying();

	
private:
	
	void unloadVideoSet();
	
	void loadSoundSet();
	void loadVideoSet();
	
	TexturesPlayer *createTexturePlayer(string soundSet,string videoSet);
		
	TexturesPlayer *previousPlayer;
	TexturesPlayer *currentPlayer;
	TexturesPlayer *nextPlayer;
	
	ofxMidiInstrument *midiInstrument;
		
	string soundSet;
	int playerNum;
	
	string videoSet;
	string nextVideoSet;
	string songName;
	//string soundSetPath;
	bool bFramesDriverPlayer;
	
	
	// came from MidiTrack
	
	
	
	ofxMidiLooper midiTrack;

	//string prefix;
	
	bool multi;
	
	vector<int> midiNotes;
	map<int,int> keyToMidi;
	map<int,int> midiToSample;
	
	void loadLoop(string filename);
	
	float volume;
	
	int mode;
	
	int currentLoop;
	
	int songState;
	
	ofxMidiTrack song;
	vector<event> recordEvents;
		
	bool bVisible;
	bool bAnimatedTransition;

};

#endif