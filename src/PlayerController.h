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
		
	void changeSet(string soundSet,bool bLoadDemo = false);
	string getCurrentSoundSet();
	
	void threadedFunction();
	
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
	
	void setSongMode(int songMode);
	int getSongMode();
	
	void processWithBlocks(float *left,float *right);
	
	void setVolume(float volume); //  0.0 to 1.0
	float getVolume();
	
	void setBPM(int bpmVal);
	
	void loadSong(string filename);
		void playSong();
	void recordSong();
	void stopSong();
	bool getIsPlaying();
	void saveSong(string filename);
	
	
	
private:
	
	void loadDemo(); // parallel to change set so I have to provide the set name

	
	bool getIsRecording(); // TODO: do I really need it ?
	
	void loadSoundSet(string soundSet);
	
	TexturesPlayer *getTexturesPlayer();
		
	TexturesPlayer *previousPlayer;
	TexturesPlayer *currentPlayer;
	TexturesPlayer *nextPlayer;
	
	ofxMidiInstrument *midiInstrument;
		
	string soundSet;
	string subSoundSet;
	int playerNum;
	
	string videoSet;
	string nextVideoSet;
	string soundSetPath;
	bool bFramesDriverPlayer;
	
	
	// came from MidiTrack
	
	
	
	ofxMidiLooper midiTrack;

	string prefix;
	
	bool multi;
	
	map<int,int> keyToMidi;
	map<int,int> midiToSample;
	
	void loadLoop(string filename);
	
	float volume;
	
	int mode;
	
	int currentLoop;
	
	int songMode;
	ofxMidiTrack song;
	vector<event> recordEvents;
	
	bool bLoadDemo;

};

#endif