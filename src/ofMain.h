/*
 *  ofMain.h
 *  YesPlastic
 *
 *  Created by Roee Kremer on 1/19/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#pragma once

#include <string>
#include <vector>
using namespace std;

#ifndef MIN
#define MIN(x,y) (((x) < (y)) ? (x) : (y))
#endif

enum ofLogLevel{
	OF_LOG_VERBOSE,
	OF_LOG_NOTICE,
	OF_LOG_WARNING,
	OF_LOG_ERROR,
	OF_LOG_FATAL_ERROR,
	OF_LOG_SILENT	//this one is special and should always be last - set ofSetLogLevel to OF_SILENT to not recieve any messages
};

#define OF_DEFAULT_LOG_LEVEL  OF_LOG_WARNING;

class ofTrueTypeFont{
	
public:
	
	
	ofTrueTypeFont();
	virtual ~ofTrueTypeFont();
	
	// 			-- default, non-full char set, anti aliased:
	void 		loadFont(string filename, int fontsize);
	
	void 		drawString(string s, float x, float y);
	
	void 		setLineHeight(float height);	
};



class ofBaseApp{
	
public:
	ofBaseApp() {
		mouseX = mouseY = 0;
	}
	
	virtual ~ofBaseApp(){}
	
	virtual void setup(){}
	virtual void update(){}
	virtual void draw(){}
	virtual void exit(){}
		
	virtual void windowResized(int w, int h){}
	
	virtual void keyPressed( int key ){}
	virtual void keyReleased( int key ){}
	
	virtual void touchDown(float x, float y, int touchId) {};
	virtual void touchMoved(float x, float y, int touchId) {};
	virtual void touchUp(float x, float y, int touchId) {};
	virtual void touchDoubleTap(float x, float y, int touchId) {};
	
	virtual void audioReceived( float * input, int bufferSize, int nChannels ){}
	virtual void audioRequested( float * output, int bufferSize, int nChannels ){}
	
	int mouseX, mouseY;			// for processing heads
};

typedef ofBaseApp ofSimpleApp;

string 	ofToDataPath(string path, bool absolute=false);
string ofToDocumentsPath(string path);
string ofToResourcesPath(string path);

void ofLog(int logLevel, string message);
void ofLog(int logLevel, const char* format, ...);
void ofSetLogLevel(int logLevel);

string  ofToString(double value, int precision = 7);
string  ofToString(int  value);

void ofPushMatrix();
void ofPopMatrix();
void ofTranslate(float x, float y, float z = 0);
void ofScale(float xAmnt, float yAmnt, float zAmnt = 1);
void ofRotate(float degrees, float vecX, float vecY, float vecZ);

float		ofClamp(float value, float min, float max);
int		ofGetElapsedTimeMillis();
int 		ofGetWidth();			// <-- should we call this ofGetWindowWidth?
int 		ofGetHeight();
float 		ofGetFrameRate();
void 		ofSetFrameRate(int targetRate);

vector<string>	ofSplitString(const string & text, const string & delimiter);
