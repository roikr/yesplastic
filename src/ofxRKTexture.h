#pragma once

#import <OpenGLES/ES1/gl.h>
#include <string>

using namespace std; 


class ofxRKTexture {
	
	public :
	
	void setup(string filename,int subWidth = 0,int subHeight = 0);
	
	void init();
	void release();
	
	void load();
	void unload();
	
	void bind()  ;
	void unbind() ;
	
	void draw(float x, float y);
	void draw(float x,float y,int i,float width = 0,float height = 0);
	void draw(float x,float y,float u,float v,float width,float height,float color);
	
	//float getHeight();
	//float getWidth();
	//bool getHasAlpha();
	//GLuint getName();
	
protected:
	
	
	int _subWidth;
	int _subHeight;
	int _columnsNumber;
	//float _rowFraction;
	//float _columnFraction;
	bool bAtlas;
	
	string filename;
	
	GLuint _name;
	uint32_t _width, _height;
	GLenum _internalFormat;
	bool _hasAlpha;
	
};




