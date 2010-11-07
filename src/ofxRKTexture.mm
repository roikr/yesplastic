#include "ofxRKTexture.h"
#import <OpenGLES/ES1/glext.h>
#import "PVRTexture.h"
#include "ofMain.h"

void ofxRKTexture::setup(string filename,int subWidth ,int subHeight ) {
	
	
	this->filename = filename;
	
	bAtlas = subWidth; // not zero
	
	_subWidth = subWidth;
	_subHeight = subHeight;
	bInitialized = false;
	
	
	
}

void ofxRKTexture::init() {
	
	PVRTexture *texture = [PVRTexture pvrTextureWithContentsOfFile:[NSString stringWithCString:filename.c_str() encoding:NSASCIIStringEncoding]];
	_name = texture.name;
	_width = texture.width;
	_height = texture.height;
	_internalFormat = texture.internalFormat;
	_hasAlpha = texture.hasAlpha;
	
	
	_columnsNumber = _subWidth ? _width / _subWidth : 0;
	//_rowFraction = (float)_subHeight / (float)texture->getHeight();
	//_columnFraction = (float)_subWidth / (float)texture->getWidth();
	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);  // GL_NEAREST
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, 1.0f);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	
	bInitialized = true;
}

void ofxRKTexture::release() {
	if (bInitialized) {
		glDeleteTextures(1, &_name);
		//ofLog(OF_LOG_VERBOSE, "ofxRKTexture::release texture: %i",_name);
		_name = 0;
	} else {
		ofLog(OF_LOG_VERBOSE,"ofxRKTexture::release: %s has not been initialized",filename.c_str());
	}
	_columnsNumber = 0;
	//_rowFraction = 0;
	//_columnFraction = 0;
}

void ofxRKTexture::load(){
		
	
	
}


void ofxRKTexture::unload() {
}

	
void ofxRKTexture::bind() {
	
	
	glBindTexture(GL_TEXTURE_2D, _name );
}

void ofxRKTexture::draw(float x,float y,float u,float v,float width,float height,float color) {
	
	
	glEnable(GL_TEXTURE_2D);
	
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	glBindTexture(GL_TEXTURE_2D, _name );
	
	
	GLfloat fColor[4]={color,color,color,0.0f};
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE);
	glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_MODULATE);
	glTexEnvi(GL_TEXTURE_ENV, GL_SRC0_RGB,         GL_TEXTURE);
	glTexEnvi(GL_TEXTURE_ENV, GL_SRC1_RGB,         GL_CONSTANT);
	glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_ALPHA,    GL_REPLACE);
	glTexEnvi(GL_TEXTURE_ENV, GL_SRC0_ALPHA,       GL_TEXTURE);
	glTexEnvfv(GL_TEXTURE_ENV, GL_TEXTURE_ENV_COLOR, fColor);
	
	GLfloat px0 = 0;		// up to you to get the aspect ratio right
	GLfloat py0 = height;
	GLfloat px1 =width;
	GLfloat py1 = 0;
	GLfloat tx0 = u/-width;		
	GLfloat ty0 = v/_height;
	GLfloat tx1 =  tx0+width/_width;
	GLfloat ty1 = ty0+height/_height;
	
	glPushMatrix();
	
	glTranslatef(x,y,0.0f);
	
	GLfloat tex_coords[] = {
		tx0,ty0,
		tx1,ty0,
		tx1,ty1,
		tx0,ty1
	};
	GLfloat verts[] = { // flip for iPhone
		px0,py1,
		px1,py1,
		px1,py0,
		px0,py0
	};
		
	
	
	glEnableClientState( GL_TEXTURE_COORD_ARRAY );
	glTexCoordPointer(2, GL_FLOAT, 0, tex_coords );
	glEnableClientState(GL_VERTEX_ARRAY);
	glVertexPointer(2, GL_FLOAT, 0, verts );
	glDrawArrays( GL_TRIANGLE_FAN, 0, 4 );
	glDisableClientState( GL_TEXTURE_COORD_ARRAY );
	glPopMatrix();
	
	
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
	
	
	glDisable(GL_BLEND);
	glDisable(GL_TEXTURE_2D);
	
	GLenum  err = glGetError();
	if (err != GL_NO_ERROR)
		NSLog(@"Error in frame. glError: 0x%04X", err);
	
	//ofLog(OF_LOG_VERBOSE,"Error in frame. glError: %d", err);
	
	
}

void ofxRKTexture::draw(float x,float y,int i,float width,float height) {
		
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, _name );
		
	GLfloat delta = 1;
	
	GLfloat px0 = 0;		// up to you to get the aspect ratio right
	GLfloat py0 = (height ? height : _subHeight) - 2*delta;
	GLfloat px1 =(width ? width : _subWidth) - 2*delta;
	GLfloat py1 = 0;
	
	GLfloat tx0 = ((i % _columnsNumber) * _subWidth+delta)/_width;		
	GLfloat ty0 = ((i / _columnsNumber)  * _subHeight+delta)/_height;
	GLfloat tx1 =  ((i % _columnsNumber+1) * _subWidth-delta-1)/_width;
	GLfloat ty1 =  ((i / _columnsNumber+1) * _subHeight-delta-1)/_height;
	
	glPushMatrix();
	glTranslatef(x+delta,y+delta,0.0f);
	
	GLfloat tex_coords[] = {
		tx0,ty0,
		tx1,ty0,
		tx1,ty1,
		tx0,ty1
	};
	GLfloat verts[] = { // flip for iPhone
		px0,py1,
		px1,py1,
		px1,py0,
		px0,py0
	};
	
	glEnableClientState( GL_TEXTURE_COORD_ARRAY );
	glTexCoordPointer(2, GL_FLOAT, 0, tex_coords );
	glEnableClientState(GL_VERTEX_ARRAY);
	glVertexPointer(2, GL_FLOAT, 0, verts );
	glDrawArrays( GL_TRIANGLE_FAN, 0, 4 );
	glDisableClientState( GL_TEXTURE_COORD_ARRAY );
	
	glPopMatrix();
	glDisable(GL_TEXTURE_2D);
	
	GLenum  err = glGetError();
	if (err != GL_NO_ERROR)
		NSLog(@"Error in frame. glError: 0x%04X", err);
		
		//ofLog(OF_LOG_VERBOSE,"Error in frame. glError: %d", err);
	
}

void ofxRKTexture::draw(float x, float y){
	
				
	glEnable(GL_TEXTURE_2D);
				
			// bind the texture
	glBindTexture(GL_TEXTURE_2D, _name );
	
	
			
			GLfloat px0 = 0;		// up to you to get the aspect ratio right
			GLfloat py0 = 0;
			GLfloat px1 = _width;
			GLfloat py1 = _height;
			
			GLfloat tx0 = 0 ;		
			GLfloat ty0 = 1;
			GLfloat tx1 = 1;
			GLfloat ty1 = 0;
			
			glPushMatrix();
			
			glTranslatef(x,y,0.0f);
			
			GLfloat tex_coords[] = {
				tx0,ty0,
				tx1,ty0,
				tx1,ty1,
				tx0,ty1
			};
			GLfloat verts[] = { // flip for iPhone
				px0,py1,
				px1,py1,
				px1,py0,
				px0,py0
			};
			
			glEnableClientState( GL_TEXTURE_COORD_ARRAY );
			glTexCoordPointer(2, GL_FLOAT, 0, tex_coords );
			glEnableClientState(GL_VERTEX_ARRAY);
			glVertexPointer(2, GL_FLOAT, 0, verts );
			glDrawArrays( GL_TRIANGLE_FAN, 0, 4 );
			glDisableClientState( GL_TEXTURE_COORD_ARRAY );
			
			glPopMatrix();
			glDisable(GL_TEXTURE_2D);
				 
				
		GLenum err;

   	err = glGetError();
	if (err != GL_NO_ERROR)
		NSLog(@"Error in frame. glError: 0x%04X", err);
}

/*
float ofxRKTexture::getWidth() {
	return _subWidth;
}
 */

