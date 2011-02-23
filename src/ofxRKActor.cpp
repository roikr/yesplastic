#include "ofxRKActor.h"
#include "ofxRKSequence.h"

#include "ofxXmlSettings.h"

void ofxRKActor::setup(ofxXmlSettings *xml,string path) {
	
	for (int i=0; i<xml->getNumTags("sequence"); i++) {
		ofxRKSequence *seq = new ofxRKSequence();
		seq->setup(xml, i,path);
		sequences.push_back(seq);
		string prefix = xml->getAttribute("sequence", "prefix", "", i);
		sequencesMap[prefix] = i;
		sequencesNames.push_back(prefix);
	}
	
	iter = sequences.begin();
	bPlaying = false;
}

void ofxRKActor::init(int seq) {
	sequences.at(seq)->init();
}

void ofxRKActor::load(int seq) {
	sequences.at(seq)->load();
}

void ofxRKActor::unloadSequence(int seq) {
	sequences.at(seq)->unload();
}

void ofxRKActor::releaseSequence(int seq) {
	sequences.at(seq)->release();
}

void ofxRKActor::release() {
	for (vector<ofxRKSequence*>::iterator iter  = sequences.begin() ; iter != sequences.end(); iter++)
		(*iter)->release();
	sequences.clear();
}


//void ofxRKActor::exit() {
//	for (vector<ofxRKSequence*>::iterator iter  = sequences.begin() ; iter != sequences.end(); iter++)
//		(*iter)->release();
//}

void ofxRKActor::update() {
	if (!bPlaying) 
		return;
	
	if (bStartSequence) {
		bStartSequence = false;
	} else if (!getIsSequenceDone()) 
		(*iter)->nextFrame();
}



void ofxRKActor::draw(int x,int y) {
	if (iter==sequences.end()) 
		return;
	(*iter)->draw(x,y);
}

void ofxRKActor::setSequence(int seq) {
	if (seq>=sequences.size()) 
		return;
	
	iter = sequences.begin()+seq;
	firstFrame();
	bStartSequence = true;
	
}

/*
void ofxRKActor::setSequence(string seqName) {
	int seq = getSequenceNumber(seqName);
	if (seq>=sequences.size()) 
		return;
	
	iter = sequences.begin()+seq;
	firstFrame();
	bStartSequence = true;
	
}
*/

int ofxRKActor::getSequenceNumber(string seqName) {
	return sequencesMap[seqName];
	
}

string ofxRKActor::getSequenceName(int seq) {
	return sequencesNames.at(seq);
}

int ofxRKActor::getCurrentSequence() {
	return distance(sequences.begin(), iter);
}

void ofxRKActor::play() {
	bPlaying = true;
}

void ofxRKActor::pause() {
	bPlaying = false;
}

bool ofxRKActor::getIsPlaying() {
	return bPlaying;
}

void ofxRKActor::setCurrentFrame(int i) {
	(*iter)->setCurrentFrame(i);
}


void ofxRKActor::firstFrame() {
	(*iter)->firstFrame();
}

void ofxRKActor::lastFrame() {
	(*iter)->lastFrame();
}

int	 ofxRKActor::getTotalNumSequences() {
	return sequences.size();
}

bool ofxRKActor::getIsSequenceDone() {
	if (iter==sequences.end()) 
		return false;
	return (*iter)->isLastFrame();
}


