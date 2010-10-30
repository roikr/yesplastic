
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
		
	
	scale = 480.0/ 762.0;
	
	string filename = "images/background.pvr";
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
	 
	 
	
	controller = 1;
	setState(SOLO_STATE);
	
	bTrans = false;
	bMove = false;
	bMenu = false;
	bPush = false;
	
	
	sampleRate 			= 44100;
	blockLength = 256;
	

	lBlock = new float[blockLength];
	rBlock = new float[blockLength];

	bpm = 120; // TODO: send bpm to players
	song.setupForSave(blockLength);
		
	soundStreamSetup();
	ofSeedRandom();
	
	bInitialized = true;
	
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
		output[i*nChannels] = lBlock[i];
		output[i*nChannels + 1] = rBlock[i];
	}
	
}





float testApp::getProgress() {
	
	if (isInTransition()) {
		float progress = 0.0f;
		
		for (int i=0;i<3;i++)
			progress+=player[i].getProgress();
		
		return progress/3.0;
	} 
	
	return 0.0f;
}

float testApp::getPlayhead() {
	
// TODO: return playhead 
	/*
	if (songState == SONG_RENDER_AUDIO || songState == SONG_RENDER_VIDEO || songState == SONG_PLAY) {
		return player[2].getPlayhead();
	}
	 */
	
	return songState == SONG_RENDER_VIDEO && totalBlocks!=0 ? (float)currentBlock/(float)totalBlocks : 0.0f;
}


int testApp::getMode(int player) {
	return this->player[controller].getMode();
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
		default:
			break;
	}
	bNeedDisplay = true;
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

void testApp::loadSong(string songName,bool bDemo) {

	bIsSongOverwritten = false;
	bIsSongValid = true;
	
	printf("testApp::loadSong: %s\n",songName.c_str());
		
	
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
	bIsSongValid = false;
	
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
	switch (playerNum) {
		case 0:
			return "GTR";
			break;
		case 1:
			return "VOC";
			break;
		case 2:
			return "DRM";
			break;
		default:
			return "";
			break;
	}
}

void testApp::seekFrame(int frame) {
	
	assert(songState==SONG_RENDER_VIDEO);
	
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
	
}


void testApp::update(){
	//	printf("update()\n");
	
	
	if (songState==SONG_RECORD) {
		if (ofGetElapsedTimeMillis()-startRecordingTime > 30000) {
			setSongState(SONG_IDLE);
		}
	}
	
	
	for (int i=0;i<3;i++) {
		player[i].update();
		if (player[i].isInTransition()) {
			break;
		}
	}
	
	
	if (isInTransition()!=bInTransition) {
		bInTransition = !bInTransition;
		bNeedDisplay = true;
	}
		
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

void testApp::nextFrame() {
	for (int i=0;i<3;i++) {
		player[i].nextFrame();
	}
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
	
	if (!bInitialized)
		return;
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
			
			if (bPush) {
				bPush = false;
				player[controller].setPush(false);
			}
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
	
//	int x;
//	int y;
//	
//	if (!bTrans ) {
//		switch (state) {
//			case SOLO_STATE:
//			{
//				if (!bMove && measures.empty() && !bMenu) 
//					for (i=0;i<8;i++) {
//						
//						y = 360+(i/4) * 60;
//						x = 10+(i%4)*80;
//						if (player[controller].getMode() == MANUAL_MODE)
//							buttons.draw(x,y,i*60,controller*2*60,60,60,bButtonDown && i==button ?  1.0f : 0.4f );
//						else
//							buttons.draw(x,y,i*60,(controller*2+1)*60,60,60,i==player[controller].getCurrentLoop() ?  1.0f : 0.4f );
//					}
//				
//			} break;
//			case BAND_STATE:
//			
//			{
//				
//				/*
//				for (i=0;i<8;i++) 
//					if (player[controller].getMidiTrack()->getMode() == MANUAL_MODE)
//						buttons.draw(i*60,260,i*60,controller*2*60,60,60,bButtonDown && i==button ?  1.0f : 0.4f );
//					else
//						buttons.draw(i*60,260,i*60,(controller*2+1)*60,60,60,i==player[controller].getMidiTrack()->getCurrentLoop() ?  1.0f : 0.4f );
//				*/
//				
//				
//					
//				
//				if (!measures.empty() ) 
//					buttons.draw(50+controller*160,260,nextLoopNum*60,(controller*2+1)*60,60,60,  1.0f );
//				
//			} 
//			 
//			break;
//				
//		}
//		
//		
//		//for(i=0;i<3;i++) {
//			/*
//			float alpha =1.0f;
//			if (state==BAND_STATE && player[i].getMidiTrack()->getMode() == MANUAL_MODE) {
//				alpha = 1.0f;
//			} 
//			
//			if (player[i].bFade) {
//				float t = (float)(time - player[i].fadeStart)/250.0;
//				if (t >= 1) 
//					player[i].bFade = false;
//				else {
//					alpha = easeInOutQuad(t,alpha > 0.0f ? 0.0f : 1.0f,ty);
//				}
//					
//			}
//			 */
//			//player[i].mask.draw(player[i].mask_x*scale,0,player[i].mask_width,320,1.0f);
//			//player[i].mask.draw(player[i].mask_x*scale,0,0,0,player[i].mask_width,320,0.0f);
//		//
//	//}
//		 
//		
//		/*
//		if (menu.mode != MENU_IDLE && !bTrans) 
//			menu.draw();
//		 */
//	}
//	
//	
//	/*
//	 
//	 ui.draw(10,0,bPlay ? 90 : 10,0,20,20,bPlay ? 1.0f : 0.4f);
//	 ui.draw(450,0,bRecord ? 370 : 450,0,20,20,bRecord ? 1.0f : 0.4f);
//	 
//	 if (bpmDown) {
//	 ui.draw(40,0,40,0,20,20,1.0f);
//	 ui.draw(420,0,420,0,20,20,1.0f);
//	 ui.draw((bpmVal - 50.0)/150.0 * 380.0 + 40.0,0,60,0,20,20,1.0f);
//	 }
//	 else
//	 ui.draw((float)(MidiTrack::GetBPM() - 50)/150.0 * 380.0 + 40.0,0,60,0,20,20,0.4f);
//	 */
	
	
	
}

void testApp::exit() {
	printf("exit()\n");
	//stopThread();
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
	
	
	switch (state) {
		case BAND_STATE: {
			int xmod = (int)x % 160;
			if (xmod>25 && xmod < 135 && y>75 && y<245) {
				controller = (int)x/160;
				player[controller].setPush(true);
				bPush = true;
			}
			
			
			//nextLoopNum = player[controller].getCurrentLoop();
		} break;
		case SOLO_STATE: {
			if (x>50 && x<270 && y>100 && y<350) {
				player[controller].setPush(true);
				bPush = true;
			}
			
			measure m;
			m.x = x;
			m.y = y;
			m.t = ofGetElapsedTimeMillis();
			measures.push_back(m);
			break;
		}
	}
	/*
	if (state==SOLO_STATE && y>=360) {
		button = 4*(((int)y-360)/60)+(int)x/80;
		
		buttonPressed(button);
		bButtonDown = true; // for view 
	} */
	
}


	
	
	
	

void testApp::touchMoved(float x, float y, int touchId) {
	//printf("touchMoved: %.f, %.f %i\n", x, y, touchId);
	
	if (touchId!=0) // || bButtonDown) 
		return;
	
	measure m;
	m.x = x;
	m.y = y;
	m.t = ofGetElapsedTimeMillis();

	measures.push_back(m);
	
	/*
	switch (state) {
		case SOLO_STATE: 
			
			break;
		case BAND_STATE:
			
			nextLoopNum = (player[controller].getCurrentLoop() + (measures.back().y-measures.front().y) / 40 + 8) % 8;
			
			break;
	}
	 */
}


void testApp::touchUp(float x, float y, int touchId) {
	//printf("touchUp: %.f, %.f %i\n", x, y, touchId);
	
	if (touchId!=0 || bMenu) {
		if (!measures.empty()) { 
			measures.clear();
		}
		return;
	}
	
	if (bPush) {
		player[controller].setPush(false);
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
					
					
					bNeedDisplay = true; // TODO: is this exact ?
					
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
			
			
		/*
		case BAND_STATE: 
			
			if (player[controller].getCurrentLoop() != nextLoopNum ) 
				player[controller].changeLoop(nextLoopNum);
			
			break;
		 */
	}
	
	if (bPush) {
		bPush = false;
			
		//if (measures.size()<=1 ) { // && !bButtonDown
			setMode(controller,player[controller].getMode() == MANUAL_MODE ? LOOP_MODE : MANUAL_MODE);
		//}
	}
	
	measures.clear();
//	bButtonDown = false;
	
	
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
	
	song.open(ofToDocumentsPath("temp.wav"));
	
	
	int block = 0;
	
	while (getSongState()==SONG_RENDER_AUDIO) {
		
		
		memset(lBlock, 0, blockLength*sizeof(float));
		memset(rBlock, 0, blockLength*sizeof(float));
		
		for (int i=0;i<3;i++) {
			player[i].processWithBlocks(lBlock, rBlock);
		}
		
		song.saveWithBlocks(lBlock, rBlock);
		block++;
	}
	
	song.close();	
	
	cout << "renderAudio finished" << endl;
	
	totalBlocks = block;
	
}


void testApp::startRecording() {
	setSongState(SONG_RECORD);
	startRecordingTime = ofGetElapsedTimeMillis();
	
}

void testApp::setSongState(int songState) {
	
	// song is valid and can Overwritten only when FINISHING RECORD
	if (this->songState==SONG_RECORD && songState!=SONG_RECORD) {
		bIsSongOverwritten = true;
		bIsSongValid = true;
	}
		
	this->songState = songState;
	
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

int  testApp::getSongState() { // should be called frequently to observe changes
	
	if (songState == SONG_TRIGGER_RECORD) {
		for (int i=0; i<3; i++) {
			if (getMode(i) == LOOP_MODE) {
				startRecording();
				break;
			}
		}
		
	}
	
	switch (songState) {
		case SONG_PLAY:
		case SONG_RENDER_AUDIO:
		case SONG_RENDER_VIDEO:
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
			
		default:
			break;
	}
	
	
	
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

	bIsSongOverwritten = false;
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
	bNeedDisplay = true;
	
	
}

bool testApp::isSongValid() {
	return bIsSongValid;
}


bool testApp::isSongOverwritten() {
	return bIsSongOverwritten;
}


	
void testApp::soundStreamSetup() {
	
	
	ofSoundStreamSetup(2,0,this, sampleRate, blockLength, 4);
}

void testApp::soundStreamStart() {
	ofSoundStreamStart();
}

void testApp::soundStreamStop() {
	ofSoundStreamStop();
}

void testApp::soundStreamClose() {
	ofSoundStreamClose();
}
