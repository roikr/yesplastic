//
//  SongCell.m
//  MilgromInterface
//
//  Created by Roee Kremer on 7/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SongCell.h"
#import "CustomFontLabel.h"
#import "SongsTable.h"
#import "Song.h"
#import "MilgromMacros.h"
#import "MilgromInterfaceAppDelegate.h"
#import "SoundSet.h"
#import "VideoSet.h"

@interface NSObject (PrivateMethods)


@end


@implementation SongCell

@synthesize label;
@synthesize lock;
@synthesize deleteButton;
@synthesize songsTable;



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];
	
	self.backgroundView.hidden = selected;
	self.selectedBackgroundView.hidden = !selected;

    // Configure the view for the selected state
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animate {
	if (editing) {
		deleteButton.hidden = NO;
	} else {
		deleteButton.hidden = YES;
	}	
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	[super setHighlighted:highlighted animated:animated];
	//
//	CGRect oldFrame = self.label.frame;
//	oldFrame.origin.x = (highlighted && !self.selected ) ? 45 : 40;
//	oldFrame.origin.y = (highlighted && !self.selected) ? 5 : 0;
//	self.label.frame = oldFrame;
	
	
//	
//    CGFloat newX = location.x; // + oldFrame.size.width / 2.0;
//    CGFloat newY = location.y; // + oldFrame.size.height / 2.0;
//	
//    CGRect newFrame = CGRectMake(newX, newY, oldFrame.size.width, oldFrame.size.height);
//	
//    self.optionsView.frame = newFrame;
	 
	 //self.label.frame.origin.x= highlighted ? 5 : 0;
	 //self.label.frame.origin.y= highlighted ? 5 : 0;
}
 
- (void) updateBackgroundWithNumber:(NSInteger)num {
	NSArray * cells = [NSArray arrayWithObjects:@"CELL1.png",@"CELL2.png",@"CELL3.png",@"CELL4.png",@"CELL5.png",nil];
	//NSArray * cells_pressed = [NSArray arrayWithObjects:@"CELL1_PRESS.png",@"CELL2_PRESS.png",@"CELL3_PRESS.png",@"CELL4_PRESS.png",@"CELL5_PRESS.png",nil];
	NSArray * cells_selected = [NSArray arrayWithObjects:@"CELL1_SELECT.png",@"CELL2_SELECT.png",@"CELL3_SELECT.png",@"CELL4_SELECT.png",@"CELL5_SELECT.png",nil];
	
	
	//[cell.bkg setImage:[UIImage imageNamed:[cellsBkgs objectAtIndex:[indexPath row]%[cellsBkgs count]]]];
	[(UIImageView*)self.backgroundView setImage:[UIImage imageNamed:[cells objectAtIndex:num%[cells count]]]];
	
	[(UIImageView*)self.backgroundView setHighlightedImage:[UIImage imageNamed:[cells_selected objectAtIndex:num%[cells_selected count]]]];
	
	[(UIImageView*)self.selectedBackgroundView setImage:[UIImage imageNamed:[cells_selected objectAtIndex:num%[cells_selected count]]]];
	//[(UIImageView*)self.selectedBackgroundView setHighlightedImage:[UIImage imageNamed:[cells_pressed objectAtIndex:num%[cells_pressed count]]]];
	
}

- (void) configureWithSong:(Song*)theSong withSongsTable:(SongsTable*)theTable {
	
	
	self.label.text = theSong.songName;
	self.songsTable = theTable;
	
	
	
	
}

- (NSNumber *)progress {
	return _progress;
}

- (void) setProgress:(NSNumber *)theProgress {
	if ([theProgress floatValue]<1.0f) {
		
		self.userInteractionEnabled = NO;
		
		CGRect frame = self.frame;
		frame.size.width  = [theProgress floatValue]*270.0;
		self.frame = frame;
		
				
	} else {
		self.userInteractionEnabled = YES;
		CGRect frame = self.frame;
		frame.size.width = 270.0;
		self.frame = frame;
		
	}
	
	_progress = theProgress;
	
}

/*
- (void)didMoveToSuperview {
	[super didMoveToSuperview];
	self.progress = self.progress;
}

- (void)didMoveToWindow {
	[super didMoveToWindow];
}
*/

- (void) delete:(id)sender {
	[songsTable deleteSong:self];
	
}

- (void)dealloc {
	[songsTable release];
    [super dealloc];
}



@end
