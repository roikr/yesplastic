#ifndef _PLAYER_CONTROLLER
#define _PLAYER_CONTROLLER


class ofxXmlSettings;
class TexturesPlayerBase;


#include "MidiTrack.h"
#include "ofxRKTexture.h"
#include "TexturesPlayer.h"


class PlayerController  {

public:
	PlayerController();
	void setup(int playerNum);
	void update();
	void translate();
	void draw();
	
	void exit();
	
	void touchDown(float x, float y);
	void keyPressed(int key);
	void play(int num);
		
	MidiTrack *getMidiTrack();

	
	
	void changeSet(string soundSet);
	string getCurrentSoundSet();
	
	
	
	void threadedFunction();
	
	void setState(int state);
	float getScale();
	bool isInTransition();
	bool isEnabled();
	
	bool enable;
	int transitionState;
	
private:
	
	TexturesPlayer *getTexturesPlayer();
		
	TexturesPlayer *previousPlayer;
	TexturesPlayer *currentPlayer;
	TexturesPlayer *nextPlayer;
	MidiTrack midiTrack;
	
	string soundSet;
	string subSoundSet;
	int playerNum;
	
	string videoSet;
	string soundSetPath;
	bool bFramesDriverPlayer;

};

#endif