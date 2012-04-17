#pragma mark Class Interface

@interface FDZoomableImageView : UIView<
	UIScrollViewDelegate>
{
}


#pragma mark -
#pragma mark Properties

@property (nonatomic, readonly) UITapGestureRecognizer *doubleTapGestureRecognizer;

@property (nonatomic, retain) UIImage *image;

@property (nonatomic, readonly) NSString *imageNamePrefix;
@property (nonatomic, readonly) NSString *imageExtension;
@property (nonatomic, readonly) CGSize tileSize;
@property (nonatomic, readonly) size_t levelsOfDetail;


#pragma mark -
#pragma mark Instance Methods

- (void)setImageNamePrefix: (NSString *)imageNamePrefix 
	imageExtension: (NSString *)imageExtension 
	imageSize: (CGSize)imageSize 
	tileSize: (CGSize)tileSize 
	levelsOfDetail: (size_t)levelsOfDetail;

- (void)asyncLoadImageWithContentsOfFile: (NSString *)path 
	completion: (void (^)(void))completion;


@end // @interface FDZoomableImageView