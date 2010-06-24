#include "MidiTrack.h"
#include "ofxXmlSettings.h"
#include "TexturesPlayer.h"
#include "ofxRKAQSoundPlayer.h"

#include "ofMain.h"
#include "Constants.h"
#include <set>

int MidiTrack::currentTick;
int MidiTrack::loopTick;
int MidiTrack::startTime;
int MidiTrack::startTick;
float MidiTrack::ticksForMS;
int MidiTrack::songMode; 
int MidiTrack::bpm;

void MidiTrack::setup(int playerNum) {
	
	this->playerNum = playerNum;
	videoSet = "";
	
	mode = MANUAL_MODE;		
	
	midiInstrument = 0;
	
}



void MidiTrack::setTexturesPlayer(TexturesPlayer *texturesPlayer) {
	this->texturesPlayer = texturesPlayer;
}
 

void MidiTrack::releaseSoundSet() {
	midiInstrument->release();
	
}

string MidiTrack::getCurrentSoundSet() {
	return soundSet;
}
	
void  MidiTrack::loadSoundSet(string soundSet) {
	
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
		midiInstrument->unloadSounds();
		delete midiInstrument;
	}
	midiInstrument = new ofxRKAQSoundPlayer;
	
	
	int i;
	loops.clear();

	string path = ofToDataPath("SOUNDS/"+soundSet+"/"+prefix +"/"+prefix + "_");
	
	for (i=0; i<midiNotes.size();i++) {
		string soundname = path+ofToString(i+1) + ".caf";
		ofLog(OF_LOG_VERBOSE,"loading sound: %s",soundname.c_str());
		if (multi)
			midiInstrument->loadSound(soundname, midiNotes[i],127,chokeGroup.find(i)!=chokeGroup.end());
		else
			midiInstrument->loadSound(soundname, midiNotes[i],127);
		
		
	}
	
	for (i=0;i<8;i++) {
		string loopname =path+ofToString(i+1)+".xml";		
		
		loop newLoop;
		loops.push_back(newLoop);
		currentLoop=loops.begin()+i;
		ofLog(OF_LOG_VERBOSE,"loading loop %s(%i)",loopname.c_str(),i);
		loadLoop(loopname);
		if (!currentLoop->events.empty())
			loadLoopFinished();
	}
	
	changeLoop(0);
}


void MidiTrack::addEvent(int time,int note,int velocity) {
	event e;
	e.time = time;
	e.note = note; //(note-36)%24;
	e.velocity = velocity;
	currentLoop->events.push_back(e);
	
	//ofLog(OF_LOG_VERBOSE,"addEvent - time: %u, note: %u, velocity: %u",time,note,velocity);
}



void MidiTrack::loadLoopFinished() {
	
	int lastEvent = (currentLoop->events.end()-1)->time;
	
	int b[]={4,8,16,32,64};
	vector<int> barNums(b,b+5);
	vector<int>::iterator iter;
	for (iter = barNums.begin();iter!=barNums.end();iter++)
		if (lastEvent< 96*(*iter))
			break;
	
	if (iter==barNums.end())
		ofLog(OF_LOG_VERBOSE,"loadLoopFinished error - lastEvent: %u",lastEvent);
	else {
		currentLoop->numTicks = 96*(*iter);
		ofLog(OF_LOG_VERBOSE,"loadLoopFinished - numTicks: %u, lastEvent: %u",currentLoop->numTicks,lastEvent);
	}
	
}


void MidiTrack::setupSoundSet() {
	if (multi) 
		midiInstrument->init(8,true); 
	else
		midiInstrument->init(2,false); 
	
	currentTick = 0;
	lastPlayed = 0;
	
}





void MidiTrack::Init() {
	ticksForMS = 96 * 120 / 60000.0; // bpm = 60
	startTick = 0;
	bpm =120;
	ofxRKAQSoundPlayer::SetBPM(bpm,0);
	
}

int MidiTrack::GetSongMode() {
	return MidiTrack::songMode;
}


void MidiTrack::SetSongMode(int songMode) {
	MidiTrack::songMode = songMode;
	startTick = 0;
	startTime = ofGetElapsedTimeMillis();
	ofxRKAQSoundPlayer::Start();
	cout << "SetSongMode: " << songMode << "\n"; 
}

bool MidiTrack::isSongDone() {
	return songhead==song.end();
}
	
void MidiTrack::setupSong() {
	
	switch (songMode) {
		case SONG_PLAY:
			songhead = song.begin();
			break;
		case SONG_RECORD:
			song.clear();
			break;
	}
			
}



void MidiTrack::SetBPM(int bpmVal) {
	bpm = bpmVal;
	int currentTime = ofGetElapsedTimeMillis();
	int tick = startTick+(currentTime-startTime) * ticksForMS;
	
	ticksForMS = 96 * bpm / 60000.0;
	
	startTick= currentTick =  tick;
	startTime = currentTime;
	ofxRKAQSoundPlayer::SetBPM(bpm,currentTick);
	cout << "beatPerMinute: " << bpm << ", ticksForMS: " << ticksForMS << "\n";	
	
}

int MidiTrack::GetBPM() {
	return bpm;
}

void MidiTrack::UpdateTicks() {
		
	currentTick =  startTick+(ofGetElapsedTimeMillis()-startTime) * ticksForMS;
}




void  MidiTrack::setMode(int mode,bool reset) {
	if (!enable)
		return;
	
	this->mode =  mode;
	
	if (mode == LOOP_MODE) {
		if (reset) {
			playhead = currentLoop->events.begin();
			if (mode == LOOP_MODE) 
				while (playhead->time < 10) {
					texturesPlayer->play(midiToSample[playhead->note]);
					playMidi(loopTick+playhead->time,playhead->note,playhead->velocity);
					playhead++;
				}
		}
	
		seekPlayhead();
	}
	
	printf("change mode:  %i\n", mode);
}

void MidiTrack::changeLoop(int loopNum) {
	currentLoop = loops.begin()+loopNum;
	
	seekPlayhead();
}


int MidiTrack::getCurrentLoop() {
	return distance(loops.begin(), currentLoop);
}


void MidiTrack::seekPlayhead() {
	
	playhead = currentLoop->events.begin();
	
	if (mode==LOOP_MODE) {
		while (playhead!=currentLoop->events.end() && playhead->time - ticksForMS*100.0  <= (currentTick-loopTick) % currentLoop->numTicks   ) 
			playhead++;
		
		if (playhead==currentLoop->events.end())
			playhead = currentLoop->events.begin();
	}
}




void MidiTrack::update() {
	
	if (!enable)
		return;
	
	if (!animations.empty()) {
		// comment priorities - because giori set it with the ticks tricks
		/*  
		if (multi) {	
			int priority = 0;
			int note = 0;
			while (currentTick >= animations.front().first && !animations.empty()) {
				if (priorities[animations.front().second] > priority) {
					note = animations.front().second;
					priority = priorities[note];
				}
				animations.pop();
			}
			if (priority)
				texturesPlayer->play(note);
			
		} else */
			if (currentTick >= animations.front().first) {
				texturesPlayer->play(animations.front().second);
				animations.pop();
			}
	}
	
	if (mode == LOOP_MODE) {
		
		int tick = (currentTick-loopTick) % currentLoop->numTicks;
		if (playhead == currentLoop->events.end())
			printf(" MidiTrack::update error - reach currentLoop->events.end()\n");
		
		
		while (( playhead->time - tick + currentLoop->numTicks ) % currentLoop->numTicks < ticksForMS*100.0) {
			int playheadTick = currentTick - tick + playhead->time;
			int midiNote = (playhead->note-12) % 24;
			playheadTick+= playheadTick < currentTick ? currentLoop->numTicks : 0;
			
			//printf("note: %u, playhead: %u, tick: %u\n",playhead->note,playhead->time,tick);
					  
			if (songMode==SONG_RECORD) {
				event e;
				e.time = playheadTick;
				e.note = playhead->note + 36; // compensating for the -12 in the playback 
				e.velocity = playhead->velocity;
				song.push_back(e);
				cout << "record note: " << e.note << ", tick: " << e.time << "\n"; 
			}
				
			midiInstrument->queueNote(playheadTick, midiNote, playhead->velocity*volume);
			
			animations.push(make_pair(playheadTick, midiToSample[midiNote]));
			
			playhead++;
			if (playhead==currentLoop->events.end()) 
				playhead = currentLoop->events.begin();
		}
	}
	
	
	
	while (songMode == SONG_PLAY && songhead!=song.end() && songhead->time - currentTick < ticksForMS*100.0) {
		int midiNote = (songhead->note-12) % 24;
		printf("song note: %u, songhead: %u, tick: %u\n",midiNote,songhead->time,currentTick);
			
		midiInstrument->queueNote(songhead->time, midiNote, songhead->velocity*volume);
		animations.push(make_pair(songhead->time, midiToSample[midiNote]));
			
		songhead++;
	}
	
	
	
	midiInstrument->update();
}


void MidiTrack::playMidi(int time,int midiNote,int velocity) {
	
	if (songMode==SONG_RECORD) {
		event e;
		e.time = time;
		e.note = midiNote;
		e.velocity = velocity;
		song.push_back(e);
		//cout << "record note: " << e.note << ", tick: " << e.time << "\n"; 
	}
	
	midiInstrument->play(midiNote, velocity*volume);
	
}

void MidiTrack::play(int num) {
	if (!enable)
		return;
	
	int midi = keyToMidi[num];
	cout << "num: " << num << ", midi: " << midi <<endl;
	texturesPlayer->play(midiToSample[midi]);
	playMidi(currentTick,midi,127);
}





string MidiTrack::getCurrentVideoSet() {
	return videoSet;
}

void MidiTrack::exit() {
	midiInstrument->release();
	midiInstrument->unloadSounds();
	delete midiInstrument;
}	


int MidiTrack::getMode() {
	return mode;
}



void MidiTrack::setVolume(float volume) {
	this->volume = volume;
	//for (vector<sample*>::iterator iter = samples.begin(); iter<samples.end();iter++) 
//		(*iter)->sound->volume = volume;
}

float MidiTrack::getVolume() {
	return volume;
}

void MidiTrack::addMidiToXML(ofxXmlSettings *xml) {
	for (vector<event>::iterator iter = song.begin() ; iter!=song.end() ; iter++) {
		int which = xml->addTag("Event");
		xml->pushTag("Event", which);
		xml->addValue("Absolute", iter->time);
		xml->addTag("NoteOn");
		xml->addAttribute("NoteOn", "Channel", 1,0);
		xml->addAttribute("NoteOn", "Note", iter->note,0);
		xml->addAttribute("NoteOn", "Velocity", iter->velocity,0);
		xml->popTag();
	}
}

