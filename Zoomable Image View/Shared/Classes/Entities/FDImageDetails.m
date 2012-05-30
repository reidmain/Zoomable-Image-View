#import "FDImageDetails.h"


#pragma mark Class Definition

@implementation FDImageDetails
{
	@private NSString *_name;
	@private NSString *_prefix;
	@private NSString *_extension;
	@private CGSize _dimensions;
	@private NSString *_fileSize;
	@private CGSize _tileSize;
	@private NSUInteger _levelsOfDetail;
}


#pragma mark -
#pragma mark Properties

@synthesize name = _name;
@synthesize prefix = _prefix;
@synthesize extension = _extension;
@synthesize dimensions = _dimensions;
@synthesize fileSize = _fileSize;
@synthesize tileSize = _tileSize;
@synthesize levelsOfDetail = _levelsOfDetail;


#pragma mark -
#pragma mark Constructors

- (id)initWithName: (NSString *)name 
	prefix: (NSString *)prefix 
	extension: (NSString *)extension 
	dimensions: (CGSize)dimensions 
	fileSize: (NSString *)fileSize 
	tileSize: (CGSize)tileSize 
	levelsOfDetail: (NSUInteger)levelsOfDetail;
{
	// Abort if base initializer fails.
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
	_name = [name copy];
	_prefix = [prefix copy];
	_extension = [extension copy];
	_dimensions = dimensions;
	_fileSize = [fileSize copy];
	_tileSize = tileSize;
	_levelsOfDetail = levelsOfDetail;
	
	// Return initialized instance.
	return self;
}


#pragma mark -
#pragma mark Destructor

- (void)dealloc
{
	// Release instance variables.
	[_name release];
	[_extension release];
	[_prefix release];
	[_fileSize release];
	
	// Call the base destructor.
	[super dealloc];
}


@end // @implementation FDImageDetails