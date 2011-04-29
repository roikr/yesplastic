//
//  UIViewController+Rotation.h
//  Milgrom
//
//  Created by Roee Kremer on 4/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIViewController (Rotation) 

- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration completion:(void (^)(void))completionHandler;

@end
