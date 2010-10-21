//
//  ShareManager.h
//  Milgrom
//
//  Created by Roee Kremer on 10/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FacebookUploader.h"
#import "YouTubeUploader.h"

@interface ShareManager : NSObject<FacebookUploaderDelegate,YouTubeUploaderDelegate> {
	FacebookUploader *facebookUploader;
	YouTubeUploader *youTubeUploader;
}
+ (ShareManager*) shareManager;

@property (nonatomic,retain) FacebookUploader *facebookUploader;
@property (nonatomic,retain) YouTubeUploader *youTubeUploader;
@property (readonly) BOOL isUploading;

@end
