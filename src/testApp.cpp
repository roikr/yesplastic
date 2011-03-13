
#include "testApp.h"
#include "ofMainExt.h"

//#include "ofxRKAQSoundPlayer.h"
#include "TexturesPlayer.h"
//#include "ofxRKTexture.h"
#include "Constants.h"
#include <math.h>

#include "ofxRKUtilities.h"
#include "ofSoundStream.h"

#include "easing.h"

// listen on port 12345
#define PORT 12345
#define RECORD_LIMIT 60000

#define GLOBAL_GAIN 0.65
#define FULL_SCREEN_SCALE 480.0 / 762.0

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



testApp::testApp() {
	bInitialized = false;
	songState = SONG_IDLE;
	//bChangeSet = false;
}


void testApp::setup(){	
	
	
	/*
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
	 */
	
	
	//cout << "listening for osc messages on port " << PORT << "\n";
	//receiver.setup( PORT );
	
	//printf("setup()\n");
	
	//ofBackground(0, 0, 0);
	
	//ofSetBackgroundAuto(true);
	ofSetFrameRate(60);
	
	// initialize the accelerometer
	//ofxAccelerometer.setup();

	// touch events will be sent to this class (testApp)
	//ofxMultiTouch.addListener(this);
	
	ofSetLogLevel(OF_LOG_VERBOSE);
		
	sampleRate 			= 44100;
	blockLength = 256;

	lBlock = new float[blockLength];
	rBlock = new float[blockLength];
	
	bpm = 120; // TODO: send bpm to players
	song.setupForSave(blockLength);
	
	
	
	 
	string filename = "background.pvr";
	background.setup(ofToDataPath(filename));
	background.init();
	background.load();
	
	

//	filename = "images/buttons.pvr";
//	buttons.setup(ofToDataPath(filename));
//	buttons.init();
//	buttons.load();
	
	
	
	//bChangeSet = false; 
	
//	bButtonDown = false;
	bNeedDisplay = false;
	bInTransition = false;
	
	//startThread();
	
	
	for(int i=0;i<3;i++) {
		player[i].setup(i);
		//player[i].setFont(&verdana);
		//player[i].loadSet();
		//player[i].getTexturesPlayer()->setState(state);
		//player[i].loadSet(getPlayerName(i)+"_"+"HEAT","");
		
		
	}
	 
	 
	sliderPrefs prefs;
	float scale;
	ofPoint pnt;
	for (int i=0; i<3; i++) {
		
		getTrans(SOLO_STATE, i, pnt, scale);
		prefs.pages.push_back(-pnt);
	}
	
	slider.setup(scale, prefs);
	controller = 1;
	
	setState(SOLO_STATE);
	
	bTrans = false;
	//bMenu = false;
	bPush = false;
	
	
		

	
	ofSeedRandom();
	
	
	
	startTime = ofGetElapsedTimeMillis();
	currentFrame = 0;
	
	
	
	soundStreamSetup();
	bInitialized = true;
	
}

void testApp::update() {
	
	if (!bInitialized) {
		return;
	}
	
	if (songState!=SONG_RENDER_VIDEO) {
		int frame =(ofGetElapsedTimeMillis()-startTime)  / 40;
		if (frame>currentFrame) {
			
			for (int j=0; j<frame-currentFrame; j++) {
				for (int i=0;i<3;i++) {
					player[i].nextFrame();
				}
			}
			
			if (frame-currentFrame>1) {
				ofLog(OF_LOG_VERBOSE,"skipped %i",frame-currentFrame);
			}
			
			currentFrame = frame;
		}
			
	}
	
	

	
	if (isInTransition()!=bInTransition) {
		bInTransition = !bInTransition;
		bNeedDisplay = true;
	}
	

	
	switch (songState) {
		case SONG_TRIGGER_RECORD:
			for (int i=0; i<3; i++) {
				if (getMode(i) == LOOP_MODE) {
					startRecording();
					break;
				}
			}
			break;
		case SONG_RECORD:
			if (ofGetElapsedTimeMillis()-startRecordingTime > RECORD_LIMIT) {
				setSongState(SONG_IDLE);
			} 
			break;
		case SONG_PLAY:
		//case SONG_RENDER_AUDIO:
		//case SONG_CANCEL_RENDER_AUDIO:
		// commented - to fix smooth the transition from AUDIO_RENDERING to VIDEO_RENDERING
			
			if (! getIsPlaying()) {
				
				songState = SONG_IDLE;
				for (int i=0;i<3;i++) {
					if (player[i].getSongState()!=SONG_IDLE) {
						player[i].setSongState(SONG_IDLE);
					}
				}
				bNeedDisplay = true;
			}
			break;
			
		case SONG_RENDER_VIDEO:
			
			if  (currentBlock / totalBlocks >= 1.0) {
				setSongState(SONG_RENDER_VIDEO_FINISHED); // 
				//songState = SONG_IDLE; // TODO: check why not notifying players...
				//bNeedDisplay = true;
			}
			
			
			break;
			
			
		default:
			break;
	}
		
}


bool testApp::isSongAvailiable(string song,int playerNum) {
	vector<string> soundSets = ofListFolders(ofToDataPath("SOUNDS"));
	for (vector<string>::iterator iter = soundSets.begin(); iter!=soundSets.end(); iter++) {
		if (*iter == getPlayerName(playerNum)+"_"+song) {
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
		
		
	for (int i = 0; i < bufferSize; i++){
		output[i*nChannels] = lBlock[i] * GLOBAL_GAIN;
		output[i*nChannels + 1] = rBlock[i] * GLOBAL_GAIN;
	}
	
}





float testApp::getProgress() {
	
	float progress = 1.0f;
	
	if (isInTransition()) {
		
		progress = 0;
		for (int i=0;i<3;i++)
			progress+=player[i].getProgress();
		
		progress/=3.0;
	} 
	
	return progress;
}



float testApp::getRenderProgress(){
	
	
//	float playhead = 0;
//	
//	for (int i=0;i<3;i++) {
//		float temp = player[i].getPlayhead();
//		if (temp > playhead) {
//			playhead = temp;
//		}
//	}
	
	switch (songState) {
		case SONG_RENDER_AUDIO: {
			float playhead = (float)currentBlock * (float)blockLength / (float)sampleRate;
			return playhead/duration;
		}	break;
		case SONG_RENDER_VIDEO:
			return (float)currentBlock/(float)totalBlocks;
		default:
			return 0.0f;
	}

	
	//return songState == SONG_RENDER_VIDEO && totalBlocks!=0 ? (float)currentBlock/(float)totalBlocks : 0.0f;
	
}


int testApp::getMode(int player) {
	return this->player[player].getMode();
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
	
	if (songState == SONG_TRIGGER_RECORD) {
		startRecording();
	}
	
	this->player[player].setMode(mode);
	bNeedDisplay = true;
}

void testApp::stopLoops() {
	for (int i=0;i<3;i++) {
		if (this->player[i].getMode() == LOOP_MODE) {
			this->player[i].setMode(MANUAL_MODE);
		}
	}
	bNeedDisplay = true;
}

int getRandomLoop() {
	return ofRandomuf() * 8;
}

void testApp::playRandomLoop() {
	
	float x = ofRandomuf();
	
	if (x<0.5) {
		setMode(0, LOOP_MODE);
		setMode(1, LOOP_MODE);
		setMode(2, LOOP_MODE);
		player[0].changeLoop(getRandomLoop());
		player[1].changeLoop(getRandomLoop());
		player[2].changeLoop(getRandomLoop());
	} else if (x<0.70) {
		setMode(0, LOOP_MODE);
		setMode(1, MANUAL_MODE);
		setMode(2, LOOP_MODE);
		player[0].changeLoop(getRandomLoop());
		player[2].changeLoop(getRandomLoop());
	} else if (x<0.85) {
		setMode(0, LOOP_MODE);
		setMode(1, LOOP_MODE);
		setMode(2, MANUAL_MODE);
		player[0].changeLoop(getRandomLoop());
		player[1].changeLoop(getRandomLoop());
	} else  {
		setMode(0, MANUAL_MODE);
		setMode(1, LOOP_MODE);
		setMode(2, LOOP_MODE);
		player[1].changeLoop(getRandomLoop());
		player[2].changeLoop(getRandomLoop());
	}
	
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
			slider.setPage(controller);
			break;
		default:
			break;
	}
	bNeedDisplay = true;
	
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

void testApp::loadSong(string songName,bool bDemo) {

	
	
	printf("testApp::loadSong: %s\n",songName.c_str());
	songVersion = 1;	
	
	if (!bDemo) {
		ofDisableDataPath(); // be careful of threads
		ofxXmlSettings songXml;
		bool bLoaded = songXml.loadFile(ofToDocumentsPath(songName+".xml"));
		ofEnableDataPath();	
		assert(bLoaded);
		songXml.pushTag("song");
		for (int i=0; i<3; i++) {
			player[i].setMode(MANUAL_MODE);
			string sound_set = songXml.getAttribute("player", "sound_set", "", i);
			player[i].loadSet(sound_set,ofToDocumentsPath(getPlayerName(i)+"_"+songName+".xml"));
		}
		songXml.popTag();
		
		
		
	} else {
		for (int i=0; i<3; i++) {
			string str = getPlayerName(i)+"_"+songName;
			
			player[i].setMode(MANUAL_MODE);
			player[i].loadSet(str);
			
			
		}
	}
	
	
}

void testApp::changeSoundSet(string nextSoundSet) {
	this->nextSoundSet = nextSoundSet;
	songVersion = 0;
	
	
	bNeedDisplay = true;
	
	
	string str = getPlayerName(controller)+"_"+nextSoundSet;
	if (player[controller].getCurrentSoundSet()!=str) {
		//player[controller].setMode(MANUAL_MODE);
		player[controller].changeSet(str);
	}
	
	
	
}

string testApp::getCurrentSoundSetName(int playerNum) {
	return player[playerNum].getCurrentSoundSet();
	
}


string testApp::getPlayerName(int playerNum)  {
	return player[playerNum].getName();
}

void testApp::seekFrame(int frame) {
	
	//assert(songState==SONG_RENDER_VIDEO); // can be for cancelRendering
	
	//if (songState==SONG_RENDER_VIDEO) { // TODO: why 7 ? maybe because it is the ratio block per frame...the reason for the delay...
//		for (int j=0; j<7; j++) {
//			for (int i=0;i<3;i++) {
//				player[i].processWithBlocks(lBlock, rBlock);
//			}
//		}
//	}
	
	int reqBlock = (float)frame/25.0f*(float)sampleRate/(float)blockLength;
	
	for (;currentBlock<reqBlock;currentBlock++) { // TODO: or song finished...
		for (int i=0;i<3;i++) {
			player[i].processForVideo();
		}
	}
	
	for (int i=0;i<3;i++) {
		player[i].nextFrame();

	}
	
	lastRenderedFrame = frame;
	pincher.update((float)(lastRenderedFrame-pincherStart)/6);
	
}


void testApp::transitionLoop(){
	//	printf("update()\n");
	
	
	for (int i=0;i<3;i++) {
		player[i].transitionLoop();
		if (player[i].isInTransition()) {
			break;
		}
	}
}



void testApp::getTrans(int state,int controller,ofPoint &pnt,float &ts) {
	switch (state) {
		case SOLO_STATE: {
			ts = 1.17;
			
			switch (controller) {
				case 0: {
					pnt.x = -6.0;
					pnt.y = -75.0;
				} break;
				case 1: {
					pnt.x = -246.0;
					pnt.y = -75.0;
				} break;
				case 2: {
					pnt.x = -488.0;
					pnt.y = -75.0;
				} break;
			}
			
		} break;
		case BAND_STATE: {
			ts = FULL_SCREEN_SCALE;
			pnt.x = 0;
			pnt.y = 0;
		} break;
	}
}






//--------------------------------------------------------------
void testApp::draw(){
	
	
	if (!bInitialized)
		return;
	//	printf("draw()\n");
	
	ofBackground(0, 0, 0);
	
	if (getSongState()==SONG_RENDER_VIDEO) {
		if (getState()==SOLO_STATE) {
			ofPushMatrix();
			ofScale(FULL_SCREEN_SCALE*2/3, FULL_SCREEN_SCALE*2/3, 1);
			ofTranslate(0, 80, 0);
			render();
			ofPopMatrix();
		} else {
			render();
		}

		
		return;
	}
	

	ofPushMatrix();
	
		
	if (bTrans || state == BAND_STATE) {
		
		ofPoint pnt;
		float scale;
		getTrans(state, controller, pnt, scale);	
		
		
		if (bTrans) {
			float t = (float)(ofGetElapsedTimeMillis() - animStart)/250.0;
			if (t >= 1) {
				bTrans = false;
			} else {
				ofPoint pnt2;
				float scale2;
				
				getTrans(state == BAND_STATE ? SOLO_STATE : BAND_STATE, controller, pnt2, scale2);
				
				scale = easeInOutQuad(t,scale2,scale);
				pnt.x = easeInOutQuad(t,pnt2.x,pnt.x);
				pnt.y = easeInOutQuad(t,pnt2.y,pnt.y);
			}
			
		}
		
				
		ofScale(scale, scale, 1.0);
		ofTranslate(pnt.x, pnt.y, 0.0);
		
	}  else {
		slider.update();
		slider.transform();
	}

	background.draw(0,0);
	
	for(int i=0;i<3;i++) {
		player[i].draw();
	}
	
	ofPopMatrix();
	
}



void testApp::render(){
	
	if (!bInitialized) {
		return;
	//	printf("draw()\n");
	}
	
	
	ofPushMatrix();
	pincher.transform();
		
	background.draw(0,0);
	
	int i;
	for(i=0;i<3;i++)
		player[i].draw();
	
		
	ofPopMatrix();
}

void testApp::release() {
	printf("exit()\n");
	//stopThread();
	for (int i=0;i<3;i++) {
		//setMode(i,MANUAL_MODE);
		player[i].release();
	}
	//song.exit();
}




void testApp::buttonPressed(int button) {
	
	if (songState == SONG_TRIGGER_RECORD) {
		startRecording();
	}
	
	
	if ( !player[controller].isInTransition()) {	// player[controller].isEnabled() &&				
		if ( player[controller].getMode() == MANUAL_MODE ) {
			player[controller].play(button);	
		}
		
		if ( player[controller].getMode() == LOOP_MODE ) {
			player[controller].changeLoop(button);		
			bNeedDisplay = true;
		}			
	}
		
}




//--------------------------------------------------------------
void testApp::touchDown(float x, float y, int touchId) {
	
	//printf("touchDown: %.f, %.f %i\n", x, y, touchId);
	
	if ( isInTransition()) {
		return;
	}
	
	switch (getSongState()) {
		case SONG_RENDER_VIDEO:
			pincher.touchDown(x, y, touchId);
		case SONG_RENDER_VIDEO_FINISHED:
		case SONG_RENDER_AUDIO:
		case SONG_RENDER_AUDIO_FINISHED:
		case SONG_CANCEL_RENDER_AUDIO:
			return;
			break;
		default:
			break;
	}
	
	if (touchId!=0)
		return;
	
	switch (state) {
		case BAND_STATE: {
			
			
			int xmod = (int)x % 160;
			if (xmod>25 && xmod < 135 && y>75 && y<245) {
				controller = (int)x/160;
				if (songState!=SONG_PLAY && songState!=SONG_RENDER_VIDEO) {
					player[controller].setPush(true);
					bPush = true;
				}
				
			}
			
		} break;
		case SOLO_STATE: {
			if (x>50 && x<270 && y>100 && y<350 && (songState!=SONG_PLAY && songState!=SONG_RENDER_VIDEO)) {
				player[controller].setPush(true);
				bPush = true;
			}
			
			slider.touchDown(x, y, touchId);
			break;
		}
	}
	
}


	
	
	
	

void testApp::touchMoved(float x, float y, int touchId) {
	
	//printf("touchMoved: %.f, %.f %i\n", x, y, touchId);
	
	if ( isInTransition()) {
		return;
	}
	
	switch (getSongState()) {
		case SONG_RENDER_VIDEO:
			pincher.touchMoved(x, y, touchId);
		case SONG_RENDER_VIDEO_FINISHED:
		case SONG_RENDER_AUDIO:
		case SONG_RENDER_AUDIO_FINISHED:
		case SONG_CANCEL_RENDER_AUDIO:
			return;
			break;
		default:
			break;
	}
	
	if (touchId!=0) // || bButtonDown) 
		return;
	
	if (getState() == SOLO_STATE) {
		slider.touchMoved(x, y, touchId);
		if (bPush) {
			bPush = false;
			player[controller].setPush(false);
		}		
	}
	
	
	
	
}


void testApp::touchUp(float x, float y, int touchId) {
	//printf("touchUp: %.f, %.f %i\n", x, y, touchId);
	
	switch (getSongState()) {
		case SONG_RENDER_VIDEO:
			pincher.touchUp(x, y, touchId);
		case SONG_RENDER_VIDEO_FINISHED:
		case SONG_RENDER_AUDIO:
		case SONG_RENDER_AUDIO_FINISHED:
		case SONG_CANCEL_RENDER_AUDIO:
			return;
			break;
		default:
			break;
	}
	
	if (touchId!=0)
		return;
	
	slider.touchUp(x, y, touchId);
	
//	if (bMenu) {
//		return;
//	}
	
	if (bPush) {
		player[controller].setPush(false);
		bPush = false;
		setMode(controller,player[controller].getMode() == MANUAL_MODE ? LOOP_MODE : MANUAL_MODE);
		
	} else {
		if (state == SOLO_STATE) {
			bNeedDisplay = slider.getCurrentPage() != controller;
			controller = slider.getCurrentPage();
		}
	}
	
}

void testApp::touchDoubleTap(int x, int y, int touchId) {
	if (getSongState()==SONG_RENDER_VIDEO && !pincher.getIsAnimating()) {
		pincherStart = lastRenderedFrame; 
		pincher.touchDoubleTap(x, y, touchId);
	}
}

void testApp::nextLoop(int player) {
	
	switch (this->player[player].getMode()) {
		case MANUAL_MODE:
			setMode(player, LOOP_MODE);
			break;
		default:
			this->player[player].changeLoop((this->player[player].getCurrentLoop()+1)%8);
			
			bNeedDisplay = true;
			break;
	}
}

void testApp::prevLoop(int player) {
	
	
	switch (this->player[player].getMode()) {
		case MANUAL_MODE:
			setMode(player, LOOP_MODE);
			
			break;
		default:
			this->player[player].changeLoop((this->player[player].getCurrentLoop()+7)%8);
			
			bNeedDisplay = true;
			break;
	}
	
}

int testApp::getCurrentLoop(int player) {
	return this->player[player].getCurrentLoop();
}

	

float testApp::getVolume() {
	return player[controller].getVolume();
}
	
void testApp::setVolume(float vol) {
	player[controller].setVolume(vol);
}



int testApp::getBPM() {
	return bpm; 
}

void testApp::setBPM(int bpm) {
	this->bpm = bpm;
	
	for (int i=0;i<3;i++) {
		player[i].setBPM(this->bpm);
	}
}

void testApp::renderAudio() {
	
	setSongState(SONG_RENDER_AUDIO);
		
	cout << "renderAudio started" << endl;
	
	song.openForSave(ofToDocumentsPath("temp.caf"));
	
	
	currentBlock = 0;
	
	while (getIsPlaying()) { // (getSongState()==SONG_RENDER_AUDIO || getSongState()==SONG_CANCEL_RENDER_AUDIO) {
	// this need to fix smooth the transition from AUDIO_RENDERING to VIDEO_RENDERING
		
		memset(lBlock, 0, blockLength*sizeof(float));
		memset(rBlock, 0, blockLength*sizeof(float));
		
		for (int i=0;i<3;i++) {
			player[i].processWithBlocks(lBlock, rBlock);
		}
		
		for (int i = 0; i < blockLength; i++){
			lBlock[i] *= GLOBAL_GAIN;
			rBlock[i] *= GLOBAL_GAIN;
		}
		
		
		song.saveWithBlocks(lBlock, rBlock);
		currentBlock++;
	}
	
	song.close();	
	
	cout << "renderAudio finished" << endl;
	
	for (int i=0;i<3;i++) {
		if (player[i].getSongState()!=SONG_IDLE) {
			player[i].setSongState(SONG_IDLE);
		}
	}
	bNeedDisplay = true;
	
	setSongState(SONG_RENDER_AUDIO_FINISHED);
	
	totalBlocks = currentBlock;
	
}


void testApp::startRecording() {
	setSongState(SONG_RECORD);
	startRecordingTime = ofGetElapsedTimeMillis();
	
}

void testApp::setSongState(int songState) {
	
	if (songState == SONG_RENDER_VIDEO) {
		pincher.setup(ofPoint(0,0), FULL_SCREEN_SCALE,pincherPrefs(480,320,ofRectangle(0,0,762,508),FULL_SCREEN_SCALE,1.8));
	}
	
	// song is valid and can Overwritten only when FINISHING RECORD
	if (this->songState==SONG_RECORD && songState!=SONG_RECORD) {
		songVersion++;
	}
	
	if (this->songState==SONG_RENDER_VIDEO && songState!=SONG_RENDER_VIDEO) {
		currentFrame =(ofGetElapsedTimeMillis()-startTime)  / 40;
	}
		
	this->songState = songState;
	
	if (songState == SONG_RENDER_AUDIO || songState == SONG_RENDER_VIDEO) {
		duration = 0;
		
		for (int i=0;i<3;i++) {
			float temp = player[i].getDuration();
			if (temp > duration) {
				duration = temp;
			}
		}
	}		
	
	if (songState == SONG_RENDER_VIDEO) { 
		currentBlock = 0;
	}
	
	for (int i=0;i<3;i++) {
		player[i].setSongState(songState);
	}
	
	bNeedDisplay = true;
	
	//	bool bRecord = MidiTrack::GetSongMode() == SONG_RECORD;
	//	MidiTrack::SetSongMode(SONG_IDLE);
	//	for (int i=0;i<3;i++)
	//		this->player[i].getMidiTrack()->setMode(MANUAL_MODE,false);
	//	
	//	if (bRecord) {
	//		saveMidi();
	//	}
							
	
	
}

int  testApp::getSongState() { 
	
	return songState;
}


bool testApp::getIsPlaying() {
	
	for (int i=0;i<3;i++) {
		if (player[i].getIsPlaying()) {
			return true;
		}
	}
	return false;
}
		
			

void testApp::saveSong(string songName) {
	
	printf("testApp::saveSong: %s\n",songName.c_str());

	
	ofxXmlSettings songXml;
	ofDisableDataPath();
	
	songXml.addTag("song");
	songXml.pushTag("song");
	for (int i=0; i<3; i++) {
		songXml.addTag("player");
		songXml.addAttribute("player", "sound_set", player[i].getCurrentSoundSet(), i);
		player[i].saveSong(ofToDocumentsPath(getPlayerName(i)+"_"+songName+".xml"));
	}
	songXml.popTag();
	
	songXml.saveFile(ofToDocumentsPath(songName+".xml"));
	ofEnableDataPath();	
	songVersion = 1;
	bNeedDisplay = true;
	
	
	
	
}

int testApp::getSongVersion() {
	return songVersion;
}




	
void testApp::soundStreamSetup() {
	
	
	ofSoundStreamSetup(2,0,this, sampleRate, blockLength, 4);
}

void testApp::soundStreamStart() {
	if (bInitialized) {
		ofSoundStreamStart();
	}
	
}

void testApp::soundStreamStop() {
	ofSoundStreamStop();
}

void testApp::soundStreamClose() {
	ofSoundStreamClose();
}
