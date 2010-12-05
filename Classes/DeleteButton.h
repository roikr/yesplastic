//
//  DeleteButton.h
//  Milgrom
//
//  Created by Roee Kremer on 12/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Song;

@interface DeleteButton : UIButton {
	Song *song;
}

@property (nonatomic,retain) Song *song;

@end
