#import "FDImageListControllerDelegate.h"


#pragma mark Class Interface

@interface FDImageListController : UIViewController<
	UITableViewDataSource, 
	UITableViewDelegate>
{
}


#pragma mark -
#pragma mark Properties

@property (nonatomic, assign) IBOutlet id<FDImageListControllerDelegate> delegate;


@end // @interface FDImageListController