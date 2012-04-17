#import "FDRootViewController_iPhone.h"
#import "FDZoomableImageController.h"


#pragma mark Class Definition

@implementation FDRootViewController_iPhone


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
	
	// Create a image list controller and make it the root view controller of the navigation stack.
	FDImageListController *imageListController = [[FDImageListController alloc] 
		init];
	
	imageListController.delegate = self;
	
	self.viewControllers = [NSArray arrayWithObject: imageListController];
	
	[imageListController release];
	
	// Return initialized instance.
	return self;
}


#pragma mark -
#pragma mark FDImageListControllerDelegate Methods

- (void)imageListController: (FDImageListController *)imageListController 
	selectedImageDetails: (FDImageDetails *)imageDetails
{
	// Create a zoomable image controller with the image details that were selected and display it
	FDZoomableImageController *zoomableImageController = [[FDZoomableImageController alloc] 
		initWithImageDetails: imageDetails];
	
	[self pushViewController: zoomableImageController 
		animated: YES];
	
	[zoomableImageController release];
}


@end // @implementation FDRootViewController_iPhone