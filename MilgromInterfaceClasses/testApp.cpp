
#include "testApp.h"


#include "Constants.h"
#include <math.h>
#include <iostream>




void testApp::setup(){	
	
	controller = 0;
	
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



void testApp::setMode(int player,int mode) {
}

int testApp::getMode(int player) {
	return MANUAL_MODE;
}

void testApp::setState(int state) {
	this->state = state;
}

int	testApp::getState() {
	return state;
}

bool testApp::isInTransition() {
	return false;
}

void testApp::changeSoundSet(string nextSoundSet, bool bChangeAll) {
	
	
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


void testApp::playSong() {
	
	
}

void testApp::stopSong() {
	
}

void testApp::recordSong() {
	
	
}

bool testApp::getIsSongPlaying() {
	
	return false;
}

bool testApp::loadSong(string songName) {
	
	printf("testApp::loadSong: %s\n",songName.c_str());
	
	return true;
}



void testApp::saveSong(string songName) {
	
	printf("testApp::saveSong: %s\n",songName.c_str());


	
}
	


void testApp::didBecomeAcive() {
	cout << "testApp::didBecomeAcive" << endl;
	
}

void testApp::willResignActive() {
	cout << "testApp::willResignActive" << endl;
	;

}

void testApp::playRandomLoop() {
}
