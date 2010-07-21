#include "ofMain.h"
#include "SimplePlayer.h"
#include "FramesDrivenPlayer.h"

#include "PlayerController.h"
#include "ofxXmlSettings.h"
#include "Constants.h"
#include "ofxMidiInstrument.h"


PlayerController::PlayerController() {
	transitionState = TRANSITION_IDLE;
	enable = false;
	
};

void PlayerController::setup(int playerNum) {
	enable = true;	
	this->playerNum = playerNum;
	
	
	
	mode = MANUAL_MODE;	
	
	
		
	currentPlayer = 0;
	midiInstrument = 0;
	midiTrack.setup();
	songMode = SONG_IDLE;
	song.setup();
	//midiTrack = 0;
	
}


void  PlayerController::loadSoundSet(string soundSet) {
	
	//enable =  xml.getValue("enable", "true",0) == "true";
	
	this->soundSet = soundSet;
	ofxXmlSettings xml;
	string xmlpath = "SOUNDS/"+soundSet+"/"+soundSet+".xml";
	bool loaded = xml.loadFile(xmlpath);
	ofLog(OF_LOG_VERBOSE,"loading of %s %s",xmlpath.c_str(),loaded ? "succeeded" : "failed");
	enable = true;
	if (!loaded) {
		enable = false;
		return;
	}
	
	xml.pushTag("sound_set");
	xml.pushTag("player", playerNum);
	videoSet=	xml.getValue("video","");
	
	
	xml.pushTag("sound");
	
	multi = xml.tagExists("multi");
	prefix = xml.getValue("id","");
	volume = xml.getValue("volume", 1.0f);
	
	ofLog(OF_LOG_VERBOSE,"loading set %s (%s)",soundSet.c_str(),prefix.c_str());
	
	vector<int> midiNotes;
	
	if (xml.tagExists("notes")) {
		xml.pushTag("notes");
		for (int i=0; i<xml.getNumTags("note");i++) {
			int midi = (xml.getAttribute("note", "midi", 0, i) -12) % 24 ;// ("note", 0, i)-36) % 24;
			
			int sample = xml.getAttribute("note", "sample", 0, i)-1;
			midiToSample[midi] = sample;
			
			int key = xml.getAttribute("note", "key", 0, i);
			if (key)
				keyToMidi[key-1] = midi;
			
			midiNotes.push_back(midi);
			
			//ofLog(OF_LOG_VERBOSE,"parsing note %d: midi=%d, video=%d, key=%d",i,midi,video,key);
			
		}
		xml.popTag();
	}
	
	// ticks trick
	/*
	 if (multi && xml.tagExists("priorities")) {
	 xml.pushTag("priorities");
	 for (int i=0;i<xml.getNumTags("priority");i++)
	 priorities.push_back(xml.getValue("priority",0,i)); 
	 xml.popTag();
	 }
	 */
	
	set<int> chokeGroup;
	if (multi && xml.tagExists("choke_group")) {
		xml.pushTag("choke_group");
		for (int i=0;i<xml.getNumTags("note");i++) 
			chokeGroup.insert(xml.getValue("note", 0, i)-1); // -1 because in the xml we start from 1
		xml.popTag();
	}
	
	
	xml.popTag();
	xml.popTag();
	xml.popTag();
	
	
	if (midiInstrument) {
		midiInstrument->exit();
		delete midiInstrument;
	}
	midiInstrument = new ofxMidiInstrument;
	
	
	int i;
	//loops.clear();
	
	string path = "SOUNDS/"+soundSet+"/"+prefix +"/"+prefix + "_";
	
	for (i=0; i<midiNotes.size();i++) {
		string soundname = path+ofToString(i+1) + ".aif";
		ofLog(OF_LOG_VERBOSE,"loading sound: %s, map to midiNote: %i",soundname.c_str(),midiNotes[i]);
		
		midiInstrument->loadSample(ofToDataPath(soundname), midiNotes[i]); // TODO: add choke mechanics
		
		
		/*
		 if (multi)
		 midiInstrument->loadSound(soundname, midiNotes[i],127,chokeGroup.find(i)!=chokeGroup.end());
		 else
		 midiInstrument->loadSound(soundname, midiNotes[i],127);
		 */
		
	}
	
	midiInstrument->setup(256, 44100); // TODO: move these out
	
	midiTrack.clear();
	
	
	string pathPrefix = ofToDataPath(path);
	ofDisableDataPath(); // ofxXmlSettings uses ofToDataPath();
	for (i=0;i<8;i++) {
		midiTrack.loadLoop(pathPrefix+ofToString(i+1)+".xml");
	}
	ofEnableDataPath();
	
	midiTrack.play();
	
	currentLoop = 0;
	
	loadDemo();
	//midiTrack->playLoop(currentLoop);
	
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
	
	if (loaded) { // TODO: if not ?
		xml.pushTag("sound_set");
		xml.pushTag("player", playerNum);
		bFramesDriverPlayer = xml.getAttribute("video", "lips", 0, 0);
		subSoundSet = xml.getValue("sound:id", "", 0);
		nextVideoSet =	xml.getValue("video","");
		xml.popTag();
		xml.popTag();
	}
	
	ofLog(OF_LOG_VERBOSE,"loading of %s %s - using video: %s",xmlpath.c_str(),loaded ? "succeeded" : "failed",videoSet.c_str());
	
	if (nextVideoSet!=videoSet) {
		if (playerNum == 1) //  && videoSet == "VOC_CORE"
			nextPlayer = new FramesDrivenPlayer("SOUNDS/"+soundSet,subSoundSet);
		else
			nextPlayer = new SimplePlayer;
		
		nextPlayer->setup(nextVideoSet);
		
	}
	
	
	
	if (bFirstTime) {
		
		currentPlayer = nextPlayer;
		nextPlayer = 0;
		
		transitionState = TRANSITION_SETUP;
		while (transitionState != TRANSITION_IDLE);
		
		currentPlayer->prepareIn();
		currentPlayer->prepareSet();
		
		//midiTrack.setupSoundSet();
		
		
		//midiTrack.setTexturesPlayer(currentPlayer);
		
	} else if (/*getMidiTrack()->getCurrentSet()!=setNum &&*/ !isInTransition()) {
		midiTrack.pause();
		
		if (nextVideoSet!=videoSet) {
			
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
			loadSoundSet(soundSet);
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
			loadSoundSet(soundSet);
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
					//midiTrack.setTexturesPlayer(currentPlayer);
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
				videoSet = nextVideoSet;
				//midiTrack->exit(); // done in loadSoundSet
				//midiTrack.releaseSoundSet();
				transitionState = TRANSITION_CHANGE_SOUND_SET;
				break;
			case TRANSITION_CHANGE_SOUND_SET_FINISHED:
				midiTrack.play();
				//midiTrack.setupSoundSet(); // done in loadSoundSet
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






void PlayerController::play(int num) {
	if (!enable) 
		return;
	
	if (mode == MANUAL_MODE) {
		if (playerNum != 2) {
			midiInstrument->noteOffAll();
		}
		int midi = keyToMidi[num];
		cout << "num: " << num << ", midi: " << midi <<endl;
		currentPlayer->play(midiToSample[midi]);
		
		
		/* TODO: song record
		 if (songMode==SONG_RECORD) {
		 event e;
		 e.time = time;
		 e.note = midi;
		 e.velocity = 127;
		 song.push_back(e);
		 //cout << "record note: " << e.note << ", tick: " << e.time << "\n"; 
		 }
		 */
		
		midiInstrument->noteOn(midi, 127*volume);
		
		
	}
	else if (mode == LOOP_MODE)
		midiTrack.playLoop(num);
	
}

/*
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
 */


void PlayerController::exit() {
	//stopThread();
	if (!enable) 
		return;
	//for (vector<TexturesPlayer*>::iterator iter = videos.begin() ; iter!=videos.end();iter++)
	//	(*iter)->exit();
	currentPlayer->exit();
	
	midiTrack.clear();
}


TexturesPlayer *PlayerController::getTexturesPlayer() {
	return currentPlayer;
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

int PlayerController::getSongMode() {
	return songMode;
}


void PlayerController::setSongMode(int songMode) {
	this->songMode = songMode;
	//startTick = 0;
	//startTime = ofGetElapsedTimeMillis();
	//ofxRKAQSoundPlayer::Start();
	cout << "SetSongMode: " << songMode << "\n"; 
}
	
void PlayerController::sync() {
	if (!enable)
		return;
	midiTrack.sync();
}

void  PlayerController::setMode(int mode) { // 
	if (!enable)
		return;
	
	this->mode =  mode; 
	
	switch (mode) {
		case LOOP_MODE:
			midiTrack.playLoop(currentLoop);
			break;
		case MANUAL_MODE:
			midiTrack.stopLoop();
			break;
		default:
			break;
	}
	
	printf("change mode:  %i\n", mode);
}


int  PlayerController::getMode() { 
	return mode;
}

void PlayerController::changeLoop(int loopNum) {
	currentLoop = loopNum;
	midiTrack.playLoop(currentLoop);
}

int PlayerController::getCurrentLoop() {
	return currentLoop;
}

void PlayerController::processWithBlocks(float *left,float *right) {
	vector<event> events;
	midiTrack.process(events);
	for (vector<event>::iterator iter=events.begin(); iter!=events.end(); iter++) {
		int note = (iter->note - 12) % 24;
		//printf("loop note:  %i\n", note);
		if (iter->bNoteOn) {
			midiInstrument->noteOn(note, iter->velocity*volume);
			currentPlayer->play(midiToSample[note]); // TODO: manage animations for multi player (drum)
		}
						 
		else {
			if (playerNum!=2) {
				midiInstrument->noteOff(note);
			}
		}
	}
	
	events.clear();
	
	switch (songMode) {
		case SONG_PLAY: {
			song.process(events);
			for (vector<event>::iterator iter=events.begin(); iter!=events.end(); iter++) {
				int note = (iter->note - 12) % 24;
				//printf("loop note:  %i\n", note);
				if (iter->bNoteOn) {
					midiInstrument->noteOn(note, iter->velocity*volume);
					currentPlayer->play(midiToSample[note]); // TODO: manage animations for multi player (drum)
				}
				
				else {
					if (playerNum!=2) {
						midiInstrument->noteOff(note);
					}
				}
			}
		} break;
		default:
			break;
	}
	midiInstrument->preProcess();
	midiInstrument->mixWithBlocks(left,right);
	midiInstrument->postProcess();
	
}


void PlayerController::setVolume(float volume) {
	this->volume = volume;
}

float PlayerController::getVolume() {
	return volume;
}

void PlayerController::setBPM(int bpmVal) {
	midiTrack.setBPM(bpmVal);
	song.setBPM(bpmVal);
}


void PlayerController::loadSong(string filename) {
	ofDisableDataPath();
	song.loadTrack(filename);
	ofEnableDataPath();
}

void PlayerController::loadDemo() {
	loadSong(ofToDataPath("SOUNDS/"+soundSet+"/"+prefix +"/"+prefix + "_SONG.xml"));
}

void PlayerController::playSong() {
	setMode(MANUAL_MODE);
	songMode = SONG_PLAY;
	song.play();
}

void PlayerController::stopSong() {
	songMode = SONG_IDLE;
	song.stop();
}

bool PlayerController::getIsPlaying() {
	return song.getIsPlaying();
}


