//
//  SoundSet.h
//  MilgromInterface
//
//  Created by Roee Kremer on 8/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Set.h"

@class VideoSet;

@interface SoundSet :  Set  
{
}

@property (nonatomic, retain) VideoSet * videoSet;

@end



