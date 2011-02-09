//
//  MilgromUtils.m
//  Milgrom
//
//  Created by Roee Kremer on 2/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MilgromUtils.h"


void MilgromAlert(NSString *title,NSString *message) {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil  cancelButtonTitle:@"OK"  otherButtonTitles: nil];
	[alert show];
	[alert release];
}


