
#include "testApp.h"


#include "Constants.h"
#include <math.h>
#include <iostream>




void testApp::setup(){	
	
	controller = 0;
	songState = SONG_IDLE;
	
}

bool testApp::isSongAvailiable(string song,int playerNum) {
//	vector<string> soundSets = ofListFolders(ofToDataPath("SOUNDS"));
//	for (vector<string>::iterator iter = soundSets.begin(); iter!=soundSets.end(); iter++) {
//		if (*iter == getPlayerName(playerNum)+"_"+song) {
//			return true;
//		}
//	}
	return true;
}


void testApp::draw(){
}

void testApp::update(){
}


string testApp::getPlayerName(int playerNum)  {
	switch (playerNum) {
		case 0:
			return "GTR";
			break;
		case 1:
			return "VOC";
			break;
		case 2:
			return "DRM";
			break;
		default:
			return "";
			break;
	}
}


void testApp::setMode(int player,int mode) {
}

int testApp::getMode(int player) {
	return MANUAL_MODE;
}

void testApp::stopLoops() {
	bNeedDisplay = true;
}

void testApp::setState(int state) {
	this->state = state;
	bNeedDisplay = true;
}

int	testApp::getState() {
	return state;
}

bool testApp::isInTransition() {
	return false;
}

void testApp::changeSoundSet(string nextSoundSet) {
	bNeedDisplay = true;
	
}



void testApp::exit() {
	printf("exit()\n");
	
}


void testApp::buttonPressed(int button) {
	
//	if (player[controller].isEnabled() && !player[controller].isInTransition()) {					
//		if ( player[controller].getMode() == MANUAL_MODE ) {
//			player[controller].play(button);	
//		}
//		
//		if ( player[controller].getMode() == LOOP_MODE ) {
//			player[controller].changeLoop(button);		
//		}			
//	}
	
}



//--------------------------------------------------------------
void testApp::touchDown(float x, float y, int touchId) {
	
	printf("touchDown: %.f, %.f %i\n", x, y, touchId);
	
	
	if (songState == SONG_TRIGGER_RECORD) {
		setSongState(SONG_RECORD);
	}
	
	
}


	
	
	
	

void testApp::touchMoved(float x, float y, int touchId) {
	//printf("touchMoved: %.f, %.f %i\n", x, y, touchId);
	
	
}


void testApp::touchUp(float x, float y, int touchId) {
	//printf("touchUp: %.f, %.f %i\n", x, y, touchId);
	
		
	
}

void testApp::nextLoop(int player) {
	//this->player[player].changeLoop((this->player[player].getCurrentLoop()+1)%8);
}

void testApp::prevLoop(int player) {
	//this->player[player].changeLoop((this->player[player].getCurrentLoop()+7)%8);
}

int testApp::getCurrentLoop(int player) {
	return 5;
}
	

float testApp::getVolume() {
	return volume;
}
	
void testApp::setVolume(float vol) {
	volume = vol;
}



float testApp::getBPM() {
	return bpm;
}

void testApp::setBPM(float bpm) {
	
	this->bpm = bpm;
}


void testApp::renderAudio() {
	
		
}


void testApp::setSongState(int songState) {
	
	
	
	this->songState = songState;
	
	
	bNeedDisplay = true;
		
	
}

int  testApp::getSongState() {
	
	//switch (songState) {
//		case SONG_PLAY:
//		case SONG_RENDER_AUDIO:
//		case SONG_RENDER_VIDEO:
//			if (! getIsPlaying()) {
//				songState = SONG_IDLE;
//				
//			}
//			break;
//			
//		default:
//			break;
//	}
	
	
	
	return songState;
}


void testApp::loadSong(string songName,bool bDemo) {
	
	printf("testApp::loadSong: %s\n",songName.c_str());
	
}



void testApp::saveSong(string songName) {
	
	printf("testApp::saveSong: %s\n",songName.c_str());


	
}



void testApp::playRandomLoop() {
}

string testApp::getCurrentSoundSetName(int playerNum) {
	switch (playerNum) {
		case 0:
			return "GTR_HEAT";
			break;
		case 1:
			return "VOC_HEAT";
			break;
		case 2:
			return "DRM_HEAT";
			break;
		default:
			return "";
			break;
	}
}

bool testApp::isSongValid() {
	return true;
}


bool testApp::isSongOverwritten() {
	return false;
}

void testApp::soundStreamStart() {
}

void testApp::soundStreamStop() {
	
}

void testApp::threadedFunction() {
	
}

float testApp::getProgress() {
	return 0.0f;
}
