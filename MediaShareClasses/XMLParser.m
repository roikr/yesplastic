#import "XMLParser.h"
#import "SoundSet.h"
#import "Asset.h"
#import "ZoozzMacros.h"

@implementation XMLParser

@synthesize currentParseBatch;
@synthesize assets;
@synthesize delegate;

enum {
	YesPlasticSoundSet = 3,
	YesPlasticVideoResouce = 4
};
typedef NSUInteger YesPlasticAssetType; 

-(void) dealloc {
	
	[currentParseBatch release];
	[assets release];
	[super dealloc];
}


-(id) parse:(NSData *)xml withDelegate:(id<XMLParserDelegate>)theDelegate {
	if (self = [super init]) {
		self.delegate = theDelegate;
		self.assets = [NSMutableArray array];
		[NSThread detachNewThreadSelector:@selector(parseAssetData:) toTarget:self withObject:xml];
		//[self parseAssetData:xml];
	}
	
	return self;
}

- (void) addAssetsToList:(NSArray *)list {
	for (id asset in list)
		[assets addObject:asset];
	
}


- (void)parseAssetData:(NSData *)data {
    // You must create a autorelease pool for all secondary threads.
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    self.currentParseBatch = [NSMutableArray array];
	currentSectionNumber = 0;
		
    //
    // It's also possible to have NSXMLParser download the data, by passing it a URL, but this is not desirable
    // because it gives less control over the network, particularly in responding to connection errors.
    //
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    [parser parse];
	
    self.currentParseBatch = nil;
    
    [parser release];        
    [pool release];
	
	//[self performSelectorOnMainThread:@selector(updateTables) withObject:nil waitUntilDone:YES];
	
	
}


// Handle errors in the download or the parser by showing an alert to the user. This is a very simple way of handling the error,
// partly because this application does not have any offline functionality for the user. Most real applications should
// handle the error in a less obtrusive way and provide offline functionality to the user.
- (void)handleError:(NSError *)error {
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"XMLParser Error", @"Title for alert displayed when download or parse error occurs.") message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}



#pragma mark Parser constants

// Limit the number of parsed assets to 50.
static const const NSUInteger kMaximumNumberOfAssetsToParse = 1000;

// When an Asset object has been fully constructed, it must be passed to the main thread and the table view 
// in RootViewController must be reloaded to display it. It is not efficient to do this for every Earthquake object -
// the overhead in communicating between the threads and reloading the table exceed the benefit to the user. Instead,
// we pass the objects in batches, sized by the constant below. In your application, the optimal batch size will vary 
// depending on the amount of data in the object and other factors, as appropriate.
static NSUInteger const kSizeOfAssetBatch = 50;

// Reduce potential parsing errors by using string constants declared in a single place.
static NSString * const kSectionElementName = @"sec";
static NSString * const kCategoryElementName = @"cat";
static NSString * const kAssetElementName = @"a";


#pragma mark NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    // If the number of parsed earthquakes is greater than kMaximumNumberOfAssetsToParse, abort the parse.
    if (parsedAssetsCounter >= kMaximumNumberOfAssetsToParse) {
        // Use the flag didAbortParsing to distinguish between this deliberate stop and other parser errors.
        didAbortParsing = YES;
        [parser abortParsing];
    } else if ([elementName isEqualToString:kSectionElementName]) {
		currentCategoryNumber = 0;
	}
	else if ([elementName isEqualToString:kCategoryElementName]) {
		
		
	}if ([elementName isEqualToString:kAssetElementName]) {
		NSUInteger type = [[attributeDict valueForKey:@"t"] intValue];
		Asset *asset;
		switch (type) {
			case YesPlasticSoundSet:
				asset = [[SoundSet alloc]  initWithIdentifier:[attributeDict valueForKey:@"aid"] withProductIdentifier:[attributeDict valueForKey:@"pidfr"] withPurchaseID:[attributeDict valueForKey:@"pid"] 
												   withNew:([attributeDict valueForKey:@"new"] != nil ? YES : NO) withChanged:([attributeDict valueForKey:@"changed"] != nil ? YES : NO)
											withOriginalID:[attributeDict valueForKey:@"oid"]];
				break;
			case YesPlasticVideoResouce:
				asset = [[Asset alloc] initWithIdentifier:[attributeDict valueForKey:@"aid"] withOriginalID:[attributeDict valueForKey:@"oid"]];
				break;

			default:
				ZoozzLog(@"illegal type: %u",type);
				return;
				break;
		}
		
		[self.currentParseBatch addObject:asset];
		//[asset copyResources];
		[asset release];
		parsedAssetsCounter++;
		
		
		
		/*
		if (parsedAssetsCounter % 19 == 0) {
			currentCategoryNumber++;
		}
		 */
		/*
        if (parsedAssetsCounter % kSizeOfAssetBatch == 0) {
            [self performSelectorOnMainThread:@selector(addAssetsToList:) withObject:self.currentParseBatch waitUntilDone:NO];
			
			self.currentParseBatch = [NSMutableArray array];
        }
		 */
		
    } 
	
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {     
    if ([elementName isEqualToString:kSectionElementName]) {
		currentSectionNumber++;
	}
	else if ([elementName isEqualToString:kCategoryElementName]) {
		currentCategoryNumber++;
		
		[self performSelectorOnMainThread:@selector(addAssetsToList:) withObject:self.currentParseBatch waitUntilDone:YES];
		//[self addAssetsToList:currentParseBatch];
		self.currentParseBatch = [NSMutableArray array];
	}
	
	
}

// This method is called by the parser when it find parsed character data ("PCDATA") in an element. The parser is not
// guaranteed to deliver all of the parsed character data for an element in a single invocation, so it is necessary to
// accumulate character data until the end of the element is reached.
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    // If the number of earthquake records received is greater than kMaximumNumberOfEarthquakesToParse, we abort parsing.
    // The parser will report this as an error, but we don't want to treat it as an error. The flag didAbortParsing is
    // how we distinguish real errors encountered by the parser.
    if (didAbortParsing == NO) {
        // Pass the error to the main thread for handling.
        //[self performSelectorOnMainThread:@selector(handleError:) withObject:parseError waitUntilDone:NO];
		[self.delegate performSelectorOnMainThread:@selector(XMLParserDidFail:) withObject:self waitUntilDone:NO];
		//[self.delegate XMLParserDidFail:self];
    }
}


-(void)parserDidEndDocument:(NSXMLParser *)parser {
	[self.delegate performSelectorOnMainThread:@selector(XMLParserDidFinish:) withObject:self waitUntilDone:NO];
	//[self.delegate XMLParserDidFinish:self];
	
}



@end