#import "FDTiledImageView.h"


#pragma mark Class Extension

@interface FDTiledImageView ()
{
	@private NSString *_imageNamePrefix;
	@private NSString *_imageExtension;
}


- (void)_initializeTiledImageViewView;
- (UIImage *)_tileForZoomLevel: (NSUInteger)zoomLevel 
	column: (NSUInteger)column 
	row: (NSUInteger)row;
- (void)_redrawImage;


@end // @interface FDTiledImageView ()


#pragma mark -
#pragma mark Class Definition

@implementation FDTiledImageView


#pragma mark -
#pragma mark Properties

@synthesize imageNamePrefix = _imageNamePrefix;
@synthesize imageExtension = _imageExtension;

- (CGSize)tileSize
{
	CATiledLayer *tiledLayer = (CATiledLayer *)[self layer];
	
	return tiledLayer.tileSize;
}

- (NSUInteger)levelsOfDetail
{
	CATiledLayer *tiledLayer = (CATiledLayer *)[self layer];
	
	return tiledLayer.levelsOfDetail;
}


#pragma mark -
#pragma mark Constructors

- (id)initWithImageNamePrefix: (NSString *)imageNamePrefix 
	imageExtension: (NSString *)imageExtension 
	imageSize: (CGSize)imageSize 
	tileSize: (CGSize)tileSize 
	levelsOfDetail: (NSUInteger)levelsOfDetail
{
	// Abort if base initializer fails.
	if ((self = [super initWithFrame: CGRectZero]) == nil)
	{
		return nil;
	}
	
	// Initialize view.
	[self _initializeTiledImageViewView];
	
	// Configure view to displayed the image.
	[self setImageNamePrefix: imageNamePrefix 
		imageExtension: imageExtension 
		imageSize: imageSize 
		tileSize: tileSize 
		levelsOfDetail: levelsOfDetail];
	
	// Return initialized instance.
	return self;
}

- (id)initWithFrame: (CGRect)frame
{
	// Abort if base initializer fails.
	if ((self = [super initWithFrame: frame]) == nil)
	{
		return nil;
	}
	
	// Initialize view.
	[self _initializeTiledImageViewView];
	
	// Return initialized instance.
	return self;
}

- (id)initWithCoder: (NSCoder *)coder
{
	// Abort if base initializer fails.
	if ((self = [super initWithCoder: coder]) == nil)
	{
		return nil;
	}
	
	// Initialize view.
	[self _initializeTiledImageViewView];
	
	// Return initialized instance.
	return self;
}


#pragma mark -
#pragma mark Destructor

- (void)dealloc
{
	// Release instance variables.
	[_imageNamePrefix release];
	[_imageExtension release];
	
	// Call the base destructor.
	[super dealloc];
}


#pragma mark -
#pragma mark Public Methods

- (void)setImageNamePrefix: (NSString *)imageNamePrefix 
	imageExtension: (NSString *)imageExtension 
	imageSize: (CGSize)imageSize 
	tileSize: (CGSize)tileSize 
	levelsOfDetail: (NSUInteger)levelsOfDetail
{
	// Prevent the image name prefix from being set to nil or the empty string.
	if (FDIsEmpty(imageNamePrefix) == YES)
	{
		[NSException raise: NSInvalidArgumentException 
			format: @"%s imageNamePrefix argument cannot be nil", 
				__PRETTY_FUNCTION__];
	}
	
	// Prevent the image extension from being set to nil or the empty string.
	if (FDIsEmpty(imageExtension) == YES)
	{
		[NSException raise: NSInvalidArgumentException 
			format: @"%s imageExtension argument cannot be nil", 
				__PRETTY_FUNCTION__];
	}
	
	// Check if the image size has changed.
	if (self.width != imageSize.width 
		|| self.height != imageSize.height)
	{
		// Resize the view so it is the same size as the image it will be displaying.
		self.width = imageSize.width;
		self.height = imageSize.height;
		
		// Redraw the image because its size has changed.
		[self _redrawImage];
	}
	
	// Check if the image name prefix has changed.
	if (FDIsEmpty(_imageNamePrefix) == YES 
		|| [_imageNamePrefix caseInsensitiveCompare: imageNamePrefix] != NSOrderedSame)
	{
		// Update the image name prefix and redraw the image.
		[_imageNamePrefix release];
		
		_imageNamePrefix = [imageNamePrefix copy];
		
		[self _redrawImage];
	}
	
	
	// Check if the image extension has changed.
	if (FDIsEmpty(imageExtension) == YES 
		|| [_imageExtension isEqualToString: imageExtension] == NO)
	{
		// Update image extension and redraw the image;
		[_imageExtension release];
		
		_imageExtension = [imageExtension copy];
		
		[self _redrawImage];
	}
	
	// Check if the tile size has changed.
	CATiledLayer *tiledLayer = (CATiledLayer *)[self layer];
	
	if (CGSizeEqualToSize(tiledLayer.tileSize, tileSize) == NO)
	{
		// Update the tile size and redraw the image.
		tiledLayer.tileSize = tileSize;
		
		[self _redrawImage];
	}
	
	// Check if the levels of details have changed.
	if (tiledLayer.levelsOfDetail != levelsOfDetail)
	{
		// Update the levels of detail and redraw the image
		tiledLayer.levelsOfDetail = levelsOfDetail;
		
		[self _redrawImage];
	}
}


#pragma mark -
#pragma mark Overridden Methods

+ (Class)layerClass
{
	return [CATiledLayer class];
}

- (void)drawRect: (CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Get the x and y scale factors from the context by getting the current transform matrix, then asking for the "a" and "d" components.
	// NOTE: Apple says that we can ask for either "a" or "d" because this view should be getting scaled equally in both directions but there appears to be a bug where where the x and y scale factors can differ by tens of thousandths.
	CGFloat scaleX = ABS(CGContextGetCTM(context).a);
	CGFloat scaleY = ABS(CGContextGetCTM(context).d);
	
	// Calculate which tiles intersect the rect we have been asked to draw.
	CATiledLayer *tiledLayer = (CATiledLayer *)self.layer;
	
	CGSize tileSize = tiledLayer.tileSize;
	tileSize.width /= scaleX;
    tileSize.height /= scaleY;
	
	int firstColumn = CGRectGetMinX(rect) / tileSize.width;
	int lastColumn = CGRectGetMaxX(rect) / tileSize.width;
	int firstRow = CGRectGetMinY(rect) / tileSize.height;
	int lastRow = CGRectGetMaxY(rect) / tileSize.height;
	
	// Calculate what zoom level we have been asked to draw.
	NSUInteger zoomLevel = (NSUInteger)(1 / scaleX);
	
	// Draw the visible parts of the needed tiles.
	for (int row = firstRow; row <= lastRow; row++)
	{
		for (int column = firstColumn; column <= lastColumn; column++)
		{
			UIImage *tile = [self _tileForZoomLevel: zoomLevel 
				column: column 
				row: row];
			
			CGRect tileRect = CGRectMake(tileSize.width * column, 
				tileSize.height * row, 
				tileSize.width, 
				tileSize.height);
			
			// If the tile sticks outside of the view's bounds we need to truncate it.
			tileRect = CGRectIntersection(self.bounds, tileRect);
			
			[tile drawInRect: tileRect];
        }
    }
}


#pragma mark -
#pragma mark Private Methods

- (void)_initializeTiledImageViewView
{
	// Initialize instance variables.
	_imageNamePrefix = nil;
	_imageExtension = nil;
}

- (UIImage *)_tileForZoomLevel: (NSUInteger)zoomLevel 
	column: (NSUInteger)column 
	row: (NSUInteger)row
{
	// NOTE: Don't load the image using [UIImage +imageNamed:] because CATiledLayer already has some form of caching for every tile.
	NSString *tileName = [NSString stringWithFormat: @"%@_%d_%d_%d", 
		_imageNamePrefix, 
		zoomLevel, 
		column, 
		row];
	
	NSBundle *mainBundle = [NSBundle mainBundle];
	
	NSString *tilePath = [mainBundle pathForResource: tileName 
		ofType: _imageExtension];
	
	UIImage *tile = [UIImage imageWithContentsOfFile: tilePath];
	
	return tile;
}

- (void)_redrawImage
{
	CATiledLayer *tiledLayer = (CATiledLayer *)[self layer];
	
	// Clear existing tiles.
	tiledLayer.contents = nil;
	
	// Draw visible tiles.
	[tiledLayer setNeedsDisplay];
}


@end // @implementation FDTiledImageView