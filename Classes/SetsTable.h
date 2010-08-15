//
//  SetsTable.h
//  MilgromInterface
//
//  Created by Roee Kremer on 7/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SetCell;
@interface SetsTable : UITableViewController {
	SetCell *tmpCell;
	
	NSArray *songsArray;
}

@property (nonatomic,assign) IBOutlet SetCell *tmpCell;
@property (nonatomic,retain) NSArray *songsArray;
@end
