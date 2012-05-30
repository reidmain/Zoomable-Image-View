#pragma mark Class Interface

@interface FDTiledImageView : UIView


#pragma mark -
#pragma mark Properties

@property (nonatomic, readonly) NSString *imageNamePrefix;
@property (nonatomic, readonly) NSString *imageExtension;
@property (nonatomic, readonly) CGSize tileSize;
@property (nonatomic, readonly) NSUInteger levelsOfDetail;


#pragma mark -
#pragma mark Constructors

- (id)initWithImageNamePrefix: (NSString *)imageNamePrefix 
	imageExtension: (NSString *)imageExtension 
	imageSize: (CGSize)imageSize 
	tileSize: (CGSize)tileSize 
	levelsOfDetail: (NSUInteger)levelsOfDetail;


#pragma mark -
#pragma mark Instance Methods

- (void)setImageNamePrefix: (NSString *)imageNamePrefix 
	imageExtension: (NSString *)imageExtension 
	imageSize: (CGSize)imageSize 
	tileSize: (CGSize)tileSize 
	levelsOfDetail: (NSUInteger)levelsOfDetail;


@end // @interface FDTiledImageView