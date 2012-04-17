#import "FDRootViewController_iPad.h"
#import "FDZoomableImageController.h"


#pragma mark Class Extension

@interface FDRootViewController_iPad ()
{
	@private FDZoomableImageController *_zoomableImageController;
	@private UIPopoverController *_imageListPopoverController;
	@private UIBarButtonItem *_imagesBarButtonItem;
}


- (void)_toggleImageListPopoverVisibility;


@end // @interface FDRootViewController_iPad ()


#pragma mark -
#pragma mark Class Definition

@implementation FDRootViewController_iPad


#pragma mark -
#pragma mark Constructors

- (id)init
{
	// Abort if base initializer fails.
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// Ensure the navigation bar is translucent.
	self.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	
	// Create a zoomable image controller and make it the root view controller of the navigation stack.
	_zoomableImageController = [[FDZoomableImageController alloc] 
		init];
	
	self.viewControllers = [NSArray arrayWithObject: _zoomableImageController];
	
	// Create a popover controller that contains a image list controller.
	FDImageListController *imageListController = [[FDImageListController alloc] 
		init];
	
	imageListController.delegate = self;
	
	_imageListPopoverController = [[UIPopoverController alloc] 
		initWithContentViewController: imageListController];
	
	[imageListController release];
	
	// Add a button to the zoomable image controller's navigation bar that, when pressed, will toggle the visibility of the image list popover.
	_imagesBarButtonItem = [[UIBarButtonItem alloc] 
		initWithTitle: @"Images" 
			style: UIBarButtonItemStylePlain 
			target: self 
			action: @selector(_toggleImageListPopoverVisibility)];
	
	_zoomableImageController.navigationItem.rightBarButtonItem = _imagesBarButtonItem;
	
	// Return initialized instance.
	return self;
}


#pragma mark -
#pragma mark Destructor

- (void)dealloc 
{
	// Release instance variables.
	[_zoomableImageController release];
	[_imageListPopoverController release];
	[_imagesBarButtonItem release];
	
	// Call the base destructor.
	[super dealloc];
}


#pragma mark -
#pragma mark Overridden Methods

- (void)viewDidAppear: (BOOL)animated
{
	// Call base implementation.
	[super viewDidAppear: animated];
	
	// If the zoomable image controller does not have any image details display the image list popover.
	if (_zoomableImageController.imageDetails == nil)
	{
		[_imageListPopoverController presentPopoverFromBarButtonItem: _imagesBarButtonItem 
			permittedArrowDirections: UIPopoverArrowDirectionAny 
			animated: YES];
	}
}


#pragma mark -
#pragma mark Private Methods

- (void)_toggleImageListPopoverVisibility
{
	// Toggle the visibility of the image list popover.
	if (_imageListPopoverController.popoverVisible == YES)
	{
		[_imageListPopoverController dismissPopoverAnimated: YES];
	}
	else
	{
		[_imageListPopoverController presentPopoverFromBarButtonItem: _imagesBarButtonItem 
			permittedArrowDirections: UIPopoverArrowDirectionAny 
			animated: YES];
	}
}


#pragma mark -
#pragma mark FDImageListControllerDelegate Methods

- (void)imageListController: (FDImageListController *)imageListController 
	selectedImageDetails: (FDImageDetails *)imageDetails
{
	// Display selected image details in the zoomable image controller.
	_zoomableImageController.imageDetails = imageDetails;
	
	// Ensure the image list popover is dismissed.
	[_imageListPopoverController dismissPopoverAnimated: YES];
}


@end // @implementation FDRootViewController_iPad