
#import <Foundation/Foundation.h>


@protocol XMLParserDelegate;

@interface XMLParser : NSObject {
	id <XMLParserDelegate> delegate;
	// these variables are used during parsing
    NSMutableArray *currentParseBatch;
    NSUInteger parsedAssetsCounter;
	NSMutableArray * assets; 
   
    BOOL didAbortParsing;
	
	int currentSectionNumber;
	int currentCategoryNumber;
		
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSMutableArray *currentParseBatch;
@property (nonatomic, retain) NSMutableArray *assets;

-(id) parse:(NSData *)xml withDelegate:(id<XMLParserDelegate>)theDelegate;
- (void)parseAssetData:(NSData *)data ;
- (void) addAssetsToList:(NSArray *)list;

@end

@protocol XMLParserDelegate<NSObject>

- (void) XMLParserDidFail:(XMLParser *)theParser;
- (void) XMLParserDidFinish:(XMLParser *)theParser;


@end
