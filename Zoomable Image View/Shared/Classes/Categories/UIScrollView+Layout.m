#import "UIScrollView+Layout.h"
#import "UIView+Layout.h"


#pragma mark Class Definition

@implementation UIScrollView (Layout)


#pragma mark -
#pragma mark Public Methods

- (void)centerZoomedView
{
	UIView *viewForZooming = [self.delegate viewForZoomingInScrollView: self];
	
	// Calculate the center of the zoomed view if it were bigger than the scroll view.
	CGFloat centerXCoordinate = self.contentSize.width * 0.5;
	CGFloat centerYCoordinate = self.contentSize.height * 0.5;
	
	// If the zoomed view is smaller than the scroll view, offset the center by half of the difference between the width/height of the scroll view and the zoomed view.
	if (self.width > self.contentSize.width)
	{
		centerXCoordinate += (self.width - self.contentSize.width) * 0.5;
	}
	
	if (self.height > self.contentSize.height)
	{
		centerYCoordinate += (self.height - self.contentSize.height) * 0.5;
	}
	
	// NOTE: The center parameter of the image container gets set instead of the frame because the image container may have a transform applied to it and therefore the frame is undefined.
	viewForZooming.center = CGPointMake(centerXCoordinate, centerYCoordinate);
}


@end // @implementation UIScrollView (Layout)