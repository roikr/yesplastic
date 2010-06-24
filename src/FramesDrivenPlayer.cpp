#include "FramesDrivenPlayer.h"
#include "ofxXmlSettings.h"
#include "Constants.h"
#include "ofxRKTexture.h"

enum  {
	
	SEQUENCE_IDLE,
	SEQUENCE_IN,
	SEQUENCE_OUT
	
};

FramesDrivenPlayer::FramesDrivenPlayer(string soundSetPath,string subSoundSet) {
	driver.loadVectors(soundSetPath+"/"+subSoundSet+"/"+subSoundSet+".xml");
	this->subSoundSet = subSoundSet;
	
}
												

void FramesDrivenPlayer::setup(string setName) {
	
	
	
	/*
	this->xml = xml;
	enable = xml.getValue("enable", "true",0) == "true";
	if (!enable)
		return;
	 */
	
	ofxXmlSettings xml;
	this->setName = setName;
	bool loaded = xml.loadFile("VIDEOS/"+setName+"/"+setName+".xml");
	enable = true;
	if (!loaded) {
		enable = false;
		return;
	}
	
	
	
	xml.pushTag("video_set");
	displayName = xml.getValue("id","");
	
	x = xml.getValue("x",0);
	y = xml.getValue("y",0);
	tx = xml.getValue("tx",x);
	ty = xml.getValue("ty",y);
	
	solo_x = xml.getValue("solo:x",0);
	solo_y = xml.getValue("solo:y",0);
	solo_scale = xml.getValue("solo:scale",0.0);
	
	
	
		
	
	for (int i=0; i<xml.getNumTags("actor"); i++) {
		string path = "VIDEOS/" + xml.getAttribute("actor","path","",i);
		bool bLips = xml.getAttribute("actor", "lips", 0, i);
		xml.pushTag("actor",i);
		ofLog(OF_LOG_VERBOSE,"setup: %s(%i)",path.c_str(),i);
		if (bLips) {
			lipsActor.setup(&xml, path);
		}
		else {
			actor.setup(&xml, path);
			for (int j=0; j<actor.getTotalNumSequences(); j++) {
				vector<string> split = ofSplitString(actor.getSequenceName(j), "_");
				if (split.back() != "IDLE" && split.back() != "IN" && split.back() != "OUT") {
					sequences.push_back(j);
				}
				specSeqs.push_back(actor.getSequenceNumber(setName+"_IDLE"));
				specSeqs.push_back(actor.getSequenceNumber(setName+"_IN"));
				specSeqs.push_back(actor.getSequenceNumber(setName+"_OUT"));
				
				//seqsToSpec[actor.getSequenceNumber(setName+"_IDLE")] = SEQUENCE_IDLE;
				//seqsToSpec[actor.getSequenceNumber(setName+"_IN")] = SEQUENCE_IN;
				//seqsToSpec[actor.getSequenceNumber(setName+"_OUT")] = SEQUENCE_OUT;
				
			}
		}

		xml.popTag();
	}
	
	
	
	
	xml.popTag();
	
	/*
	 for (i=0;i<xml.getNumTags("hierarchy:id");i++) {
	 string sampleID = xml.getValue("hierarchy:id","",i);
	 hierarchy.push_back(samples[sampleID[0]-'A']);
	 }*/
	
	
	
	//scale = xml.getValue("scale",0.0);
	nextSequence = SEQUENCE_IDLE;
	bChangeSequence = true;
	
	/*
	actor.setSequence(nextSequence);
	actor.play();
	
	lipsActor.setSequence(nextSequence);
	lipsActor.play();
	*/
	track.loadTracks("VIDEOS/"+setName+"/"+setName+"_TRACKS.xml");
	
	state = BAND_STATE;
	
	bTransitionEnded = false;
}



void FramesDrivenPlayer::prepareOut() {
	if (!enable)
		return;
	
	ofLog(OF_LOG_VERBOSE,"%s: unloading actor",setName.c_str());
	for (vector<int>::iterator i=sequences.begin(); i!=sequences.end(); i++) 
		actor.unload(*i);
	ofLog(OF_LOG_VERBOSE,"%s: loading out actor",setName.c_str());
	actor.load(specSeqs[SEQUENCE_OUT]);
	
	ofLog(OF_LOG_VERBOSE,"%s: unloading lips actor",setName.c_str());
	for (int i=0; i<lipsActor.getTotalNumSequences(); i++) 
		lipsActor.unload(i);
	

}

void FramesDrivenPlayer::initIn() {
	if (!enable)
		return;
	
	ofLog(OF_LOG_VERBOSE,"%s: initializing idle actor",setName.c_str());
	actor.init(specSeqs[SEQUENCE_IDLE]);
	ofLog(OF_LOG_VERBOSE,"%s: initializing in actor",setName.c_str());
	actor.init(specSeqs[SEQUENCE_IN]);
}

void FramesDrivenPlayer::prepareIn() {
	if (!enable)
		return;

	ofLog(OF_LOG_VERBOSE,"%s: loading idle actor",setName.c_str());
	actor.load(specSeqs[SEQUENCE_IDLE]);
	ofLog(OF_LOG_VERBOSE,"%s: loading in actor",setName.c_str());
	actor.load(specSeqs[SEQUENCE_IN]);
	
}

void FramesDrivenPlayer::finishOut() {
	if (!enable)
		return;
	
	ofLog(OF_LOG_VERBOSE,"%s: unloading idle actor",setName.c_str());
	actor.unload(specSeqs[SEQUENCE_IDLE]);
	ofLog(OF_LOG_VERBOSE,"%s: unloading out actor",setName.c_str());
	actor.unload(specSeqs[SEQUENCE_OUT]);
	
}
	

void FramesDrivenPlayer::initSet() {
	if (!enable)
		return;
	
	ofLog(OF_LOG_VERBOSE,"%s: initializing actor",setName.c_str());
	for (vector<int>::iterator i=sequences.begin(); i!=sequences.end(); i++) 
		actor.init(*i);
	ofLog(OF_LOG_VERBOSE,"%s: initializing out actor",setName.c_str());
	actor.init(specSeqs[SEQUENCE_OUT]);
	
	ofLog(OF_LOG_VERBOSE,"%s: initializing lips actor",setName.c_str());
	for (int i=0; i<lipsActor.getTotalNumSequences(); i++) 
		lipsActor.init(i);
	
}

void FramesDrivenPlayer::prepareSet() {
	if (!enable)
		return;
	
	ofLog(OF_LOG_VERBOSE,"%s: unloading in actor",setName.c_str());
	actor.unload(specSeqs[SEQUENCE_IN]);
	ofLog(OF_LOG_VERBOSE,"%s: loading actor",setName.c_str());
	for (vector<int>::iterator i=sequences.begin(); i!=sequences.end(); i++) 
		actor.load(*i);
	
	ofLog(OF_LOG_VERBOSE,"%s: loading lips actor",setName.c_str());
	for (int i=0; i<lipsActor.getTotalNumSequences(); i++) 
		lipsActor.load(i);
	
}

void FramesDrivenPlayer::releaseSet() {
	if (!enable)
		return;
	ofLog(OF_LOG_VERBOSE,"%s: releasing actor",setName.c_str());
	
	for (int i=0; i<actor.getTotalNumSequences(); i++) 
		actor.release(i);
	
	
	ofLog(OF_LOG_VERBOSE,"%s: releasing lips actor",setName.c_str());
	for (int i=0; i<lipsActor.getTotalNumSequences(); i++) 
		lipsActor.release(i);
	
}


void FramesDrivenPlayer::startTransition(bool bPlayIn) {
	bTransitionEnded = false;
	bChangeSequence = true;
	nextSequence = bPlayIn ? SEQUENCE_IN : SEQUENCE_OUT;
		
	 // followed call to update yields frame = 0
	//nextFrame = 0;	
}

bool FramesDrivenPlayer::didTransitionEnd() {
	if (bTransitionEnded) {
		bTransitionEnded = false;
		return true;
	}
	return false;
}


void FramesDrivenPlayer::setDrivenSample(string sampleName) {
	
	cout << "setDriverSample: " << sampleName << endl;
	
	if (!driver.doesSampleExist(sampleName)) {
		cout << "sample does not exist" << endl;
		return;
	}
	
	driver.setCurrentSample(sampleName);  
	driver.setCurrentVideo(0);
	
	string seqName = driver.getVideoName();
	cout << "seqName: " << seqName << endl;
	actor.setSequence(actor.getSequenceNumber(seqName));
	
	currentFrame = 0;
	int lf = driver.getLipsFrame(currentFrame);
	int vf = driver.getVideoFrame(currentFrame);
	
	actor.setCurrentFrame(vf);
	lipsActor.setSequence(lipsActor.getSequenceNumber(seqName+"_LIPS"));
	track.setCurrentTrack(seqName);
	track.getPoint(vf, lx, ly);
	lipsActor.setCurrentFrame(6*vf+lf);
}

void FramesDrivenPlayer::play(int num) {
	//setDrivenSample(num+1); // play get 0 for sample 1
	//setDrivenSample(num); // now the first sample is 0
	setDrivenSample(subSoundSet+"_"+ofToString(num+1)); // get 0 for first sound which name is VOC_BLABLA_1
}


void FramesDrivenPlayer::update() {
	if (!enable)
		return;
	
	if (!bChangeSequence) {
		/*
		switch (actor.getCurrentSequence()) {
			case SEQUENCE_IN:
			case SEQUENCE_OUT:
				break;
			default: 
				if (currentFrame >= driver.getNumVideoFrames()) {
					if (actor.getCurrentSequence() == SEQUENCE_IDLE) {
						currentFrame = -1;
					} else {
						nextSequence = SEQUENCE_IDLE;
						bChangeSequence = true;
						actor.pause();
					} 
				}
				break;
		}
		 */
		
		if (actor.getCurrentSequence() !=specSeqs[SEQUENCE_IN] && actor.getCurrentSequence() !=specSeqs[SEQUENCE_OUT]) {
			if (currentFrame >= driver.getNumVideoFrames()) {
				if (actor.getCurrentSequence() == specSeqs[SEQUENCE_IDLE]) {
					currentFrame = -1;
				} else {
					nextSequence = SEQUENCE_IDLE;
					bChangeSequence = true;
					actor.pause();
				} 
			}
		}
	}
	
	if (bChangeSequence) {
		bChangeSequence = false;
		
		switch (nextSequence) {
			case SEQUENCE_IN:
			case SEQUENCE_OUT: 
				actor.setSequence(actor.getSequenceNumber(setName +  (nextSequence == SEQUENCE_IN ? "_IN" : "_OUT")));
				actor.firstFrame();
				actor.play();
				break;
			case SEQUENCE_IDLE:
				setDrivenSample(subSoundSet+"_IDLE");
				break;
			default:
				break;
		}
		 
		
	} else {
		/*
		switch (actor.getCurrentSequence()) {
			case SEQUENCE_IN:
			case SEQUENCE_OUT:
				if (actor.getIsSequenceDone()) {
					nextSequence = SEQUENCE_IDLE;
					bChangeSequence = true;
					bTransitionEnded = true;
				} 
				else {
					actor.update();
				}
				
				break;
			
			default: 
				currentFrame++;
				
				int lf = driver.getLipsFrame(currentFrame);
				int vf = driver.getVideoFrame(currentFrame);
				actor.setCurrentFrame(vf);
				track.getPoint(vf, lx, ly);
				lipsActor.setCurrentFrame(6*vf+lf);
				

				break;
		}
		 */
		if (actor.getCurrentSequence() ==specSeqs[SEQUENCE_IN] || actor.getCurrentSequence() ==specSeqs[SEQUENCE_OUT]) {
			if (actor.getIsSequenceDone()) {
				nextSequence = SEQUENCE_IDLE;
				bChangeSequence = true;
				bTransitionEnded = true;
			} 
			else {
				actor.update();
			}
				
		} else {
		
			currentFrame++;
			
			int lf = driver.getLipsFrame(currentFrame);
			int vf = driver.getVideoFrame(currentFrame);
			actor.setCurrentFrame(vf);
			track.getPoint(vf, lx, ly);
			lipsActor.setCurrentFrame(6*vf+lf);
			
		}
		
	}

	//debugStr=ofToString(frame)+" "+setName+" "+ (bPlayIn ? "IN" : (bPlayOut ? "OUT" : ""));  
}


void FramesDrivenPlayer::draw(){
	if (!enable)
		return;
	
	
	/*
	switch (actor.getCurrentSequence()) {
		case SEQUENCE_IN:
		case SEQUENCE_OUT:
			actor.draw(tx, ty);
			break;
		case SEQUENCE_IDLE:
			actor.draw(x,y);
			break;
		default:
			actor.draw(x,y);
			lipsActor.draw(x+lx,y+ly);
			break;
	}
	 */
	
	if (actor.getCurrentSequence() ==specSeqs[SEQUENCE_IN] || actor.getCurrentSequence() ==specSeqs[SEQUENCE_OUT]) {
		actor.draw(tx, ty);
	} else {
		actor.draw(x,y);
		if (actor.getCurrentSequence() !=specSeqs[SEQUENCE_IDLE])
			lipsActor.draw(x+lx,y+ly);
	}

	
	//font->drawString(debugStr,x,y);
}


void FramesDrivenPlayer::setState(int state) {
	this->state = state;
}



void FramesDrivenPlayer::translate() {
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

float FramesDrivenPlayer::getScale() {
	return solo_scale;
}


void FramesDrivenPlayer::exit() {
	releaseSet();
	
}


