#ifndef _SIMPLE_PLAYER
#define _SIMPLE_PLAYER

#include "ofMain.h"


#include <map> // for iPhone


#include "ofxRKActor.h"
#include "TexturesPlayer.h"
#include "ofxRKTexture.h"


class SimplePlayer : public TexturesPlayer {

public:
	SimplePlayer() {};
	void setup(string setName);
	void update();
	void translate();
	void draw();
	void exit();
	
	void play(int i);
	void setPush(bool bPush);
	void setState(int state);
	void setFont(ofTrueTypeFont * font);
	
	void initIdle();
	void loadIdle();
	void unloadIdle();
	void initIn();
	void loadIn();
	void unloadIn();
	void initSet();
	void loadSet();
	void unloadSet();
	void initOut();
	void loadOut();
	void unloadOut();
	void release();
	
	
	//int sequencesNumber();
	void startTransition(bool bPlayIn);
	bool didTransitionEnd();
	float getScale();
	string displayName;
	
	float getProgress();

private:
	
	float progress;
	
	string getDebugString();
	int getCurrentFrame();
	
	string setName;
	
	int x;
	int y;
	int tx;
	int ty;
	
	int solo_x;
	int solo_y;
	float solo_scale;
	
	bool enable;
	int state;
		
	int nextSequence;
	
	ofxRKActor actor;

	ofTrueTypeFont	*font;
	
	bool bTransitionEnded;
	
	string debugStr;
	
	bool bPush;
	int pushWidth;
	int pushHeight;
	ofxRKTexture pushTexture;
	
};

#endif