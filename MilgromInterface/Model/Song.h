//
//  Song.h
//  MilgromInterface
//
//  Created by Roee Kremer on 8/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Song :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * bLoaded;
@property (nonatomic, retain) NSNumber * bLocked;
@property (nonatomic, retain) NSString * filename;
@property (nonatomic, retain) NSString * songName;
@property (nonatomic, retain) NSNumber * bDemo;

@end



