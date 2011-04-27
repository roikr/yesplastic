//
//  Song.h
//  Milgrom
//
//  Created by Roee Kremer on 4/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class SoundSet;

@interface Song :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * bReady;
@property (nonatomic, retain) NSNumber * bRingtoneExprted;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSNumber * bDemo;
@property (nonatomic, retain) NSNumber * bLocked;
@property (nonatomic, retain) NSString * songName;
@property (nonatomic, retain) NSNumber * bpm;
@property (nonatomic, retain) NSNumber * bVideoRendered;
@property (nonatomic, retain) NSSet* soundSets;

@end


@interface Song (CoreDataGeneratedAccessors)
- (void)addSoundSetsObject:(SoundSet *)value;
- (void)removeSoundSetsObject:(SoundSet *)value;
- (void)addSoundSets:(NSSet *)value;
- (void)removeSoundSets:(NSSet *)value;

@end

