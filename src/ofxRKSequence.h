#pragma once

#include <string>
#include <vector>

using namespace std; 

class ofxRKTexture;
class ofxXmlSettings;

struct atlas {
	int start;
	int number;
	ofxRKTexture* texture;
};

class ofxRKSequence {
	
	public :
	
	void setup(ofxXmlSettings *xml,int seq,string path = "");
	void init();
	void load();
	void draw(int x,int y,int i);
	void unload();
	void release();
	void exit();
	
	void draw(int x,int y);
	void setCurrentFrame(int i);
	int getCurrentFrame();
	void firstFrame();
	void lastFrame();
	void nextFrame();
	void previousFrame();
	bool isLastFrame();
	int	 getTotalNumFrames();
	
	
	
protected:
	
	int numFrames;
	int currentFrame;
	
	string prefix;
	
	int width;
	int height;
	vector<atlas> atlases;
	
};




