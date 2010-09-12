#include "ofMain.h"
#include "SimplePlayer.h"
#include "FramesDrivenPlayer.h"

#include "PlayerController.h"
#include "ofxXmlSettings.h"
#include "Constants.h"
#include "ofxMidiInstrument.h"

enum {
	TRANSITION_CHANGE_SOUND_SET,
	TRANSITION_LOAD_SONG,
	TRANSITION_CHANGE_SOUND_SET_FINISHED,
	TRANSITION_UNLOAD_SET,
	TRANSITION_UNLOAD_SET_FINISHED,
	TRANSITION_LOAD_SET,
	TRANSITION_LOAD_SET_FINISHED,
	TRANSITION_BEFORE_IDLE,
	TRANSITION_IDLE,
	TRANSITION_RELEASE_SET,
	TRANSITION_RELEASE_SET_FINISHED,
	TRANSITION_INIT_IN_OUT,
	TRANSITION_INIT_IN_OUT_FINISHED,
	TRANSITION_PLAYING_OUT,
	TRANSITION_PLAYING_IN,
	TRANSITION_INIT_SET,
	TRANSITION_INIT_SET_FINISHED
	
};


PlayerController::PlayerController() {
	transitionState = TRANSITION_IDLE;
	enable = false;
	bVisible = false;
	
	currentPlayer = 0;
	videoSet = "";
	
};

void PlayerController::setup(int playerNum) {
	
	this->playerNum = playerNum;
	
	mode = MANUAL_MODE;	
			
	midiInstrument = 0;
	looper.setup();
	songState = SONG_IDLE;
	song.setup();
	//looper = 0;
	
}


void  PlayerController::loadSet(string soundSet,string songName){
	
	
	bAnimatedTransition = false;
	
	this->songName = songName;
	
		
	if (getCurrentSoundSet() == soundSet) {
		transitionState = TRANSITION_LOAD_SONG;
	} else {
		this->soundSet = soundSet;
		transitionState = TRANSITION_CHANGE_SOUND_SET;
	}

}

void PlayerController::changeSet(string soundSet) {
	
	
	
	if (isInTransition() || soundSet == this->soundSet) {
		return;
	}
	this->soundSet = soundSet;
	bAnimatedTransition = true;
		
	transitionState = TRANSITION_CHANGE_SOUND_SET;
}

void PlayerController::loadSong() {
	if (songName!="") { 
		ofDisableDataPath();
		song.loadTrack(songName);
		ofEnableDataPath();
		
		
	} else {
		song.loadTrack("SOUNDS/"+soundSet +"/"+soundSet + "_SONG.xml");
	}
	
}

void  PlayerController::loadSoundSet() {
	
	
		
	
	
	int start = ofGetElapsedTimeMillis();
	progress = 0.0f;
	ofLog(OF_LOG_VERBOSE,"loadSoundSet: %s",soundSet.c_str());
	
	this->soundSet = soundSet;
	
	string path = "SOUNDS/"+soundSet+"/"+soundSet;
	
	ofxXmlSettings xml;
	string xmlpath = path+".xml";
	bool loaded = xml.loadFile(xmlpath);
	ofLog(OF_LOG_VERBOSE,"xml loading %s",loaded ? "succeeded" : "failed");
	assert(loaded);
	
	
	xml.pushTag("sound_set");
	bFramesDriverPlayer = xml.getAttribute("video", "lips", 0, 0);
	nextVideoSet =	xml.getValue("video","");
	
	//ofLog(OF_LOG_VERBOSE,"using video: %s",nextVideoSet.c_str());
	
	bMulti = xml.tagExists("multi");
	volume = xml.getValue("volume", 1.0f);
	
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
	if (bMulti && xml.tagExists("choke_group")) {
		xml.pushTag("choke_group");
		for (int i=0;i<xml.getNumTags("note");i++) 
			chokeGroup.insert(xml.getValue("note", 0, i)-1); // -1 because in the xml we start from 1
		xml.popTag();
	}
	
	
	
	xml.popTag(); // sound_set
	
	
	
	if (midiInstrument) {
		midiInstrument->exit();
		delete midiInstrument;
	}
	midiInstrument = new ofxMidiInstrument;
	
	
	int i;
	//loops.clear();
	
	for (i=0; i<midiNotes.size();i++) {
		string soundname = path+"_"+ofToString(i+1) + ".aif";
		//ofLog(OF_LOG_VERBOSE,"loading sound: %s, map to midiNote: %i",soundname.c_str(),midiNotes[i]);
		
		if (bMulti)
			midiInstrument->loadSample(ofToDataPath(soundname), midiNotes[i],chokeGroup.find(i)!=chokeGroup.end());
		else
			midiInstrument->loadSample(ofToDataPath(soundname), midiNotes[i]);
		
	}
	
	midiInstrument->setup(256, 44100); // TODO: move these out
	
	looper.clear();
	
	
	string pathPrefix = ofToDataPath(path);
	ofDisableDataPath(); // ofxXmlSettings uses ofToDataPath();
	for (i=0;i<8;i++) {
		looper.loadLoop(pathPrefix+"_"+ofToString(i+1)+".xml");
	}
	ofEnableDataPath();
	
	currentLoop = 0;
	
	//looper->playLoop(currentLoop);
	
	
	
	ofLog(OF_LOG_VERBOSE,"loadSoundSet finished: %i [ms]",ofGetElapsedTimeMillis()-start);
	
}



TexturesPlayer *PlayerController::createTexturePlayer(string soundSet,string videoSet) {
	TexturesPlayer *player;
	
	if (playerNum == 1) //  && videoSet == "VOC_CORE"
		player = new FramesDrivenPlayer(soundSet);
	else
		player = new SimplePlayer;
	
	player->setup(videoSet);
	return player;
}







string PlayerController::getCurrentSoundSet() {
	return soundSet;
}


bool PlayerController::isInTransition() {
	
	return transitionState != TRANSITION_IDLE;
}

void PlayerController::threadedFunction() {
	
	
	if (!bAnimatedTransition) {
		switch (transitionState) {
			case TRANSITION_CHANGE_SOUND_SET:
				looper.pause();
				loadSoundSet();
				transitionState = TRANSITION_LOAD_SONG;
				break;
				
			case TRANSITION_LOAD_SONG:
				loadSong();
				transitionState = TRANSITION_CHANGE_SOUND_SET_FINISHED; 
				break;


			case TRANSITION_UNLOAD_SET:
				previousPlayer->release();
				delete previousPlayer;
				previousPlayer = 0;
				transitionState = TRANSITION_UNLOAD_SET_FINISHED;
				break;

			case TRANSITION_LOAD_SET:
				
				nextPlayer = createTexturePlayer(soundSet, nextVideoSet);
				nextPlayer->initIdle();
				nextPlayer->initSet();
				transitionState = TRANSITION_LOAD_SET_FINISHED;
				break;
			case TRANSITION_BEFORE_IDLE:
				looper.play();
				enable = true;
				transitionState = TRANSITION_IDLE;
				break;

		}
	} else {
		switch (transitionState) {
			case TRANSITION_CHANGE_SOUND_SET:
				looper.pause();
				loadSoundSet();
				
				transitionState = TRANSITION_LOAD_SONG;
				break;
			case TRANSITION_LOAD_SONG:
				song.clear();
				transitionState = TRANSITION_CHANGE_SOUND_SET_FINISHED; 
				break;
			case TRANSITION_INIT_IN_OUT:
				currentPlayer->initOut();
				nextPlayer = createTexturePlayer(soundSet, nextVideoSet);
				nextPlayer->initIn();
				nextPlayer->initIdle();
				transitionState = TRANSITION_INIT_IN_OUT_FINISHED;
				break;
			case TRANSITION_RELEASE_SET: 
				previousPlayer->release();
				delete previousPlayer;
				previousPlayer = 0;
				transitionState = TRANSITION_RELEASE_SET_FINISHED;
				break;
			case TRANSITION_INIT_SET:
				currentPlayer->initSet();
				transitionState = TRANSITION_INIT_SET_FINISHED;
				break;
			case TRANSITION_BEFORE_IDLE:
				looper.play();
				enable = true;
				transitionState = TRANSITION_IDLE;
				break;
				
			
		}
		
	}
	
	
}
	
float PlayerController::getProgress() {
//	if (nextPlayer) {
//		progress = nextPlayer->getProgress();
//	}
	
	float progress;
	if (isInTransition()) {
		progress = transitionState;
		if (transitionState == TRANSITION_LOAD_SONG) {
			progress+=song.getProgress();
		}
		progress/=(float)TRANSITION_IDLE;
	} else {
		progress = 1.0f;
	}

	
	return  progress;
}

float PlayerController::getPlayhead() {
	//	if (nextPlayer) {
	//		progress = nextPlayer->getProgress();
	//	}
	return songState == SONG_PLAY || songState == SONG_RENDER_AUDIO || songState == SONG_RENDER_VIDEO ? song.getPlayhead() : 0.0f;
}

	
void PlayerController::update() {
	
	
	if (!bAnimatedTransition) {
		switch (transitionState) {
			case TRANSITION_CHANGE_SOUND_SET_FINISHED:
				if (nextVideoSet!=videoSet) {
					if (currentPlayer) {
						previousPlayer = currentPlayer;
						currentPlayer = 0;
						previousPlayer->unloadIdle();
						previousPlayer->unloadSet();
						transitionState = TRANSITION_UNLOAD_SET;

					} else {
						transitionState = TRANSITION_LOAD_SET;
					}
				}
				else {
					transitionState = TRANSITION_BEFORE_IDLE;
					
				}
				break;
			case TRANSITION_UNLOAD_SET_FINISHED:
				
				transitionState = TRANSITION_LOAD_SET;
				break;
			case TRANSITION_LOAD_SET_FINISHED:
				nextPlayer->loadIdle();
				nextPlayer->loadSet();
				currentPlayer = nextPlayer;
				nextPlayer = 0;
				progress = 1.0f;
				transitionState = TRANSITION_BEFORE_IDLE;
				
				break;
			
		}
		
	} else {
		switch (transitionState) {
			case TRANSITION_CHANGE_SOUND_SET_FINISHED:
				
				if (nextVideoSet!=videoSet) {
					transitionState = TRANSITION_INIT_IN_OUT;
				}
				else {
					transitionState = TRANSITION_BEFORE_IDLE;
				}
				break;
			case TRANSITION_INIT_IN_OUT_FINISHED:
				nextPlayer->loadIn();
				nextPlayer->loadIdle();
				currentPlayer->loadOut();
				currentPlayer->startTransition(false);
				transitionState = TRANSITION_PLAYING_IN;
				break;
			case TRANSITION_PLAYING_IN:
				if (currentPlayer->didTransitionEnd()) {
					previousPlayer = currentPlayer;
					currentPlayer = nextPlayer;
					currentPlayer->startTransition(true);
					//currentPlayer->update(); // TODO: do i need it ?
					nextPlayer = 0;
					transitionState = TRANSITION_PLAYING_OUT;
				}
				break;
			case TRANSITION_PLAYING_OUT:
				if (currentPlayer->didTransitionEnd()) {
					previousPlayer->unloadOut();
					previousPlayer->unloadIdle();
					previousPlayer->unloadSet();
					currentPlayer->unloadIn();
					transitionState = TRANSITION_RELEASE_SET;
				}
				break;
			case TRANSITION_RELEASE_SET_FINISHED:
				transitionState = TRANSITION_INIT_SET;
				break;
			case TRANSITION_INIT_SET_FINISHED:
				
				currentPlayer->loadSet();
				
				videoSet = nextVideoSet;
				transitionState = TRANSITION_BEFORE_IDLE;
				break;
			
			default:
				break;
				
		}
		
	}
	
	
	if (currentPlayer) {
		currentPlayer->update();
	}
	
	
				
			
	
}

void PlayerController::translate() {
	if (currentPlayer) 
		currentPlayer->translate();
}

void PlayerController::draw() {
	if (currentPlayer) 
		currentPlayer->draw();
}


void PlayerController::setPush(bool bPush) {

	if (currentPlayer) 
		currentPlayer->setPush(bPush);
}


void PlayerController::setState(int state){
	if (currentPlayer) 
		currentPlayer->setState(state);
}

float PlayerController::getScale(){
	return currentPlayer ? currentPlayer->getScale() : 0.0;
}






void PlayerController::play(int num) {
	if (isInTransition()) 
		return;
	
	if (mode == MANUAL_MODE) {
		
		int midi = keyToMidi[num];
		cout << "num: " << num << ", midi: " << midi <<endl;
		currentPlayer->play(midiToSample[midi]);
		
		
		if (!bMulti) // ROIKR: for non drummer, stop all notes on trigger
			midiInstrument->noteOffAll();
		
		midiInstrument->noteOn(midi, 127*volume);
		
		if (songState==SONG_RECORD) { //TODO: get current playing note from midi instrument...
			event e;
			e.channel = 1;
			e.note = midi+12; // when playing we substract 12
			e.velocity = 127;
			e.bNoteOn = true;
			recordEvents.push_back(e);
			//cout << "record note: " << e.note << ", tick: " << e.time << "\n"; 
		}
		
		
	}
	else if (mode == LOOP_MODE)
		looper.playLoop(num);
	
}

/*
void PlayerController::keyPressed(int key) {
	if (!enable) 
		return;
	
	if (isInTransition()) 
		return;
	
	if (looper.getMode() == MANUAL_MODE) 
		looper.play(key);
	else if (looper.getMode() == LOOP_MODE)
		looper.changeLoop(key);
	
}
 */


void PlayerController::exit() {
	//stopThread();
	if (!enable) 
		return;
	//for (vector<TexturesPlayer*>::iterator iter = videos.begin() ; iter!=videos.end();iter++)
	//	(*iter)->exit();
	currentPlayer->exit();
	
	looper.clear();
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

	
void PlayerController::sync() {
	
	looper.sync();
}

void  PlayerController::setMode(int mode) { // 
	
	
	this->mode =  mode; 
	
	switch (mode) {
		case LOOP_MODE:
			looper.playLoop(currentLoop);
			break;
		case MANUAL_MODE:
			looper.stopLoop();
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
	looper.playLoop(currentLoop);
//	if (bMulti) {
//		midiInstrument->noteOffAll();
//	}
}

int PlayerController::getCurrentLoop() {
	return currentLoop;
}

void PlayerController::processWithBlocks(float *left,float *right) {
	if (!enable) {
		return;
	}
	
	
	vector<event> events;
	looper.process(events);
	
	if (isInTransition()) {
		return;
	}
	
	// if it is not the drummer, we should stop other notes on each note on
	if (!bMulti) { 
		for (vector<event>::iterator iter=events.begin(); iter!=events.end(); iter++) {
			if (iter->bNoteOn) { // if there is note on, we can stop all other notes
				midiInstrument->noteOffAll();
				break;
			} else { // otherwise, stop only those who note off
				int note = (iter->note - 12) % 24;
				midiInstrument->noteOff(note);
			}
		}
	}
	
	for (vector<event>::iterator iter=events.begin(); iter!=events.end(); iter++) {
		int note = (iter->note - 12) % 24;
		cout << "tick: " << iter->absolute << endl; // DEBUG
		if (iter->bNoteOn) {
			midiInstrument->noteOn(note, iter->velocity*volume);
			currentPlayer->play(midiToSample[note]); // TODO: manage animations for multi player (drum)
		}
	}
	
	
	
	switch (songState) {
		case SONG_PLAY:
		case SONG_RENDER_AUDIO: 
		case SONG_RENDER_VIDEO: {
			events.clear();
			song.process(events);
			
			if (!bMulti && songState!=SONG_RENDER_VIDEO) { 
				for (vector<event>::iterator iter=events.begin(); iter!=events.end(); iter++) {
					if (iter->bNoteOn) { // if there is note on, we can stop all other notes
						midiInstrument->noteOffAll();
						break;
					} else { // otherwise, stop only those who note off
						int note = (iter->note - 12) % 24;
						midiInstrument->noteOff(note);
					}
				}
			}
			
			for (vector<event>::iterator iter=events.begin(); iter!=events.end(); iter++) {
				int note = (iter->note - 12) % 24;
				//printf("loop note:  %i\n", note);
				if (iter->bNoteOn) {
					midiInstrument->noteOn(note, iter->velocity*volume);
					
					if (songState!=SONG_RENDER_AUDIO) {
						currentPlayer->play(midiToSample[note]); // TODO: manage animations for multi player (drum)
					}
					
				}
			}
		} break;
		case SONG_RECORD: {
			for (vector<event>::iterator iter=recordEvents.begin(); iter!=recordEvents.end(); iter++) {
				cout << "record note: " << iter->note << endl; 
				events.push_back(*iter);
			}
			
			song.process(events); // add events from loops :-)
		} break;
			
		 
			
		default:
			break;
	}
	
	midiInstrument->preProcess();
	midiInstrument->mixWithBlocks(left,right);
	midiInstrument->postProcess();
	
	
	
	recordEvents.clear(); // TODO: is it safe ?
	
}


void PlayerController::setVolume(float volume) {
	this->volume = volume;
}

float PlayerController::getVolume() {
	return volume;
}

void PlayerController::setBPM(int bpmVal) {
	looper.setBPM(bpmVal);
	song.setBPM(bpmVal);
}


void PlayerController::setSongState(int songState) {
	
	switch (songState) {
		case SONG_IDLE:
			song.stop();
			setMode(MANUAL_MODE);
			break;
		case SONG_TRIGGER_RECORD:
			song.stop();
			break;
		case SONG_PLAY:
		case SONG_RENDER_AUDIO:
		case SONG_RENDER_VIDEO:
			setMode(MANUAL_MODE);
			song.play();
			break;
		case SONG_RECORD:
			song.record();
			break;
		
			

		default:
			break;
	}
	this->songState = songState;
}

int  PlayerController::getSongState() {
	return songState;
}

bool PlayerController::getIsRecording() {
	return song.getIsRecording() || midiInstrument->getIsPlaying();
}

bool PlayerController::getIsPlaying() {
	return song.getIsPlaying() || midiInstrument->getIsPlaying();
}



void PlayerController::saveSong(string filename) {
	song.saveTrack(filename);
}


