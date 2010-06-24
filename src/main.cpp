
#include "ofMain.h"
#include "testApp.h"
#include "Constants.h"


int main(int argc, char *argv[]) {
	ofSetupOpenGL(SCREEN_WIDTH,SCREEN_HEIGHT, OF_FULLSCREEN);			// <-------- setup the GL context

	ofRunApp(new testApp);
}
