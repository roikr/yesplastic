
#include "testApp.h"

//#include "ofxRKAQSoundPlayer.h"
#include "TexturesPlayer.h"
//#include "ofxRKTexture.h"
#include "Constants.h"
#include <math.h>

#include "ofxRKUtilities.h"
#include "ofSoundStream.h"

// listen on port 12345
#define PORT 12345


enum {
	loopswitch,
	tempo,
	gtr_loopswitch,
	gtr_volume,
	gtr_set,
	gtr_key,
	voc_loopswitch,
	voc_volume,
	voc_set,
	voc_key,
	drm_loopswitch,
	drm_volume,
	drm_set,
	drm_key,
	song_record,
	song_play
};




void testApp::setup(){	
	
	
	
	verdana.loadFont(ofToDataPath("verdana.ttf"),16);
	verdana.setLineHeight(20.0f);
	
	oscMap["/loopswitch"] = loopswitch;
	oscMap["/tempo"] = tempo;
	oscMap["/gtr_loopswitch"]=gtr_loopswitch;
	oscMap["/gtr_volume"]=gtr_volume;
	oscMap["/gtr_set"]=gtr_set;
	oscMap["/gtr_key"]=gtr_key;
	oscMap["/voc_loopswitch"]=voc_loopswitch;
	oscMap["/voc_volume"]=voc_volume;
	oscMap["/voc_set"]=voc_set;
	oscMap["/voc_key"]=voc_key;
	oscMap["/drm_loopswitch"]=drm_loopswitch;
	oscMap["/drm_volume"]=drm_volume;
	oscMap["/drm_set"]=drm_set;
	oscMap["/drm_key"]=drm_key;	
	oscMap["/record"]=song_record;
	oscMap["/play"]=song_play;	

	
	
	cout << "listening for osc messages on port " << PORT << "\n";
	//receiver.setup( PORT );
	
	printf("setup()\n");
	
	//ofBackground(0, 0, 0);
	
	//ofSetBackgroundAuto(true);
	ofSetFrameRate(60);
	
	// initialize the accelerometer
	//ofxAccelerometer.setup();

	// touch events will be sent to this class (testApp)
	//ofxMultiTouch.addListener(this);
	
	ofSetLogLevel(OF_LOG_VERBOSE);
		
	
	scale = 480.0/ 762.0;
	
	string filename = "images/background.pvr";
	background.setup(ofToDataPath(filename));
	background.init();
	background.load();

	filename = "images/buttons.pvr";
	buttons.setup(ofToDataPath(filename));
	buttons.init();
	buttons.load();
	
	//for (int i=0;i<3;i++) {}
	
	
	
	/*
	for (int i=0; i<xml.getNumTags("sound_set"); i++) {
		soundSets.push_back(xml.getValue("sound_set", "", i));
	}
	*/
	
	
	//MidiTrack::Init();
	
	lastFrame = 0;
	bChangeSet = false; 
	
	bButtonDown = false;
	
	startThread();
	
	for(int i=0;i<3;i++) {
		player[i].setup(i);
		//player[i].setFont(&verdana);
		//player[i].loadSet();
		//player[i].getTexturesPlayer()->setState(state);
		player[i].changeSet("PACIFIST");
		
		
	}
	//MidiTrack::SetSongMode(SONG_IDLE);
	
	controller = 1;
	setState(SOLO_STATE);
	
	bTrans = false;
	bMove = false;
	bMenu = false;
	
	
	sampleRate 			= 44100;
	blockLength = 256;
	

	lBlock = new float[blockLength];
	rBlock = new float[blockLength];

	bpm = 120; // TODO: send bpm to players
	ofSoundStreamSetup(2,0,this, sampleRate, blockLength, 4);
	
}

bool testApp::isSoundSetAvailiable(string soundSet) {
	vector<string> soundSets = ofListFolders(ofToDataPath("SOUNDS"));
	for (vector<string>::iterator iter = soundSets.begin(); iter!=soundSets.end(); iter++) {
		if (*iter == soundSet) {
			return true;
		}
	}
	return false;
}



//--------------------------------------------------------------
void testApp::audioRequested(float * output, int bufferSize, int nChannels){
	
	
	memset(lBlock, 0, bufferSize*sizeof(float));
	memset(rBlock, 0, bufferSize*sizeof(float));
	
	for (int i=0;i<3;i++) {
		player[i].processWithBlocks(lBlock, rBlock);
	}
	
//	float TWO_PI = 6.28;
//	
//	while (phase > TWO_PI){
//		phase -= TWO_PI;
//	}
//	
//	sin(phase+=TWO_PI/bufferSize;
		
	for (int i = 0; i < bufferSize; i++){
		output[i*nChannels] = lBlock[i];
		output[i*nChannels + 1] = rBlock[i];
	}
	
	
	
}


void testApp::threadedFunction() {
	int i=0;
	while (1) 
		player[i++%3].threadedFunction();
}


void testApp::setMode(int player,int mode) {
	bool looping = false;
	
	int i;
	for ( i=0;i<3;i++)
		looping = looping || (this->player[i].getMode() == LOOP_MODE);
	
	bool reset = !looping && mode==LOOP_MODE;
	
	if (reset) {
		ofLog(OF_LOG_VERBOSE,"reset loopers");
		for (i=0;i<3;i++) {
			this->player[i].sync();
		}
	}
	
	//if (mode == MANUAL_MODE || player != 0 || this->player[0].getMidiTrack()->getCurrentSet()==0)
	//if (mode == LOOP_MODE && player == 1) // && this->player[1].getMidiTrack()->getCurrentSoundSet()!="CHECKIT")
	//	return;
	
	this->player[player].setMode(mode);
	
}

void testApp::setState(int state) {
	if (this->state == state)
		return;
	
	animStart = ofGetElapsedTimeMillis();
	bTrans = true;
	
	
	this->state = state;
	switch (state) {
		case BAND_STATE: {
			for(int i=0;i<3;i++)
				player[i].setState(state);
		} break;
		case SOLO_STATE:
			player[controller].setState(state);
		default:
			break;
	}
	
	/*
	if (menu.mode!=MENU_IDLE) {
		menu.setPlayer(player+controller, state);
	}
	 */
}

int	testApp::getState() {
	return state;
}

bool testApp::isInTransition() {
	for (int i=0; i<3; i++) {
		if (player[i].isInTransition()) {
			return true;
		}
	}
	return false;
}

void testApp::changeSoundSet(string nextSoundSet, bool bChangeAll) {
	this->bChangeAll = bChangeAll;
	this->nextSoundSet = nextSoundSet;
	bChangeSet = true;
	
}


void testApp::update(){
	//	printf("update()\n");
	
	/*
	if (bChangeSet) {
		menu.player->getMidiTrack()->setMode(MANUAL_MODE,false);
		bChangeSet = false;
		menu.player->changeSet(menu.setNum);
	}
	 */
	
	
	if (bChangeSet) {
		bChangeSet = false;
		if (bChangeAll) {
			for (int i=0; i<3; i++) {
				player[i].setMode(MANUAL_MODE);
				player[i].changeSet(nextSoundSet);
			}
		} else {
			player[controller].setMode(MANUAL_MODE);
			player[controller].changeSet(nextSoundSet);
		}
	}
	 
	
	for (int i=0;i<3;i++)
		player[i].update();
/*
	if (measures.size()==1) {
		
		
		if (!bMove && menu.mode == MENU_IDLE && (ofGetElapsedTimeMillis()-measures.front().t) > 500) {
			menu.mode = MENU_DISPLAYED;
			
			menu.setPlayer(player+controller,state);
			measures.clear();
			
		}
		
	}
 */
}


void testApp::getTrans(int state,int controller,float &tx,float &ty,float &ts) {
	switch (state) {
		case SOLO_STATE: {
			ts = 1.17;
			
			switch (controller) {
				case 0: {
					tx = -6.0;
					ty = -75.0;
				} break;
				case 1: {
					tx = -246.0;
					ty = -75.0;
				} break;
				case 2: {
					tx = -488.0;
					ty = -75.0;
				} break;
			}
			
		} break;
		case BAND_STATE: {
			ts = scale;
			tx = 0;
			ty = 0;
		} break;
	}
}

float easeInOutQuad(float t, float b, float e) { 
	float d = 1.0;
	float c = e - b;
	if ((t/=d/2) < 1) 
		return c/2*t*t + b; 
	return -c/2 * ((--t)*(t-2) - 1) + b;
};

float easeOutBounce(float t, float b, float e) {
	// function (t, b, c, d) 
	float c = e - b;
	float d = 1.0;
    
	if ((t/=d) < (1/2.75)) {
		return c*(7.5625*t*t) + b;
	} else if (t < (2/2.75)) {
		return c*(7.5625*(t-=(1.5/2.75))*t + .75) + b;
	} else if (t < (2.5/2.75)) {
		return c*(7.5625*(t-=(2.25/2.75))*t + .9375) + b;
	} else {
		return c*(7.5625*(t-=(2.625/2.75))*t + .984375) + b;
	}
}

float easeOutBack (float t, float b, float e) {
	float c = e - b;
	float d = 1.0;
	float s = 1.70158;
	return c*((t=t/d-1)*t*((s+1)*t + s) + 1) + b;
};


float interp (float a,float x,float y) {
	return (1-a)*x+a*y;
}

//--------------------------------------------------------------
void testApp::draw(){
	//	printf("draw()\n");
	
	float ts;
	float tx;
	float ty;
	
	int time = ofGetElapsedTimeMillis();
	
	getTrans(state, controller, tx, ty, ts);
	
	if (bTrans) {
		float t = (float)(time - animStart)/250.0;
		if (t >= 1) {
			bTrans = false;
		} else {
			float s;
			float x;
			float y;
			getTrans(state == BAND_STATE ? SOLO_STATE : BAND_STATE, controller, x, y, s);
			
			ts = easeInOutQuad(t,s,ts);
			tx = easeInOutQuad(t,x,tx);
			ty = easeInOutQuad(t,y,ty);
		}
	}
	
	
	if (state==SOLO_STATE) {
		
		if (measures.size()>1) {
			float d = measures.back().x-measures.front().x;
			if ( (controller == 2 && d < 0) || (controller == 0 && d > 0)) {
				d=d/2;
			}
			
			tx += d/ts;
		}
		
		if (bMove) {
			float t = (float)(time - moveTime)/250.0;
			if (t >= 1) 
				bMove = false;
			else 
				tx = easeOutBack(t,sx,tx);
		}	
		
		
		
	}
	

	ofPushMatrix();
	ofScale(ts, ts, 1.0);
	ofTranslate(tx, ty, 0.0);
			
	background.draw(0,0);

	int i;
	
	if (bTrans || bMove || !measures.empty() || state == BAND_STATE) {
		for(i=0;i<3;i++)
			player[i].draw();
	} else {
		player[controller].draw();
	}
	
	ofPopMatrix();
	
	int x;
	int y;
	
	if (!bTrans ) {
		switch (state) {
			case SOLO_STATE:
			{
				if (!bMove && measures.empty() && !bMenu) 
					for (i=0;i<8;i++) {
						
						y = 360+(i/4) * 60;
						x = 10+(i%4)*80;
						if (player[controller].getMode() == MANUAL_MODE)
							buttons.draw(x,y,i*60,controller*2*60,60,60,bButtonDown && i==button ?  1.0f : 0.4f );
						else
							buttons.draw(x,y,i*60,(controller*2+1)*60,60,60,i==player[controller].getCurrentLoop() ?  1.0f : 0.4f );
					}
				
			} break;
			case BAND_STATE:
			
			{
				
				/*
				for (i=0;i<8;i++) 
					if (player[controller].getMidiTrack()->getMode() == MANUAL_MODE)
						buttons.draw(i*60,260,i*60,controller*2*60,60,60,bButtonDown && i==button ?  1.0f : 0.4f );
					else
						buttons.draw(i*60,260,i*60,(controller*2+1)*60,60,60,i==player[controller].getMidiTrack()->getCurrentLoop() ?  1.0f : 0.4f );
				*/
				
				
					
				
				if (!measures.empty() ) 
					buttons.draw(50+controller*160,260,nextLoop*60,(controller*2+1)*60,60,60,  1.0f );
				
			} 
			 
			break;
				
		}
		
		
		//for(i=0;i<3;i++) {
			/*
			float alpha =1.0f;
			if (state==BAND_STATE && player[i].getMidiTrack()->getMode() == MANUAL_MODE) {
				alpha = 1.0f;
			} 
			
			if (player[i].bFade) {
				float t = (float)(time - player[i].fadeStart)/250.0;
				if (t >= 1) 
					player[i].bFade = false;
				else {
					alpha = easeInOutQuad(t,alpha > 0.0f ? 0.0f : 1.0f,ty);
				}
					
			}
			 */
			//player[i].mask.draw(player[i].mask_x*scale,0,player[i].mask_width,320,1.0f);
			//player[i].mask.draw(player[i].mask_x*scale,0,0,0,player[i].mask_width,320,0.0f);
		//
	//}
		 
		
		/*
		if (menu.mode != MENU_IDLE && !bTrans) 
			menu.draw();
		 */
	}
	
	
	/*
	 
	 ui.draw(10,0,bPlay ? 90 : 10,0,20,20,bPlay ? 1.0f : 0.4f);
	 ui.draw(450,0,bRecord ? 370 : 450,0,20,20,bRecord ? 1.0f : 0.4f);
	 
	 if (bpmDown) {
	 ui.draw(40,0,40,0,20,20,1.0f);
	 ui.draw(420,0,420,0,20,20,1.0f);
	 ui.draw((bpmVal - 50.0)/150.0 * 380.0 + 40.0,0,60,0,20,20,1.0f);
	 }
	 else
	 ui.draw((float)(MidiTrack::GetBPM() - 50)/150.0 * 380.0 + 40.0,0,60,0,20,20,0.4f);
	 */
	
	
	
}

void testApp::exit() {
	printf("exit()\n");
	stopThread();
	for (int i=0;i<3;i++) {
		//setMode(i,MANUAL_MODE);
		player[i].exit();
	}
	
}


/*
 
 // DOWN
 
 if (y>20) {// characters
 
 bShowMenu = true;
 
 
 }
 
 
 
 
  */

//--------------------------------------------------------------
void testApp::touchDown(float x, float y, int touchId) {
	
	//printf("touchDown: %.f, %.f %i\n", x, y, touchId);
	
	
	
	if (state==BAND_STATE) {
		controller = (int)x/160;
		nextLoop = player[controller].getCurrentLoop();
	}
	
	
	
	if (state==SOLO_STATE && y>=360) {
		button = 4*(((int)y-360)/60)+(int)x/80;
		
		if (player[controller].isEnabled() && !player[controller].isInTransition()) {					
			if ( player[controller].getMode() == MANUAL_MODE ) {
				player[controller].play(button);	
			}
			
			if ( player[controller].getMode() == LOOP_MODE ) {
				player[controller].changeLoop(button);		
			}			
		}
		bButtonDown = true; // for view 
	} else {
		
		
		measure m;
		m.x = x;
		m.y = y;
		m.t = ofGetElapsedTimeMillis();
		measures.push_back(m);
	}
		
	
}


	
	
	
	

void testApp::touchMoved(float x, float y, int touchId) {
	//printf("touchMoved: %.f, %.f %i\n", x, y, touchId);
	
	if (touchId!=0 || bButtonDown) 
		return;
	
	measure m;
	m.x = x;
	m.y = y;
	m.t = ofGetElapsedTimeMillis();

	measures.push_back(m);
	
	switch (state) {
		case SOLO_STATE: 
			
			break;
		case BAND_STATE:
			
			nextLoop = (player[controller].getCurrentLoop() + (measures.back().y-measures.front().y) / 40 + 8) % 8;
			
			break;
	}
}


void testApp::touchUp(float x, float y, int touchId) {
	//printf("touchUp: %.f, %.f %i\n", x, y, touchId);
	
	if (touchId!=0 || bMenu) {
		if (!measures.empty()) {
			measures.clear();
		}
		return;
	}
	
	switch (state) {
		case SOLO_STATE: {
			
			if (y<360 && measures.size()>1 ) {
				bMove = true;
				
				
				moveTime = ofGetElapsedTimeMillis();
				
				
				float y,s;
				getTrans(SOLO_STATE, controller, sx,y,s);
				
				float d = measures.back().x-measures.front().x;
				if ( (controller == 2 && d < 0) || (controller == 0 && d > 0)) {
					d=d/2;
				} else {
					
					if (measures.size()>=2) {
						measure m = measures.back();
						measure m0 = measures.at(measures.size()-2);
						float dx = m.x-m0.x;
						float dt = m.t-m0.t;
						//printf("touchMoved: %.f, %.f\n", dx, dt);
						vx = dx/dt;
					} else 
						vx = 0;
					
					
					
					if (fabs(vx)>1.0) {
						if (controller < 2 && vx<0) 
							controller++;
						else if (controller > 0 && vx>0) 
							controller--;
						
					}  else if (fabs(d/s)>160) {
						
						if (controller <2 && d/s<0) 
							controller++;
						else if (controller >0 && d/s>0) 
							controller--;
					} 
				}
				
				sx+=d/s;
			}
		} break;
			
			
			
		case BAND_STATE: 
			
			if (player[controller].getCurrentLoop() != nextLoop ) 
				player[controller].changeLoop(nextLoop);
			
			break;
	}
	
	if (measures.size()<=1 && !bButtonDown) {
		setMode(controller,player[controller].getMode() == MANUAL_MODE ? LOOP_MODE : MANUAL_MODE);
	}
	
	measures.clear();
	bButtonDown = false;
	
	
}

	

float testApp::getVolume() {
	return player[controller].getVolume();
}
	
void testApp::setVolume(float vol) {
	player[controller].setVolume(vol);
}



float testApp::getBPM() {
	return (bpm - 50.0)/150.00;
}

void testApp::setBPM(float bpm) {
	this->bpm = ofClamp(bpm*150.0+50.0,50,200);
	
	for (int i=0;i<3;i++) {
		player[i].setBPM(this->bpm);
	}
}

//TODO: implement these
void testApp::play() {
	
	for (int i=0;i<3;i++) {
		player[i].playSong();
	}
}

void testApp::stop() {
	for (int i=0;i<3;i++) {
		player[i].stopSong();
	}
//	bool bRecord = MidiTrack::GetSongMode() == SONG_RECORD;
//	MidiTrack::SetSongMode(SONG_IDLE);
//	for (int i=0;i<3;i++)
//		this->player[i].getMidiTrack()->setMode(MANUAL_MODE,false);
//	
//	if (bRecord) {
//		saveMidi();
//	}
}

void testApp::record() {
//	MidiTrack::SetSongMode(SONG_RECORD);
//	for (int i=0;i<3;i++)
//		player[i].getMidiTrack()->setupSong();
}

bool testApp::getIsPlaying() {
	bool res = false;
	for (int i=0;i<3;i++)
		res = res || player[i].getIsPlaying();
	return res;
}


	

void testApp::saveMidi() {
	ofxXmlSettings midiXml;
	midiXml.addTag("MIDIFile");
	midiXml.pushTag("MIDIFile");
	midiXml.addValue("Format", 0);
	midiXml.addValue("TrackCount", 3);
	midiXml.addValue("TicksPerBeat", 96);
	midiXml.addValue("TimestampType", "Absolute");
	
	for (int i=0; i<3; i++) {
		midiXml.addTag("Track");
		midiXml.addAttribute("Track", "Number", i, i);
		midiXml.pushTag("Track", i);
		//player[i].getMidiTrack()->addMidiToXML(&midiXml); // TODO: save song
		midiXml.popTag();
	} 
	midiXml.popTag();
	
	midiXml.saveFile(ofToDocumentsPath("ohYeahPlastic.xml"));
	
	/*
	string str;
	midiXml.copyXmlToString(str);
	cout << str;
	 */
}

void testApp::didBecomeAcive() {
	cout << "testApp::didBecomeAcive" << endl;
	ofSoundStreamStart();
}

void testApp::willResignActive() {
	cout << "testApp::willResignActive" << endl;
	ofSoundStreamStop();

}
