#pragma once

#include <string>
#include <vector>
#include <map>

using namespace std; 

class ofxRKSequence;
class ofxXmlSettings;

class ofxRKActor {
	
	public :
	
	void setup(ofxXmlSettings *xml,string path);
	void init(int seq);
	
	void load(int num);
	
	void setSequence(int seq);
	//void setSequence(string seqName);
	int  getSequenceNumber(string seqName);
	string getSequenceName(int seq);
	void play();
	void pause();
	void firstFrame();
	void lastFrame();
	void update();
	void draw(int x,int y);
	void unloadSequence(int seq);
	void releaseSequence(int seq);
	void release();
	
//	void exit();
	
	void setCurrentFrame(int i);

	
	int	 getTotalNumSequences();
	bool getIsSequenceDone();
	bool getIsPlaying();
	int  getCurrentSequence();
	
	
	
protected:
	
	bool bStartSequence;
	bool bPlaying;
	
	vector<ofxRKSequence*>::iterator iter;
	vector<ofxRKSequence*> sequences;
	vector<string> sequencesNames;
	map<string,int> sequencesMap;
};




