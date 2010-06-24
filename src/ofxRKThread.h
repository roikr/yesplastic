/*
 *  ofxRKThread.h
 *  deadLoops13
 *
 *  Created by Giori politi on 9/8/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

struct threadContainer;

class ofxRKThread {
public:
	virtual void threadedFunction() {};
	void startThread();
	void stopThread();

private:
	threadContainer *container;
};
