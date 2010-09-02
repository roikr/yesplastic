//
//  SaveViewController.h
//  Milgrom
//
//  Created by Roee Kremer on 8/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomFontTextField;
@interface SaveViewController : UIViewController<UITextFieldDelegate>{
	CustomFontTextField	*songName;
}

@property (nonatomic,retain) IBOutlet CustomFontTextField *songName;


- (void)cancel:(id)sender;
- (void)done:(id)sender;

@end
