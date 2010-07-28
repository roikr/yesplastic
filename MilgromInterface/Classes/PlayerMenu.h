//
//  PlayerMenu.h
//  MilgromInterface
//
//  Created by Roee Kremer on 7/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SetsTable;

@interface PlayerMenu : UIViewController {
	SetsTable *setsTable;
	UIView *setsView;
}

@property (nonatomic,retain) SetsTable *setsTable;
@property (nonatomic,retain) IBOutlet UIView *setsView;

- (void)exit:(id)sender;
@end
