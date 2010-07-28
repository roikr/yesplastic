//
//  SongsTable.h
//  MilgromInterface
//
//  Created by Roee Kremer on 7/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SongCell;
@interface SongsTable : UITableViewController {
	SongCell *tmpCell;
}


@property (nonatomic,assign) IBOutlet SongCell *tmpCell;

@end
