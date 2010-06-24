//
//  RKMusicXMLParser.m
//  deadMidiPlayerAQ
//
//  Created by Roee Kremer on 9/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RKMusicXMLParser.h"
#import "MidiTrack.h"

@implementation RKMusicXMLParser


@synthesize currentString, xmlData;

- (void)loadAndParse:(NSString *)path withMidiTrack:(MidiTrack *)track {
    
	
	midiTrack = track;
    done = NO;
	
	self.xmlData = [NSMutableData dataWithContentsOfFile:path];
  
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
    parser.delegate = self;
    self.currentString = [NSMutableString string];
    [parser parse];
	[parser release];
    self.currentString = nil;
    self.xmlData = nil;
	
   
}

#pragma mark NSXMLParser Parsing Callbacks

// Constants for the XML element names that will be considered during the parse. 
// Declaring these as static constants reduces the number of objects created during the run
// and is less prone to programmer error.
static NSString *kTrack_Item = @"Track";
static NSString *kEvent_Item = @"Event";
static NSString *kEvent_Absolute = @"Absolute";
static NSString *kEvent_NoteOn = @"NoteOn";



- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *) qualifiedName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:kEvent_Item]) {
        NoteOnEvent = NO;
    } else if ([elementName isEqualToString:kEvent_Absolute]) {
        [currentString setString:@""];
        storingCharacters = YES;
    } else if ([elementName isEqualToString:kEvent_NoteOn] ) {
		
		NSScanner *noteScanner = [NSScanner scannerWithString:[attributeDict valueForKey:@"Note"]];
		[noteScanner scanInt:&note];
		NSScanner *velocityScanner = [NSScanner scannerWithString:[attributeDict valueForKey:@"Velocity"]];
        [velocityScanner scanInt:&velocity];
		
		NoteOnEvent = YES;
    }
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    //if ([elementName isEqualToString:kTrack_Item])
    //    self.midiTrack->loadLoopFinished();
	//else 
	if ([elementName isEqualToString:kEvent_Item]) {
        if (NoteOnEvent == YES)
			midiTrack->addEvent(time,note,velocity);
    } else if ([elementName isEqualToString:kEvent_Absolute]) {
		NSScanner *timeScanner = [NSScanner scannerWithString:currentString];
		[timeScanner scanInt:&time];
	} 
	storingCharacters = NO;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (storingCharacters) [currentString appendString:string];
}

/*
 A production application should include robust error handling as part of its parsing implementation.
 The specifics of how errors are handled depends on the application.
 */
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    // Handle errors as appropriate for your application.
}


@end


void MidiTrack::loadLoop(string filename) {
	
	[[RKMusicXMLParser alloc] loadAndParse:[NSString stringWithCString:filename.c_str()] withMidiTrack:this];
	
}


