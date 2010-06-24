#ifndef _SIMPLE_PLAYER
#define _SIMPLE_PLAYER

#include "ofMain.h"


#include <map> // for iPhone


#include "ofxRKActor.h"
#include "TexturesPlayer.h"


class SimplePlayer : public TexturesPlayer {

public:
	SimplePlayer() {};
	void setup(string setName);
	void update();
	void translate();
	void draw();
	void exit();
	
	void play(int i);
	void setState(int state);
	void setFont(ofTrueTypeFont * font);
	
	void initIn();
	void prepareIn();
	void initSet();
	void prepareSet();
	void prepareOut();
	void finishOut();
	void releaseSet();
	
	
	//int sequencesNumber();
	void startTransition(bool bPlayIn);
	bool didTransitionEnd();
	float getScale();
	string displayName;
	

private:
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
	
	
};

#endif