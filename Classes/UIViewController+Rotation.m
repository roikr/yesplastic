//
//  UIViewController+Rotation.m
//  Milgrom
//
//  Created by Roee Kremer on 4/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIViewController+Rotation.h"


@implementation UIViewController (Rotation)


- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	NSLog(@"rotateToInterfaceOrientation %u",toInterfaceOrientation );
	[self willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	switch (toInterfaceOrientation) {
		case UIInterfaceOrientationPortrait: 
		case UIInterfaceOrientationPortraitUpsideDown: {
			[UIView animateWithDuration:duration delay:0
								options: UIViewAnimationOptionTransitionNone | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction// UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse |
							 animations:^{
								 //self.view.frame = CGRectMake(0.0, 0.0, 320.0, 480.0);
								 self.view.transform = CGAffineTransformIdentity;
								 self.view.transform = CGAffineTransformMakeRotation(0);
								 self. view.bounds = CGRectMake(0.0f, 0.0f, 320.0f, 480.0f);
								 self.view.center = CGPointMake(160.0f, 240.0f);
								 
							 } 
							 completion:^(BOOL finished) {
								 [self didRotateFromInterfaceOrientation:UIInterfaceOrientationLandscapeRight];
							 }
			 ];
		} break;
		case UIInterfaceOrientationLandscapeRight: 
		case UIInterfaceOrientationLandscapeLeft: {
			[UIView animateWithDuration:duration delay:0
								options: UIViewAnimationOptionTransitionNone | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction// UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse |
							 animations:^{
								 //self.view.frame = CGRectMake(0.0, 0.0, 480.0, 320.0);
								 self.view.transform = CGAffineTransformIdentity;
								 self.view.transform = CGAffineTransformMakeRotation(0.5*M_PI);
								 self.view.bounds = CGRectMake(0.0f, 0.0f, 480.0f, 320.0f);
								 self.view.center = CGPointMake(160.0f, 240.0f);
								 
							 } 
							 completion:^(BOOL finished){
								 [self didRotateFromInterfaceOrientation:UIInterfaceOrientationPortrait];
							 }
			 ];		
		} break;
		default:
			break;
	}
}

@end
