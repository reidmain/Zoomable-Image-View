#import "FDImageDetails.h"


#pragma mark Class Interface

@interface FDZoomableImageController : UIViewController
{
}


#pragma mark -
#pragma mark Properties

@property (nonatomic, copy) FDImageDetails *imageDetails;


#pragma mark -
#pragma mark Constructors

- (id)initWithImageDetails: (FDImageDetails *)imageDetails;


@end // @interface FDZoomableImageController