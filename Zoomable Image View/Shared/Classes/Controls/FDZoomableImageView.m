#import "FDZoomableImageView.h"
#import "FDTiledImageView.h"
#import "UIScrollView+Layout.h"


#pragma mark Class Extension

@interface FDZoomableImageView ()
{
	@private UIScrollView *_scrollView;
	@private UIView *_imageContainer;
	@private UIImageView *_imageView;
	@private FDTiledImageView *_tiledImageView;
	
	@private UITapGestureRecognizer *_doubleTapGestureRecognizer;
	
	@private CGFloat _aspectFitZoomScale;
	@private NSObject *_latestAsyncLoad;
}


- (void)_initializeZoomableImageView;
- (void)_updateAspectFitZoomScale;
- (void)_resizeScrollViewForImageContainer;
- (void)_scrollViewDoubleTapped: (UITapGestureRecognizer *)doubleTapGestureRecognizer;


@end // @interface FDZoomableImageView ()


#pragma mark -
#pragma mark Class Definition

@implementation FDZoomableImageView


#pragma mark -
#pragma mark Properties

@synthesize doubleTapGestureRecognizer = _doubleTapGestureRecognizer;

- (UIImage *)image
{
	UIImage *image = _imageView.image;
	
	return image;
}
- (void)setImage: (UIImage *)image
{
	// If the image is nil, remove the image view.
	if (image == nil)
	{
		[_imageView removeFromSuperview];
		[_imageView release];
		_imageView = nil;
		
		// If the tiled image view has not yet been created, set the width/height of the image container to 0.0f and resize the scroll view.
		if (_tiledImageView == nil)
		{
			_imageContainer.width = 0.0f;
			_imageContainer.height = 0.0f;
			
			[self _resizeScrollViewForImageContainer];
		}
	}
	// Otherwise, display the image.
	else
	{
		// If the image view does not yet exist, create it and add it to the image container.
		if (_imageView == nil)
		{
			_imageView = [[UIImageView alloc] 
				initWithFrame: CGRectMake(
					0.0f, 
					0.0f, 
					_imageContainer.width, 
					_imageContainer.height)];
			
			_imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth 
				| UIViewAutoresizingFlexibleHeight;
			
			[_imageContainer addSubview: _imageView];
			
			[_imageContainer sendSubviewToBack: _imageView];
		}
		
		// Show the image.
		_imageView.image = image;
		
		// If the tiled image view has not yet been created, set the image container to be the same size as the image view and resize the scroll view.
		if (_tiledImageView == nil)
		{
			_imageContainer.width = _imageView.image.size.width;
			_imageContainer.height = _imageView.image.size.height;
			
			[self _resizeScrollViewForImageContainer];
		}
	}
}

- (NSString *)imageNamePrefix
{
	return  _tiledImageView.imageNamePrefix;
}

- (NSString *)imageExtension
{
	return _tiledImageView.imageExtension;
}

- (CGSize)tileSize
{
	return _tiledImageView.tileSize;
}

- (size_t)levelsOfDetail
{
	return _tiledImageView.levelsOfDetail;
}


#pragma mark -
#pragma mark Constructors

- (id)initWithFrame: (CGRect)frame
{
	// Abort if base initializer fails.
	if ((self = [super initWithFrame: frame]) == nil)
	{
		return nil;
	}
	
	// Initialize view.
	[self _initializeZoomableImageView];
	
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
	[self _initializeZoomableImageView];
	
	// Return initialized instance.
	return self;
}


#pragma mark -
#pragma mark Destructor

- (void)dealloc
{
	// nil out delegates of any instance variables.
	_scrollView.delegate = nil;
	
	// Release instance variables.
	[_scrollView release];
	[_imageContainer release];
	[_imageView release];
	[_tiledImageView release];
	
	[_doubleTapGestureRecognizer release];
	
	[_latestAsyncLoad release];
	
	// Call the base destructor.
	[super dealloc];
}


#pragma mark -
#pragma mark Public Methods

- (void)setImageNamePrefix: (NSString *)imageNamePrefix 
	imageExtension: (NSString *)imageExtension 
	imageSize: (CGSize)imageSize 
	tileSize: (CGSize)tileSize 
	levelsOfDetail: (size_t)levelsOfDetail
{
	// If the tiled image view does not yet exist, create it and add it to the image container.
	if (_tiledImageView == nil)
	{
		_tiledImageView = [[FDTiledImageView alloc] 
			initWithFrame: CGRectZero];
		
		[_imageContainer addSubview: _tiledImageView];
		
		[_imageContainer bringSubviewToFront: _tiledImageView];
	}
	
	// Update the tiled image view.
	[_tiledImageView setImageNamePrefix: imageNamePrefix 
		imageExtension: imageExtension 
		imageSize: imageSize 
		tileSize: tileSize 
		levelsOfDetail: levelsOfDetail];
	
	// Set the image container to be the same size as the tiled image view and resize the scroll view.
	_imageContainer.width = _tiledImageView.width;
	_imageContainer.height = _tiledImageView.height;
	
	[self _resizeScrollViewForImageContainer];
	
	// Ensure the image container is centered inside the scroll view.
	[_scrollView centerZoomedView];
}

- (void)asyncLoadImageWithContentsOfFile: (NSString *)path 
	completion: (void (^)(void))completion
{
	// Clear the current image.
	self.image = nil;
	
	// Create an object to represent this async load so we can only respond to the latest load request.
	NSObject *asyncLoad = [[NSObject alloc] 
		init];
	[_latestAsyncLoad release];
	_latestAsyncLoad = [asyncLoad retain];
	
	[self performBlockInBackground: ^
		{
			UIImage *image = [UIImage imageWithContentsOfFile: path];
			
			[self performBlockOnMainThread: ^
				{
					// Only update the image if this is the latest load request.
					if (_latestAsyncLoad == asyncLoad)
					{
						self.image = image;
						
						if (completion != nil)
						{
							completion();
						}
					}
				}];
		}];
	
	[asyncLoad release];
}


#pragma mark -
#pragma mark Overridden Methods

- (void)layoutSubviews
{
	// Call base implementation.
    [super layoutSubviews];
	
	// NOTE: On high resolutions screens (i.e. Retina displays) the contentScaleFactor of the tiled image view will 2.0 which will cause incorrect tiles to be loaded. We need to manually set the contentScaleFactor to 1.0 to ensure we load the correct tiles.
	_tiledImageView.contentScaleFactor = 1.0;
	
	// Center the image container inside the scroll view.
	[_scrollView centerZoomedView];
}

- (void)setFrame: (CGRect)frame
{
	// Store old frame to track if it is changing.
	CGRect oldFrame = self.frame;
	
	// Call base implementation.
	[super setFrame: frame];
	
	// If the frame changed, ensure the same portion of the image is visible.
	if (CGRectEqualToRect(oldFrame, self.frame) == NO)
	{
		CGFloat previousAspectFitZoomScale = _aspectFitZoomScale;
		
		// Compute the zoom scale that will have the tiled image view aspect fit inside the scroll view.
		[self _updateAspectFitZoomScale];
		
		// If the previous aspect fit zoom scale is the same as the current zoom scale then update the zoom scale to be the new aspect fit zoom scale
		if (_scrollView.zoomScale == previousAspectFitZoomScale)
		{
			_scrollView.zoomScale = _aspectFitZoomScale;
		}
	}
}


#pragma mark -
#pragma mark Private Methods

- (void)_initializeZoomableImageView
{
	// Initialize instance variables.
	_aspectFitZoomScale = 1.0f;
	_latestAsyncLoad = nil;
	
	// Default the background colour to black.
	self.backgroundColor = [UIColor blackColor];
	
	// Create scroll view and add it to the view.
	_scrollView = [[UIScrollView alloc] 
		initWithFrame: CGRectMake(
			0.0f, 
			0.0f, 
			self.width, 
			self.height)];
	
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth 
		| UIViewAutoresizingFlexibleHeight;
	
	[self addSubview: _scrollView];
	
	// Configure the scroll view.
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.showsVerticalScrollIndicator = NO;
	_scrollView.alwaysBounceHorizontal = YES;
	_scrollView.alwaysBounceVertical = YES;
	
	_scrollView.delegate = self;
	
	// Create view that will house the image views.
	_imageContainer = [[UIView alloc] 
		initWithFrame: CGRectZero];
	
	[_scrollView addSubview: _imageContainer];
	
	// Listen for double taps on the scroll view to automatically zoom in/out.
	_doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] 
		initWithTarget: self 
			action: @selector(_scrollViewDoubleTapped:)];
	
	_doubleTapGestureRecognizer.numberOfTapsRequired = 2;
	
	[_scrollView addGestureRecognizer: _doubleTapGestureRecognizer];
}

- (void)_updateAspectFitZoomScale
{
	// Set the aspect fit zoom scale so the entire image container will be visible when the scroll view is at this zoom level.
	if (_imageContainer.width != 0.0f 
		&& _imageContainer.height != 0.0f)
	{
		CGFloat widthRatio = _scrollView.width / _imageContainer.width;
		CGFloat heightRatio = _scrollView.height / _imageContainer.height;
		
		_aspectFitZoomScale = MIN(widthRatio, heightRatio);
	}
	else
	{
		_aspectFitZoomScale = 1.0f;
	}
}

- (void)_resizeScrollViewForImageContainer
{
	// Set the content size of the scroll view to be the same size as the image container
	_scrollView.contentSize = CGSizeMake(_imageContainer.width, _imageContainer.height);
	
	// Compute the zoom scale that will have the image container aspect fit inside the scroll view.
	[self _updateAspectFitZoomScale];
	
	// Compute the minimum and maximum zoom scales of the scroll view.
	if (_tiledImageView == nil)
	{
		_scrollView.minimumZoomScale = _aspectFitZoomScale;
		_scrollView.maximumZoomScale = MAX(1.0f, _aspectFitZoomScale);
	}
	else
	{
		CGFloat minimumZoomScale  = 1 / pow(2.0, _tiledImageView.levelsOfDetail);
		
		_scrollView.minimumZoomScale = MIN(minimumZoomScale, _aspectFitZoomScale);
		_scrollView.maximumZoomScale = 1.0f;
	}
	
	// Set the zoom scale of the scroll view so the image container will aspect fit inside it.
	_scrollView.zoomScale = _aspectFitZoomScale;
	
	// Center the image container inside the scroll view.
	[_scrollView centerZoomedView];
}

- (void)_scrollViewDoubleTapped: (UITapGestureRecognizer *)doubleTapGestureRecognizer;
{
	// If the scroll view's zoom scale is not the aspect fit zoom scale, set the zoom level to be it.
	if (_scrollView.zoomScale != _aspectFitZoomScale)
	{
		[_scrollView setZoomScale: _aspectFitZoomScale 
			animated: YES];
	}
	// Otherwise, if the zoom scale is not at the maximum zoom scale, zoom in on the point that the user double tapped on.
	else if (_scrollView.zoomScale != _scrollView.maximumZoomScale)
	{
		CGPoint doubleTapPoint = [doubleTapGestureRecognizer locationInView: _imageContainer];
		
		CGFloat width = _imageContainer.width * 0.3;
		CGFloat height = _imageContainer.height * 0.3;
		
		CGRect zoomRect = CGRectMake(
			doubleTapPoint.x - (width / 2.0f), 
			doubleTapPoint.y - (height / 2.0f), 
			width, 
			height);
		
		[_scrollView zoomToRect: zoomRect 
			animated: YES];
	}
}


#pragma mark - 
#pragma mark UIScrollViewDelegate Methods

- (UIView *)viewForZoomingInScrollView: (UIScrollView *)scrollView
{
	UIView *viewForZooming = nil;
	
	if (scrollView == _scrollView)
	{
		viewForZooming = _imageContainer;
	}
	
	return viewForZooming;
}

- (void)scrollViewDidZoom: (UIScrollView *)scrollView
{
	// When the scroll view zooms, center the image container inside it.
	if (scrollView == _scrollView)
	{
		[_scrollView centerZoomedView];
	}
}


@end // @implementation FDZoomableImageView