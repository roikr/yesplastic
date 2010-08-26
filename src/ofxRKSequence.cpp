#include "ofxRKSequence.h"
#include "ofxRKTexture.h"

#include "ofxXmlSettings.h"

void ofxRKSequence::setup(ofxXmlSettings *xml,int seq,string path) {
	
	this->prefix = xml->getAttribute("sequence", "prefix", "", seq);
	this->width = xml->getAttribute("sequence", "width", 0, seq);
	this->height = xml->getAttribute("sequence", "height", 0, seq);
	this->numFrames = xml->getAttribute("sequence", "frames", 0, seq);
	
	xml->pushTag("sequence", seq);
	
	int k=0;
	int n=0;
	for (int i=0; i<xml->getNumTags("textures"); i++) {
		int size = xml->getAttribute("textures", "size", 0, i	);
		int frames_per_texture = (size / height)*(size / width);
		
		for (int j=0; j<xml->getAttribute("textures", "number", 0, i); j++) {
			atlas a;
			a.start = n;
			n+=frames_per_texture;
			a.number = frames_per_texture;
			a.texture = new ofxRKTexture();
			string filename =prefix+"_" + ofToString(k) + ".pvr";
			k++;
			//ofLog(OF_LOG_VERBOSE,"loading: %s, start: %u, number: %u",filename.c_str(),a.start,a.number);
			a.texture->setup(ofToDataPath(path+"/"+filename),width,height);
			atlases.push_back(a);
		}
	}
	
	xml->popTag();
	
	currentFrame = 0;
}

void ofxRKSequence::init() {
	for (vector<atlas>::iterator iter  = atlases.begin() ; iter != atlases.end(); iter++)
		(*iter).texture->init();	
}

void ofxRKSequence::load() {
	for (vector<atlas>::iterator iter  = atlases.begin() ; iter != atlases.end(); iter++)
		(*iter).texture->load();
}

void ofxRKSequence::unload() {
	for (vector<atlas>::iterator iter  = atlases.begin() ; iter != atlases.end(); iter++)
		(*iter).texture->unload();
}

void ofxRKSequence::release() {
	for (vector<atlas>::iterator iter  = atlases.begin() ; iter != atlases.end(); iter++)
		(*iter).texture->release();
}


void ofxRKSequence::exit() {
	release();
}

void ofxRKSequence::draw(int x,int y) {
	draw(x,y,currentFrame);
}

void ofxRKSequence::setCurrentFrame(int i) {
	currentFrame = i;
}

int ofxRKSequence::getCurrentFrame() {
	return currentFrame;
}

void ofxRKSequence::firstFrame() {
	currentFrame = 0;
}

void ofxRKSequence::nextFrame() {
	if (currentFrame < numFrames -1)
		currentFrame++;
}

void ofxRKSequence::previousFrame() {
	if (currentFrame >0) 
		currentFrame--;
}

bool ofxRKSequence::isLastFrame() {
	return currentFrame == numFrames - 1;
}

int	 ofxRKSequence::getTotalNumFrames() {
	return numFrames;
}


void ofxRKSequence::draw(int x,int y,int i) {
	vector<atlas>::iterator iter;
	for (iter  = atlases.begin() ; iter != atlases.end() && (*iter).start+(*iter).number-1 < i; iter++) ;
	if (iter!=atlases.end()) 
		(*iter).texture->draw(x,y,i-(*iter).start);
}

