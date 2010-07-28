
#include "testApp.h"


#include "Constants.h"
#include <math.h>
#include <iostream>




void testApp::setup(){	
	
	controller = 0;
	
}

bool testApp::isSoundSetAvailiable(string soundSet) {
	return true;
}




void testApp::setMode(int player,int mode) {
}

int testApp::getMode(int player) {
	return LOOP_MODE;
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
