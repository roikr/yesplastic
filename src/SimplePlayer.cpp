#include "SimplePlayer.h"
#include "ofxXmlSettings.h"
#include "Constants.h"
#include "ofxRKTexture.h"


enum  {
	
	
	SEQUENCE_SAMPLE_1,
	SEQUENCE_SAMPLE_2,
	SEQUENCE_SAMPLE_3,
	SEQUENCE_SAMPLE_4,
	SEQUENCE_SAMPLE_5,
	SEQUENCE_SAMPLE_6,
	SEQUENCE_SAMPLE_7,
	SEQUENCE_SAMPLE_8,
	SEQUENCE_IDLE,
	SEQUENCE_IN,
	SEQUENCE_OUT
	
};


void SimplePlayer::setup(string setName) {
	
	/*
	this->xml = xml;
	enable = xml.getValue("enable", "true",0) == "true";
	if (!enable)
		return;
	 */
	
	ofxXmlSettings xml;
	this->setName = setName;
	bool loaded = xml.loadFile("VIDEOS/"+setName+"/"+setName+".xml");
	enable = false;
	assert(loaded);
	enable = true;
	progress = 0.0f;
	xml.pushTag("video_set");
	displayName = xml.getValue("id","");
	
	x = xml.getValue("x",0);
	y = xml.getValue("y",0);
	tx = xml.getValue("tx",x);
	ty = xml.getValue("ty",y);
	
	solo_x = xml.getValue("solo:x",0);
	solo_y = xml.getValue("solo:y",0);
	solo_scale = xml.getValue("solo:scale",0.0);
	
		
	string path = "VIDEOS/" + xml.getAttribute("actor","path","",0);
	xml.pushTag("actor");
	ofLog(OF_LOG_VERBOSE,"setup: %s",path.c_str());
	ofLog(OF_LOG_VERBOSE,"push: %s",path.c_str());
	pushWidth = xml.getAttribute("sequence", "width", 0);
	pushHeight = xml.getAttribute("sequence", "height", 0);
	pushTexture.setup(ofToDataPath("VIDEOS/"+setName+"/"+setName+"_PUSH.pvr"),pushWidth,pushHeight);
	bPush = false;
	actor.setup(&xml, path);
	xml.popTag();
	
	
	xml.popTag();
	
	/*
	 for (i=0;i<xml.getNumTags("hierarchy:id");i++) {
	 string sampleID = xml.getValue("hierarchy:id","",i);
	 hierarchy.push_back(samples[sampleID[0]-'A']);
	 }*/
	
	
	
	//scale = xml.getValue("scale",0.0);
	nextSequence = SEQUENCE_IDLE;
	actor.setSequence(nextSequence);
	actor.play();
	
	state = BAND_STATE;
	
	bTransitionEnded = false;
}

void SimplePlayer::setFont(ofTrueTypeFont * font) {
	this->font = font;
}


void SimplePlayer::initIdle() {
	ofLog(OF_LOG_VERBOSE,"%s: initializing idle actor",setName.c_str());
	actor.init(SEQUENCE_IDLE);
}

void SimplePlayer::loadIdle() {
	ofLog(OF_LOG_VERBOSE,"%s: loading idle actor",setName.c_str());
	actor.load(SEQUENCE_IDLE);
}

void SimplePlayer::unloadIdle() {
	ofLog(OF_LOG_VERBOSE,"%s: unloading idle actor",setName.c_str());
	actor.unload(SEQUENCE_IDLE);
}



void SimplePlayer::initIn() {
	if (!enable)
		return;
	
	ofLog(OF_LOG_VERBOSE,"%s: initializing in actor",setName.c_str());
	actor.init(SEQUENCE_IN);

}

void SimplePlayer::loadIn() {
	if (!enable)
		return;

	ofLog(OF_LOG_VERBOSE,"%s: loading in actor",setName.c_str());
	actor.load(SEQUENCE_IN);
	
}

void SimplePlayer::unloadIn() {
	if (!enable)
		return;
	
	ofLog(OF_LOG_VERBOSE,"%s: unloading in actor",setName.c_str());
	actor.unload(SEQUENCE_IN);
		
}


	

void SimplePlayer::initSet() {
	if (!enable)
		return;
	
	ofLog(OF_LOG_VERBOSE,"%s: initializing actor",setName.c_str());
	for (int i=SEQUENCE_SAMPLE_1; i<=SEQUENCE_SAMPLE_8; i++) {
		actor.init(i);
		progress = (i-SEQUENCE_SAMPLE_1)/(SEQUENCE_SAMPLE_8 - SEQUENCE_SAMPLE_1);
	}
		
	pushTexture.init();
	
}

void SimplePlayer::loadSet() {
	if (!enable)
		return;
	
	
	ofLog(OF_LOG_VERBOSE,"%s: loading actor",setName.c_str());
	for (int i=SEQUENCE_SAMPLE_1; i<=SEQUENCE_SAMPLE_8; i++) {
		actor.load(i);
		//progress = 0.5*(1.0+i-SEQUENCE_SAMPLE_1)/(SEQUENCE_SAMPLE_8 - SEQUENCE_SAMPLE_1);
	}
	
	pushTexture.load();
	
}

float SimplePlayer::getProgress() {
	ofLog(OF_LOG_VERBOSE,"actor %s progress: %f",setName.c_str(),progress);
	return progress;
}

void SimplePlayer::unloadSet() {
	if (!enable)
		return;
	
	ofLog(OF_LOG_VERBOSE,"%s: unloading actor",setName.c_str());
	for (int i=SEQUENCE_SAMPLE_1; i<=SEQUENCE_SAMPLE_8; i++) 
		actor.unload(i);
	
	pushTexture.unload();
	
}

void SimplePlayer::initOut() {
	if (!enable)
		return;
	
	ofLog(OF_LOG_VERBOSE,"%s: initializing out actor",setName.c_str());
	actor.init(SEQUENCE_OUT);
		
}

void SimplePlayer::loadOut() {
	if (!enable)
		return;
	
	ofLog(OF_LOG_VERBOSE,"%s: loading out actor",setName.c_str());
	actor.load(SEQUENCE_OUT);
	
}

void SimplePlayer::unloadOut() {
	if (!enable)
		return;
	
	
	ofLog(OF_LOG_VERBOSE,"%s: unloading out actor",setName.c_str());
	actor.unload(SEQUENCE_OUT);
	
}

void SimplePlayer::release() {
	if (!enable)
		return;
	ofLog(OF_LOG_VERBOSE,"%s: releasing actor",setName.c_str());
	
	for (int i=SEQUENCE_IDLE; i<=SEQUENCE_OUT; i++) 
		actor.release(i);
	
	pushTexture.release();
	
}


void SimplePlayer::startTransition(bool bPlayIn) {
	bTransitionEnded = false;
	nextSequence = bPlayIn ? SEQUENCE_IN : SEQUENCE_OUT;
		
	 // followed call to update yields frame = 0
	//nextFrame = 0;	
}

bool SimplePlayer::didTransitionEnd() {
	if (bTransitionEnded) {
		bTransitionEnded = false;
		return true;
	}
	return false;
}


void SimplePlayer::update() {
	if (!enable)
		return;
	
	if (nextSequence!=actor.getCurrentSequence()) {
		actor.setSequence(nextSequence);
		actor.firstFrame();
	} else if (!actor.getIsSequenceDone()) 
		actor.update();
	else {
		
		switch (actor.getCurrentSequence()) {
			case SEQUENCE_IN:
			case SEQUENCE_OUT:
				nextSequence = SEQUENCE_IDLE;
				bTransitionEnded = true;
				break;
			case SEQUENCE_IDLE:
				actor.firstFrame();
				break;
			default:
				nextSequence = SEQUENCE_IDLE;
				break;
		}
	}
	//debugStr=ofToString(frame)+" "+setName+" "+ (bPlayIn ? "IN" : (bPlayOut ? "OUT" : ""));  
}


void SimplePlayer::draw(){
	if (!enable)
		return;
	
	
	
	
	switch (actor.getCurrentSequence()) {
		case SEQUENCE_IN:
		case SEQUENCE_OUT:
			actor.draw(tx, ty);
			break;
		default:
			actor.draw(x,y);
			break;
	}
	
	if (bPush) {
		pushTexture.draw(x,y,0,0,pushWidth,pushHeight,1.0f);
		
	}
	
	
	
	
	//font->drawString(debugStr,x,y);
}

void SimplePlayer::setPush(bool bPush) {
	this->bPush = bPush;
}

void SimplePlayer::setState(int state) {
	this->state = state;
}

string SimplePlayer::getDebugString() {
	
	//string str = "frame: "+ ofToString(frame)+"\natlas: " + ofToString(frame/texture_capacity) +"\noffset: " + ofToString(frame % texture_capacity);
	
	return "";
}



void SimplePlayer::translate() {
	switch (state) {
		case SOLO_STATE:
			
			//ofTranslate(-x+(320-sub_texture_width)/2,-y+(480-sub_texture_height)/2);
			ofScale(solo_scale,solo_scale);
			ofTranslate(-solo_x,-solo_y);
			
						
			break;
		case BAND_STATE:
			break;
	}
}	

float SimplePlayer::getScale() {
	return solo_scale;
}

void SimplePlayer::play(int num) {
	nextSequence = SEQUENCE_SAMPLE_1 + num;
	actor.setSequence(nextSequence);
	actor.firstFrame();
	//cout << "num: " << num << ", name: " << actor.getSequenceName(nextSequence) << endl; // DEBUG
}

void SimplePlayer::exit() {
	release();
	
}


