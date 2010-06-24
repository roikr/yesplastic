#include "MidiTrack.h"
#include "ofxXmlSettings.h"
#include "TexturesPlayer.h"


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

void MidiTrack::setup(ofxXmlSettings *xml,int setNum) {
	
	
	this->xml = xml;
	enable =  xml->getValue("enable", "true",0) == "true";
	
	if (!enable)
		return;
	
	id = xml->getValue("id","");
	multi = xml->tagExists("multi");
	prefix = xml->getValue("prefix","");
	volume = xml->getValue("volume", 1.0f);
	
	if (xml->tagExists("midi_notes")) {
		xml->pushTag("midi_notes");
		for (int i=0; i<xml->getNumTags("midi_note");i++) {
			int midiNote = (xml->getValue("midi_note", 0, i)-36) % 24;
			midiNotes.push_back(midiNote);
			midiNotesMap[midiNote]=i;
		}
		xml->popTag();
	}
	
	if (multi && xml->tagExists("priorities")) {
		xml->pushTag("priorities");
		for (int i=0;i<xml->getNumTags("priority");i++)
			priorities.push_back(xml->getValue("priority",0,i));
		xml->popTag();
	}
			
								
								
	mode = MANUAL_MODE;		
	
	midiInstrument = 0;
	
}



void MidiTrack::setTexturesPlayer(TexturesPlayer *texturesPlayer) {
	this->texturesPlayer = texturesPlayer;
}
 

void MidiTrack::releaseSoundSet() {
	
	
}

int MidiTrack::getCurrentSet() {
	return setNum;
}
	
void  MidiTrack::loadSoundSet(int setNum) {
	this->setNum = setNum;
	
	xml->pushTag("dead", 0);
	xml->pushTag(id,0);
	
	set<int> chokeGroup;
	if (multi && xml->tagExists("choke_group")) {
		xml->pushTag("choke_group");
		for (int i=0;i<xml->getNumTags("note");i++) 
			chokeGroup.insert(xml->getValue("note", 0, i));
		xml->popTag();
	}
	
	xml->pushTag("sound_set",setNum);
	
	setName = xml->getValue("id","");
	
	
	
	ofLog(OF_LOG_VERBOSE,"loading set %s(%i)",setName.c_str(),setNum);
	videoSetName = xml->getValue("video","");
	
	xml->popTag();
	xml->popTag();
	xml->popTag();
	
	
	
	
	
	int i;
	loops.clear();

	string path = ofToDataPath("SOUNDS/"+prefix+"_"+setName+"/"+prefix+"_"+setName + "_");
	
	for (i=0; i<8;i++) {
		string soundname = path+ofToString(i+1) + ".caf";
		ofLog(OF_LOG_VERBOSE,"loading sound: %s",soundname.c_str());
		
		
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
	e.note = (note-36)%24;
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
		
	currentTick = 0;
	lastPlayed = 0;
	
}





void MidiTrack::Init() {
	ticksForMS = 96 * 120 / 60000.0; // bpm = 60
	startTick = 0;
	bpm =120;
		
}

void MidiTrack::SetSongMode(int songMode) {
	MidiTrack::songMode = songMode;
	startTick = 0;
	startTime = ofGetElapsedTimeMillis();
	
	cout << "SetSongMode: " << songMode << "\n"; 
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
					texturesPlayer->play(midiNotesMap[playhead->note]);
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
			
		} else
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
			playheadTick+= playheadTick < currentTick ? currentLoop->numTicks : 0;
			
			printf("note: %u, playhead: %u, tick: %u\n",playhead->note,playhead->time,tick);
					  
			if (songMode==SONG_RECORD) {
				event e;
				e.time = playheadTick;
				e.note = playhead->note;
				e.velocity = playhead->velocity;
				song.push_back(e);
				cout << "record note: " << e.note << ", tick: " << e.time << "\n"; 
			}
				
			
			animations.push(make_pair(playheadTick, midiNotesMap[playhead->note]));
			
			playhead++;
			if (playhead==currentLoop->events.end()) 
				playhead = currentLoop->events.begin();
		}
	}
	
	
	while (songMode == SONG_PLAY && songhead!=song.end() && songhead->time - currentTick < ticksForMS*100.0) {
		printf("song note: %u, songhead: %u, tick: %u\n",songhead->note,songhead->time,currentTick);
			
		animations.push(make_pair(songhead->time, midiNotesMap[songhead->note]));
			
		songhead++;
	}
	
	
}


void MidiTrack::playMidi(int time,int midiNote,int velocity) {
	if (songMode==SONG_RECORD) {
		event e;
		e.time = time;
		e.note = midiNote;
		e.velocity = velocity;
		song.push_back(e);
		cout << "record note: " << e.note << ", tick: " << e.time << "\n"; 
	}
	
	
	
}

void MidiTrack::play(int num) {
	if (!enable)
		return;
	
	texturesPlayer->play(num);
	playMidi(currentTick,midiNotes[num],127);
}

string MidiTrack::getVideoSetName() {
	return videoSetName;
}

void MidiTrack::exit() {
	
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

