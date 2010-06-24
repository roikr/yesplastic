#import "ofxRKPVRTexture.h"
#import "RKPVRTexture.h"


void ofxRKPVRTexture::init(string filename,int subWidth,int subHeight) {
	
	NSString * path = [[NSString alloc] initWithCString:filename.c_str()];
	
	//PVRTexture * pvrTexture = [PVRTexture pvrTextureWithContentsOfFile:[[NSBundle mainBundle] pathForResource:path ofType:@"pvr"]];
	pvrTexture = [[[RKPVRTexture alloc] initWithContentsOfFile:path] retain];
	
	
	if (pvrTexture == nil) {
		//ofLog(OF_LOG_VERBOSE,"loading: %s, %s",filename.c_str(),res ? "loaded" : "not loaded");
	
		NSLog(@"Failed to load %@", path);
	}
	
	[path release];
		
}

void ofxRKPVRTexture::release() {
	if (!pvrTexture)
		return;
	[pvrTexture dealloc];
	pvrTexture = nil;
}

void ofxRKPVRTexture::load() {
	if (!pvrTexture)
		return;
	[pvrTexture createGLTexture];
}

void ofxRKPVRTexture::unload() {
	if (!pvrTexture)
		return;
	[pvrTexture unload];
}

float ofxRKPVRTexture::getWidth() {
	if (!pvrTexture)
		return 0;
	return [pvrTexture width];
}


float ofxRKPVRTexture::getHeight() {
	if (!pvrTexture)
		return 0;
	return [pvrTexture height];
}

GLenum ofxRKPVRTexture::getInternalFormat() {
	if (!pvrTexture)
		return 0; 
	return [pvrTexture internalFormat];
}

bool ofxRKPVRTexture::getHasAlpha() {
	if (!pvrTexture)
		return 0;
	return [pvrTexture hasAlpha];
}

GLuint ofxRKPVRTexture::getName() {
	if (!pvrTexture)
		return 0;
	return [pvrTexture name];
}
