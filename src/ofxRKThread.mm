//
//  RKMusicXMLParser.m
//  deadMidiPlayerAQ
//
//  Created by Roee Kremer on 9/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ofxRKThread.h"

@interface RKThread : NSObject {
	
    NSThread *internalThread;
   	
@private
	ofxRKThread *myThread;
}

@property (nonatomic, retain) NSThread *internalThread;

- (void)startWithThreadedObject:(ofxRKThread*) aThread;
- (void)threadedFunction:(id)anArgument;
- (void)stop;

@end



@implementation RKThread


@synthesize internalThread;

- (void)startWithThreadedObject:(ofxRKThread*) aThread {
    myThread = aThread;
	internalThread = [[NSThread alloc] initWithTarget:self selector:@selector(threadedFunction:) object:nil];
	[internalThread start];
	//[NSThread detachNewThreadSelector:@selector(threadedFunction:) toTarget:self withObject:nil];
}

- (void)threadedFunction:(id)anArgument {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	myThread->threadedFunction();
	[pool release];
	
}

- (void)stop {
	[internalThread cancel];
}

@end

struct threadContainer {
	RKThread *objThread;
};

void ofxRKThread::startThread() {
	container = new threadContainer;
	container->objThread =[RKThread alloc];
	[container->objThread startWithThreadedObject:this];
}

void ofxRKThread::stopThread() {
	[container->objThread stop];
	delete container;
	container = 0;
}



