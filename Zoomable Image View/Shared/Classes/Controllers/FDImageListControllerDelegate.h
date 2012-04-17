#import "FDImageDetails.h"


#pragma mark Forward Declarations

@class FDImageListController;


#pragma mark -
#pragma mark Protocol

@protocol FDImageListControllerDelegate<NSObject>


#pragma mark -
#pragma mark Required Methods

@required

- (void)imageListController: (FDImageListController *)imageListController 
	selectedImageDetails: (FDImageDetails *)imageDetails;


@end // @protocol FDImageListControllerDelegate