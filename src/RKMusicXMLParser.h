//
//  RKMusicXMLParser.h
//  deadMidiPlayerAQ
//
//  Created by Giori politi on 9/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

class MidiTrack;


@interface RKMusicXMLParser : NSObject {

    NSMutableString *currentString;
    BOOL storingCharacters;
    NSMutableData *xmlData;
    BOOL done;
	BOOL NoteOnEvent;
	
	int time;
	int note;
	int velocity;
	
	@private
	MidiTrack *midiTrack;
}

@property (nonatomic, retain) NSMutableString *currentString;
@property (nonatomic, retain) NSMutableData *xmlData;

- (void)loadAndParse:(NSString *)path withMidiTrack:(MidiTrack *)track ;

@end
