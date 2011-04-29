//
//  UIViewController+Rotation.m
//  Milgrom
//
//  Created by Roee Kremer on 4/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIViewController+Rotation.h"


@implementation UIViewController (Rotation)

int getOrientationEnumeration(UIInterfaceOrientation orientation) {
	int res = 4;
	
	switch (orientation) {
		case UIInterfaceOrientationPortrait:
			res = 0;
			break;
		case UIInterfaceOrientationLandscapeRight:
			res = 1;
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			res = 2;
			break;
		case UIInterfaceOrientationLandscapeLeft:
			res = 3;
			break;
		default:
			res = 4;
			break;
	}
	
	return res;
	
}

- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration completion:(void (^)(void))completionHandler {
	NSLog(@"rotateToInterfaceOrientation %u",toInterfaceOrientation );
	
	
	[UIView animateWithDuration:duration delay:0 options: UIViewAnimationOptionTransitionNone | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction// UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse |
					 animations:^{
						 //self.view.frame = CGRectMake(0.0, 0.0, 320.0, 480.0);
						 self.view.transform = CGAffineTransformIdentity;
						 
						 switch (toInterfaceOrientation) {
							 case UIInterfaceOrientationPortrait: 
								 self.view.transform = CGAffineTransformMakeRotation(0);
								 break;
							 case UIInterfaceOrientationLandscapeRight: 
								 self.view.transform = CGAffineTransformMakeRotation(0.5*M_PI);
								 break;
							 case UIInterfaceOrientationPortraitUpsideDown: 
								 self.view.transform = CGAffineTransformMakeRotation(M_PI);
								 break;
							 case UIInterfaceOrientationLandscapeLeft: 
								 self.view.transform = CGAffineTransformMakeRotation(1.5*M_PI);
								 break;
						 }
						 
						 switch (toInterfaceOrientation) {
							 case UIInterfaceOrientationPortrait: 
							 case UIInterfaceOrientationPortraitUpsideDown: 
								 self.view.bounds = CGRectMake(0.0f, 0.0f, 320.0f, 480.0f);
								 break;
							 case UIInterfaceOrientationLandscapeRight: 
							 case UIInterfaceOrientationLandscapeLeft: 
								 self.view.bounds = CGRectMake(0.0f, 0.0f, 480.0f, 320.0f);
								 break;
						 }
						 
						 self.view.center = CGPointMake(160.0f, 240.0f);
						 
						 
						 
					 } 
					 completion:^(BOOL finished) {
						 if (completionHandler) {
							 completionHandler();
						 }
						 
					 }
	 ];
}

@end
