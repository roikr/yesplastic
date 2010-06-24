#include "ofMain.h"
#include "SimplePlayer.h"
#include "FramesDrivenPlayer.h"
#include "MidiTrack.h"
#include "PlayerController.h"
#include "ofxXmlSettings.h"
#include "Constants.h"


PlayerController::PlayerController() {
	transitionState = TRANSITION_IDLE;
	enable = false;
	
};

void PlayerController::setup(int playerNum) {
	enable = true;	
	this->playerNum = playerNum;
	//enable = xml->getValue("enable", "true",0) == "true";
	
	
	
	/*
	for (int i=0;i<xml->getNumTags("video_set");i++) { //
		videosMap[xml->getValue("video_set:id","",i)]=i;
		TexturesPlayer* texturePlayer  = new TexturesPlayer;
		texturePlayer->setup(xml,i);
		videos.push_back(texturePlayer);
	}
	 */
	/*
	for (int i=0;i<xml->getNumTags("sound_set");i++) {
		string video = xml->getValue("sound_set:video","",i);
		
		videosMap[video]=i;
		TexturesPlayer* texturePlayer  = new TexturesPlayer;
		texturePlayer->setup(video);
		videos.push_back(texturePlayer);
		
		int videoSet =videosMap[video];
		ofLog(OF_LOG_VERBOSE,"sound set %s using video set %s(%i)",xml->getValue("sound_set:id","",i).c_str(),video.c_str(),videoSet);
		videoSets.push_back(videoSet);
	}
	 */
	
	
	
	if (!enable)
		return;

	//id = xml->getValue("id","");
	//touchArea = xml->getValue("player_num",0);
	
	midiTrack.setup(playerNum);
	
	
	//bChangeVideoSet = false;
	//startThread(true, false);
	
	
	//string filename = xml->getValue("mask:filename","");
//	mask.setup(ofToDataPath(filename));
//	mask.init();
//	mask.load();
//	mask_x = xml->getValue("mask:x",0);
//	mask_width = xml->getValue("mask:width",0);
//	bFade = false;
	
	currentPlayer = 0;
	
}




void PlayerController::changeSet(string soundSet) {
	
	if (isInTransition()) {
		return;
	}
	
	bool bFirstTime = !currentPlayer;
	
	this->soundSet = soundSet;
	
	ofxXmlSettings xml;
	string xmlpath = "SOUNDS/"+soundSet+"/"+soundSet+".xml";
	bool loaded = xml.loadFile(xmlpath);
	
	
	if (loaded) {
		xml.pushTag("sound_set");
		xml.pushTag("player", playerNum);
		bFramesDriverPlayer = xml.getAttribute("video", "lips", 0, 0);
		subSoundSet = xml.getValue("sound:id", "", 0);
		videoSet =	xml.getValue("video","");
		xml.popTag();
		xml.popTag();
	}
	
	ofLog(OF_LOG_VERBOSE,"loading of %s %s - using video: %s",xmlpath.c_str(),loaded ? "succeeded" : "failed",videoSet.c_str());
	
	if (getMidiTrack()->getCurrentVideoSet()!=videoSet) {
		if (playerNum == 1) //  && videoSet == "VOC_CORE"
			nextPlayer = new FramesDrivenPlayer("SOUNDS/"+soundSet,subSoundSet);
		else
			nextPlayer = new SimplePlayer;
		
		nextPlayer->setup(videoSet);
	}
	
	
	
	if (bFirstTime) {
		
		currentPlayer = nextPlayer;
		nextPlayer = 0;
		
		transitionState = TRANSITION_SETUP;
		while (transitionState != TRANSITION_IDLE);
		
		currentPlayer->prepareIn();
		currentPlayer->prepareSet();
		
		midiTrack.setupSoundSet();
		
		midiTrack.setTexturesPlayer(currentPlayer);
		
	} else if (/*getMidiTrack()->getCurrentSet()!=setNum &&*/ !isInTransition()) {
						
		if (getMidiTrack()->getCurrentVideoSet()!=videoSet) {
			
			currentPlayer->prepareOut();
			transitionState = TRANSITION_INIT_IN;
		}
		else {
			//nextSetNum = setNum;
			transitionState = TRANSITION_CHANGE_SOUND_SET;
		}
		
	}
}



string PlayerController::getCurrentSoundSet() {
	return soundSet;
}


bool PlayerController::isInTransition() {
	
	return transitionState != TRANSITION_IDLE;
}

void PlayerController::threadedFunction() {
	if (!enable) 
		return;
	switch (transitionState) {
		case TRANSITION_SETUP:
			currentPlayer->initIn();
			currentPlayer->initSet();
			midiTrack.loadSoundSet(soundSet);
			transitionState = TRANSITION_IDLE;
			break;
		case TRANSITION_INIT_IN:
			nextPlayer->initIn();
			transitionState = TRANSITION_INIT_IN_FINISHED;
			break;
		case TRANSITION_RELEASE_SET: 
			previousPlayer->releaseSet();
			transitionState = TRANSITION_RELEASE_SET_FINISHED;
			break;
		case TRANSITION_INIT_SET:
			currentPlayer->initSet();
			transitionState = TRANSITION_INIT_SET_FINISHED;
			break;
		case TRANSITION_CHANGE_SOUND_SET:
			midiTrack.loadSoundSet(soundSet);
			transitionState = TRANSITION_CHANGE_SOUND_SET_FINISHED;
			break;
	}

}
	
	
void PlayerController::update() {
	if (!enable) 
		return;
	
		switch (transitionState) {
			case TRANSITION_IDLE:
				break;
			case TRANSITION_INIT_IN_FINISHED:
				nextPlayer->prepareIn();
				currentPlayer->startTransition(false);
				transitionState = TRANSITION_PLAYING_IN;
				break;
			case TRANSITION_PLAYING_IN:
				if (currentPlayer->didTransitionEnd()) {
					previousPlayer = currentPlayer;
					currentPlayer = nextPlayer;
					midiTrack.setTexturesPlayer(currentPlayer);
					currentPlayer->startTransition(true);
					currentPlayer->update();
					nextPlayer = 0;
					transitionState = TRANSITION_PLAYING_OUT;
				}
				break;
			case TRANSITION_PLAYING_OUT:
				if (currentPlayer->didTransitionEnd()) {
					previousPlayer->finishOut();
					transitionState = TRANSITION_RELEASE_SET;
				}
				break;
			case TRANSITION_RELEASE_SET_FINISHED:
				transitionState = TRANSITION_INIT_SET;
				break;
			case TRANSITION_INIT_SET_FINISHED:
				currentPlayer->prepareSet();
				delete previousPlayer;
				previousPlayer = 0;
				midiTrack.releaseSoundSet();
				transitionState = TRANSITION_CHANGE_SOUND_SET;
				break;
			case TRANSITION_CHANGE_SOUND_SET_FINISHED:
				midiTrack.setupSoundSet();
				transitionState = TRANSITION_IDLE;
				break;
			default:
				break;
		
		}
	
	currentPlayer->update();
				
			
	
}

void PlayerController::translate() {
	if (!enable) 
		return;
	getTexturesPlayer()->translate();
}

void PlayerController::draw() {
	if (!enable) 
		return;
	getTexturesPlayer()->draw();
}

void PlayerController::setState(int state){
	if (!enable) 
		return;
	getTexturesPlayer()->setState(state);
	
}

float PlayerController::getScale(){
	if (!enable) 
		return 0.0;
	return getTexturesPlayer()->getScale();
	
}



void PlayerController::touchDown(float x, float y) {
	if (!enable) 
		return;
	
	int key = y/60;
	if (midiTrack.getMode() == MANUAL_MODE) 
		midiTrack.play(key);
	else if (midiTrack.getMode() == LOOP_MODE)
		midiTrack.changeLoop(key);
	
}

void PlayerController::keyPressed(int key) {
	if (!enable) 
		return;
	
	if (isInTransition()) 
		return;
	
	if (midiTrack.getMode() == MANUAL_MODE) 
		midiTrack.play(key);
	else if (midiTrack.getMode() == LOOP_MODE)
		midiTrack.changeLoop(key);
	
}


void PlayerController::exit() {
	//stopThread();
	if (!enable) 
		return;
	//for (vector<TexturesPlayer*>::iterator iter = videos.begin() ; iter!=videos.end();iter++)
	//	(*iter)->exit();
	currentPlayer->exit();
	
	midiTrack.exit();
}


TexturesPlayer *PlayerController::getTexturesPlayer() {
	return currentPlayer;
}

MidiTrack * PlayerController::getMidiTrack() {
	return &midiTrack;
}

bool PlayerController::isEnabled() {
	return enable;
}


/*
string PlayerController::getCurrentSet() {
	
	vector<TexturesPlayer*>::iterator iter = videos.begin();
	while (iter!=videos.end() && (*iter)!=currentPlayer) {
		iter++;
	}
	
	return distance(videos.begin(), iter);
	
	
}
 */

	


