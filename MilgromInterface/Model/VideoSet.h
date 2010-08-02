//
//  VideoSet.h
//  MilgromInterface
//
//  Created by Roee Kremer on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface VideoSet :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * videoSetName;
@property (nonatomic, retain) NSString * filename;

@end



