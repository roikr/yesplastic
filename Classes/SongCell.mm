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

- (void)update;
@end


@implementation SongCell

@synthesize label;
@synthesize lock;
@synthesize deleteButton;
@synthesize songsTable;
@synthesize song; 


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
	
	self.song = theSong;
	self.label.text = theSong.songName;
	self.songsTable = theTable;
	currentSet = 0;
	[self update];
	
}

- (void)update {
	self.userInteractionEnabled = YES;
	
	if (![song.bReady boolValue]) { 
		self.userInteractionEnabled = NO;
		CGRect frame = self.frame;
		frame.size.width = 0;
		self.frame = frame;
		MilgromLog(@"Song: %@",[song songName]);
		NSArray *soundSets = [song.soundSets allObjects];
		while (currentSet/2 < [soundSets count] )  {
		
			SoundSet *soundSet = [soundSets objectAtIndex:currentSet/2];
			if (![soundSet.bReady boolValue]) {
				MilgromLog(@"%i: SoundSet: %@ is not ready",currentSet/2,[soundSet setName]);
				[[AssetLoader alloc] initWithSet:soundSet delegate:self];
				return; 
			} else {
				currentSet++;
				VideoSet *videoSet = [soundSet videoSet];
				if (![videoSet.bReady boolValue]) {
					MilgromLog(@"%i: VideoSet: %@ is not ready",currentSet/2,[videoSet setName]);
					[[AssetLoader alloc] initWithSet:videoSet delegate:self];
					return;
				} else {
					currentSet++;
				}


			}
			
		}
		frame.size.width = 270;
		self.frame = frame;
		self.userInteractionEnabled = YES;
		[song setBReady:[NSNumber numberWithBool:YES]];
		[songsTable updateContext];
		
	} 
}

- (void) delete:(id)sender {
	[songsTable deleteSong:self];
	
}

- (void)dealloc {
	[songsTable release];
	[song release];
    [super dealloc];
}

#pragma mark -
#pragma mark AssetLoader methods

- (void) loaderDidFail:(AssetLoader *)theLoader {
	[self update];
}

- (void) loaderDidFinish:(AssetLoader *)theLoader {
	
	Set *set = theLoader.set;
	MilgromLog(@"Set: %@ is ready",[set setName]);
	[set setBReady:[NSNumber numberWithBool:YES]];
	[songsTable updateContext];
	[self update];
	
}

- (void) loaderProgress:(NSNumber *)theProgress {
	CGRect frame = self.frame;
	frame.size.width = (float)currentSet * 270/6 + [theProgress floatValue] * 270/6;
	self.frame = frame;
	//MilgromLog(@"loaderProgress: %3.2f, width: %3.0f/%3.0f",[theProgress floatValue] *100,self.frame.size.width,270);
}


@end
