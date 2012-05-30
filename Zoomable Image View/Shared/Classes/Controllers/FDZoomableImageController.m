#import "FDZoomableImageController.h"
#import "FDZoomableImageView.h"
#import "UIView+Layout.h"


#pragma mark Class Extension

@interface FDZoomableImageController ()

- (void)_showImage;
- (void)_viewTapped;


@end // @interface FDZoomableImageController ()


#pragma mark -
#pragma mark Class Definition

@implementation FDZoomableImageController
{
	@private FDImageDetails *_imageDetails;
	@private FDZoomableImageView *_zoomableImageView;
	@private UIActivityIndicatorView *_activityIndicatorView;
}


#pragma mark -
#pragma mark Properties

@synthesize imageDetails = _imageDetails;
- (void)setImageDetails: (FDImageDetails *)imageDetails
{
	if (_imageDetails != imageDetails)
	{
		[_imageDetails release];
		
		_imageDetails = [imageDetails retain];
		
		// Set the controller's title.
		self.title = _imageDetails.name;
		
		[self _showImage];
	}
}



#pragma mark -
#pragma mark Constructors

- (id)init
{
	// Abort if base initializer fails.
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// Indicate that the controller wants to be laid out fullscreen
	self.wantsFullScreenLayout = YES;
	
	// Return initialized instance.
	return self;
}

- (id)initWithImageDetails: (FDImageDetails *)imageDetails;
{
	// Abort if base initializer fails.
	if ((self = [self init]) == nil)
	{
		return nil;
	}
	
	// Indicate that the controller wants to be laid out fullscreen
	self.wantsFullScreenLayout = YES;
	
	// Initialize instance variables.
	self.imageDetails = imageDetails;
	
	// Return initialized instance.
	return self;
}


#pragma mark -
#pragma mark Destructor

- (void)dealloc 
{
	// Release instance variables.
	[_imageDetails release];
	[_zoomableImageView release];
	
	// Call the base destructor.
	[super dealloc];
}


#pragma mark -
#pragma mark Overridden Methods

- (BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)loadView
{
	UIScreen *mainScreen = [UIScreen mainScreen];
	
	UIView *view = [[[UIView alloc] 
		initWithFrame: CGRectMake(
				0.0f, 
				0.0f, 
				mainScreen.bounds.size.width, 
				mainScreen.bounds.size.height)] 
			autorelease];
	
	view.autoresizingMask = UIViewAutoresizingFlexibleWidth 
		| UIViewAutoresizingFlexibleHeight;
	
	self.view = view;
}

- (void)viewDidLoad
{
	// Call base implementation.
	[super viewDidLoad];
	
	// Create a zoomable image view and add it to the view.
	_zoomableImageView = [[FDZoomableImageView alloc] 
		initWithFrame: CGRectMake(
			0.0f, 
			0.0f, 
			self.view.width, 
			self.view.height)];
	
	_zoomableImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth 
		| UIViewAutoresizingFlexibleHeight;
	
	[self.view addSubview: _zoomableImageView];
	
	// Listen for single taps on the view.
	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] 
		initWithTarget: self 
			action: @selector(_viewTapped)];
	
	tapGestureRecognizer.numberOfTapsRequired = 1;
	
	// Require that the double tap gesture recognizer for the zoomable image view must fail for the single tap gesture to work. If this is not set then when the user double taps they would also toggle the visibility of the status/navigation bars.
	[tapGestureRecognizer requireGestureRecognizerToFail: _zoomableImageView.doubleTapGestureRecognizer];
	
	[self.view addGestureRecognizer: tapGestureRecognizer];
	
	[tapGestureRecognizer release];
	
	// Add activity indicator to the view.
	_activityIndicatorView = [[UIActivityIndicatorView alloc] 
		initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
	
	_activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin 
		| UIViewAutoresizingFlexibleRightMargin 
		| UIViewAutoresizingFlexibleBottomMargin 
		| UIViewAutoresizingFlexibleLeftMargin;
	
	_activityIndicatorView.hidesWhenStopped = YES;
	
	[self.view addSubview: _activityIndicatorView];
	
	[_activityIndicatorView alignHorizontally: UIViewHorizontalAlignmentCenter 
		vertically: UIViewVerticalAlignmentMiddle];
	
	// Display the image the image details represent.
	[self _showImage];
}

- (void)viewDidUnload
{
	// Call base implementation.
	[super viewDidUnload];
	
	// Release references to subviews of the controller's view. Only do this for objects that can be easily recreated.	
	[_zoomableImageView release];
	_zoomableImageView = nil;
	
	[_activityIndicatorView release];
	_activityIndicatorView = nil;
}


#pragma mark -
#pragma mark Internal Methods

- (void)_showImage
{
	if (_imageDetails != nil)
	{
		NSString *compressedImageName = [NSString stringWithFormat: @"%@_compressed.%@", 
			_imageDetails.prefix, 
			_imageDetails.extension];
		
		_zoomableImageView.image = [UIImage imageNamed: compressedImageName];
		
		[_zoomableImageView setImageNamePrefix: _imageDetails.prefix 
			imageExtension: _imageDetails.extension 
			imageSize: _imageDetails.dimensions 
			tileSize: _imageDetails.tileSize 
			levelsOfDetail: _imageDetails.levelsOfDetail];
		
		// NOTE: Uncomment the following lines and comment out the above lines to load the image async inside of tiling.
//		[_activityIndicatorView startAnimating];
//		
//		NSString *originalImageName = [NSString stringWithFormat: @"%@_original.%@", 
//			_imageDetails.prefix, 
//			_imageDetails.extension];
//
//		NSBundle *mainBundle = [NSBundle mainBundle];
//		
//		NSString *originalImagePath = [mainBundle pathForResource: originalImageName 
//			ofType: nil];
//		
//		[_zoomableImageView asyncLoadImageWithContentsOfFile: originalImagePath 
//			completion: ^
//			{
//				[_activityIndicatorView stopAnimating];
//			}];
	}
}

- (void)_viewTapped
{
	// Toggle the visibility of the status bar and navigation bar.
	UIApplication *application = [UIApplication sharedApplication];
	
	BOOL showOnlyImage = (application.statusBarHidden == NO);
	
	if (showOnlyImage == YES)
	{
		[application setStatusBarHidden: YES 
			withAnimation: UIStatusBarAnimationFade];
		
		[UIView animateWithDuration: 0.33 
			delay: 0.0 
			options: UIViewAnimationOptionCurveEaseIn 
			animations: ^
			{
				self.navigationController.navigationBar.alpha = 0.0f;
			} 
			completion: ^(BOOL finished)
			{
				[self.navigationController setNavigationBarHidden: YES 
					animated: NO];
			}];
	}
	else
	{
		[application setStatusBarHidden: NO 
			withAnimation: UIStatusBarAnimationFade];
		
		[self.navigationController setNavigationBarHidden: NO 
			animated: NO];
		
		[UIView animateWithDuration: 0.33 
			delay: 0.0 
			options: UIViewAnimationOptionCurveEaseIn 
			animations: ^
			{
				self.navigationController.navigationBar.alpha = 1.0f;
			} 
			completion: nil];
	}
}


@end // @implementation FDZoomableImageController