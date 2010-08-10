//
//  Set.h
//  MilgromInterface
//
//  Created by Roee Kremer on 8/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Set :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * setName;
@property (nonatomic, retain) NSString * filename;
@property (nonatomic, retain) NSNumber * bReady;

@end



