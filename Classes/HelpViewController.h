//
//  HelpViewController.h
//  MilgromInterface
//
//  Created by Roee Kremer on 7/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HelpViewController : UIViewController {
	UIScrollView *scrollView;
}


@property (nonatomic,retain) IBOutlet UIScrollView *scrollView;

- (void) exit:(id)sender;
@end
