/*
 *  ofMain.cpp
 *  YesPlastic
 *
 *  Created by Roee Kremer on 1/19/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "ofMain.h"
#include <OpenGLES/ES1/gl.h>

#include "sys/time.h" // for gettimeofday

#include <sstream>  //for ostringsream
#include <iomanip>  //for setprecision

#include <dirent.h> 
#include <sys/stat.h> 

//--------------------------------------------------
string ofToDataPath(string path, bool makeAbsolute){	
	return ofToDocumentsPath("data/"+path);
}


string ofToDocumentsPath(string path){
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	string documentsPathRoot = [documentsDirectory UTF8String];
	path = documentsPathRoot+"/"+path;
	
	return path;
}

string ofToResourcesPath(string path){
	
	//----- DAMIAN
	// set data path root for ofToDataPath()
	// path on iPhone will be ~/Applications/{application GUID}/openFrameworks.app/data
	// get the resource path for the bundle (ie '~/Applications/{application GUID}/openFrameworks.app')
	NSString *bundle_path_ns = [[NSBundle mainBundle] resourcePath];
	// convert to UTF8 STL string
	string dataPathRoot = [bundle_path_ns UTF8String];
	// append data
	dataPathRoot.append( "/data/" ); // ZACH
	//dataPathRoot.append( "/" ); // ZACH
	//printf("setting data path root to '%s'\n", dataPathRoot.c_str() );
	
	
	//check if absolute path has been passed or if data path has already been applied
	//do we want to check for C: D: etc ?? like  substr(1, 2) == ':' ??
	if( path.substr(0,1) != "/" && path.substr(0,dataPathRoot.length()) != dataPathRoot){
		path = dataPathRoot+path;
	}	
	
	return path;
}


//--------------------------------------------------
void ofLog(int logLevel, string message){
	
	/*
	if(logLevel == OF_LOG_VERBOSE){
		printf("OF_VERBOSE: ");
	}
	else if(logLevel == OF_LOG_NOTICE){
		printf("OF_NOTICE: ");
	}
	else if(logLevel == OF_LOG_WARNING){
		printf("OF_WARNING: ");
	}
	else if(logLevel == OF_LOG_ERROR){
		printf("OF_ERROR: ");
	}
	else if(logLevel == OF_LOG_FATAL_ERROR){
		printf("OF_FATAL_ERROR: ");
	}
	 */
	printf("%s\n",message.c_str());	
	
}

//--------------------------------------------------
void ofLog(int logLevel, const char* format, ...){
	//thanks stefan!
	//http://www.ozzu.com/cpp-tutorials/tutorial-writing-custom-printf-wrapper-function-t89166.html
	va_list args;
	va_start( args, format );
	if(logLevel == OF_LOG_VERBOSE){
		printf("OF_VERBOSE: ");
	}
	else if(logLevel == OF_LOG_NOTICE){
		printf("OF_NOTICE: ");
	}
	else if(logLevel == OF_LOG_WARNING){
		printf("OF_WARNING: ");
	}
	else if(logLevel == OF_LOG_ERROR){
		printf("OF_ERROR: ");
	}
	else if(logLevel == OF_LOG_FATAL_ERROR){
		printf("OF_FATAL_ERROR: ");
	}
	vprintf( format, args );
	printf("\n");
	va_end( args );
	
		
	
}

void ofSetLogLevel(int logLevel) {
}

//--------------------------------------------------
string ofToString(double value, int precision){
	stringstream sstr;
	sstr << fixed << setprecision(precision) << value;
	return sstr.str();
}

//--------------------------------------------------
string ofToString(int value){
	stringstream sstr;
	sstr << value;
	return sstr.str();
}

//our openGL wrappers
//----------------------------------------------------------
void ofPushMatrix(){
	glPushMatrix();
}

//----------------------------------------------------------
void ofPopMatrix(){
	glPopMatrix();
}

//----------------------------------------------------------
void ofTranslate(float x, float y, float z){
	glTranslatef(x, y, z);
}

//----------------------------------------------------------
void ofScale(float xAmnt, float yAmnt, float zAmnt){
	glScalef(xAmnt, yAmnt, zAmnt);
}

//----------------------------------------------------------
void ofRotate(float degrees, float vecX, float vecY, float vecZ){
	glRotatef(degrees, vecX, vecY, vecZ);
}


float ofClamp(float value, float min, float max) {
	return value < min ? min : value > max ? max : value;
}

unsigned long ofGetSystemTime( ) {
	struct timeval now;
	gettimeofday( &now, NULL );
	return now.tv_usec/1000 + now.tv_sec*1000;
}

static unsigned long startTime = ofGetSystemTime();   //  better at the first frame ?? (currently, there is some delay from static init, to running.

//--------------------------------------
int ofGetElapsedTimeMillis(){
	return (int)(ofGetSystemTime() - startTime);
}


ofTrueTypeFont::ofTrueTypeFont() {}
 ofTrueTypeFont::~ofTrueTypeFont() {}
void 		ofTrueTypeFont::loadFont(string filename, int fontsize) {}
void 		ofTrueTypeFont::drawString(string s, float x, float y) {}
void 		ofTrueTypeFont::setLineHeight(float height) {}


int ofGetWidth() {
	return 320;
}

int 		ofGetHeight() {
	return 480;
}

float 		ofGetFrameRate() {
	return 30.0f;
}

void 		ofSetFrameRate(int targetRate) {}

//--------------------------------------------------
vector<string> ofSplitString(const string& str, const string& delimiter = " "){
    vector<string> elements;
	// Skip delimiters at beginning.
    string::size_type lastPos = str.find_first_not_of(delimiter, 0);
    // Find first "non-delimiter".
    string::size_type pos     = str.find_first_of(delimiter, lastPos);
	
    while (string::npos != pos || string::npos != lastPos)
    {
        // Found a token, add it to the vector.
    	elements.push_back(str.substr(lastPos, pos - lastPos));
        // Skip delimiters.  Note the "not_of"
        lastPos = str.find_first_not_of(delimiter, pos);
        // Find next "non-delimiter"
        pos = str.find_first_of(delimiter, lastPos);
    }
    return elements;
}






