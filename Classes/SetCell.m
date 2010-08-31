//
//  SetCell.m
//  MilgromInterface
//
//  Created by Roee Kremer on 7/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SetCell.h"
#import "CustomFontLabel.h"

@implementation SetCell

@synthesize label;


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


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	[super setHighlighted:highlighted animated:animated];
	
	//CGRect oldFrame = self.label.frame;
//	oldFrame.origin.x = (highlighted && !self.selected ) ? 45 : 40;
//	oldFrame.origin.y = (highlighted && !self.selected) ? 5 : 0;
//	self.label.frame = oldFrame;
}
 

- (void) configureCell:(NSInteger)num withLabel:(NSString*)theLabel {
	NSArray * cells = [NSArray arrayWithObjects:@"DRM_CELL1.png",@"DRM_CELL2.png",@"DRM_CELL3.png",nil];
	//NSArray * cells_pressed = [NSArray arrayWithObjects:@"DRM_CELL1_PUSH.png",@"DRM_CELL2_PUSH.png",@"DRM_CELL3_PUSH.png",nil];
	NSArray * cells_selected = [NSArray arrayWithObjects:@"DRM_CELL1_SELECT.png",@"DRM_CELL2_SELECT.png",@"DRM_CELL3_SELECT.png",nil];
	//NSArray * cells_progress = [NSArray arrayWithObjects:@"DRM_CELL1_PROGRESS.png",@"DRM_CELL2_PROGRESS.png",@"DRM_CELL3_PROGRESS.png",nil];
	
	
	//[cell.bkg setImage:[UIImage imageNamed:[cellsBkgs objectAtIndex:[indexPath row]%[cellsBkgs count]]]];
	[(UIImageView*)self.backgroundView setImage:[UIImage imageNamed:[cells objectAtIndex:num%[cells count]]]];
	
	[(UIImageView*)self.backgroundView setHighlightedImage:[UIImage imageNamed:[cells_selected objectAtIndex:num%[cells_selected count]]]];
	
	[(UIImageView*)self.selectedBackgroundView setImage:[UIImage imageNamed:[cells_selected objectAtIndex:num%[cells_selected count]]]];
	//[(UIImageView*)self.selectedBackgroundView setHighlightedImage:[UIImage imageNamed:[cells_pressed objectAtIndex:num%[cells_pressed count]]]];
	
	label.text = theLabel;
}


- (void)dealloc {
    [super dealloc];
}


@end
