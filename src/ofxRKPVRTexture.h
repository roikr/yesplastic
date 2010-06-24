#pragma once

#import "ofxRKTexture.h"

@class RKPVRTexture;

class ofxRKPVRTexture {
	
	public :
	
	void init(string filename,int subWidth = 0,int subHeight = 0);
	void release();
	void load();
	void unload();
	
	
	float getWidth();
	float getHeight();
	GLenum getInternalFormat();
	bool getHasAlpha();
	GLuint getName();
	
protected:
	
	RKPVRTexture * pvrTexture;
	
	
};




