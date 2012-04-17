#pragma mark Class Interface


@interface FDImageDetails : NSObject
{
}


#pragma mark -
#pragma mark Properties

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *prefix;
@property (nonatomic, readonly) NSString *extension;
@property (nonatomic, readonly) CGSize dimensions;
@property (nonatomic, readonly) NSString *fileSize;
@property (nonatomic, readonly) CGSize tileSize;
@property (nonatomic, readonly) NSUInteger levelsOfDetail;


#pragma mark -
#pragma mark Constructors

- (id)initWithName: (NSString *)name 
	prefix: (NSString *)prefix 
	extension: (NSString *)extension 
	dimensions: (CGSize)dimensions 
	fileSize: (NSString *)fileSize 
	tileSize: (CGSize)tileSize 
	levelsOfDetail: (NSUInteger)levelsOfDetail;


@end // @interface FDImageDetails