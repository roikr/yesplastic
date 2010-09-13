//
//  SoundSet.h
//  Milgrom
//
//  Created by Roee Kremer on 9/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Set.h"

@class Song;
@class VideoSet;

@interface SoundSet :  Set  
{
}

@property (nonatomic, retain) NSNumber * playerNum;
@property (nonatomic, retain) Song * demo;
@property (nonatomic, retain) VideoSet * videoSet;

@end



