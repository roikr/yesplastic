//
//  ShareViewController.h
//  Milgrom
//
//  Created by Roee Kremer on 8/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomImageView;
@class AVAssetExportSession;
@class ActionCell;

@interface ShareViewController : UITableViewController<UINavigationControllerDelegate,UIActionSheetDelegate> {
	ActionCell *tmpCell;
	
	CustomImageView *progressView;
	BOOL bRender;
	BOOL bYouTubeUploaded;
	BOOL bFaceBookUploaded;
	
	NSArray	*dataSourceArray;
}

@property (nonatomic,assign) IBOutlet ActionCell *tmpCell;

@property (nonatomic,retain) NSNumber *progress;
@property (nonatomic,retain) IBOutlet CustomImageView *progressView;
@property BOOL bRender;
@property (nonatomic, retain) NSArray *dataSourceArray;


- (void)done:(id)sender;
- (void)play:(id)sender;
- (void)youTube:(id)sender;
- (void)render;
- (void)action;

@end
