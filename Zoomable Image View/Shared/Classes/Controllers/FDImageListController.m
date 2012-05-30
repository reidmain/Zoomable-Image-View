#import "FDImageListController.h"
#import "FDImageDetails.h"
#import "UIView+Layout.h"


#pragma mark Class Extension

@interface FDImageListController ()

@property (nonatomic, retain) IBOutlet UITableView *tableView;


- (void)_updateTableViewContentInset;


@end // @interface FDImageListController ()


#pragma mark -
#pragma mark Class Variables

static NSString * const TableViewCellIdentifier = @"ImageListCell";


#pragma mark -
#pragma mark Class Definition

@implementation FDImageListController
{
	@private UITableView *_tableView;
	@private id<FDImageListControllerDelegate> _delegate;
	
	@private NSMutableArray *_imageDetails;
}


#pragma mark -
#pragma mark Properties

@synthesize tableView = _tableView;
@synthesize delegate = _delegate;


#pragma mark -
#pragma mark Constructors

- (id)init
{
	// Abort if base initializer fails.
	if ((self = [super initWithNibName: @"FDImageListView" 
		bundle: nil]) == nil)
	{
		return nil;
	}
	
	// Set the controller's title.
	self.title = @"Images";
	
	// Indicate that the controller wants to be laid out fullscreen
	self.wantsFullScreenLayout = YES;
	
	// Set the size of the controller if it is inside a popover.
	self.contentSizeForViewInPopover = CGSizeMake(400.0f, 600.0f);
	
	// Load image details from bundle.
	NSBundle *mainBundle = [NSBundle mainBundle];
	
	NSURL *imagesURL = [mainBundle URLForResource: @"Images" 
		withExtension: @"plist"];
	
	NSArray *rawImageDetails = [[NSArray alloc] 
		initWithContentsOfURL: imagesURL];
	
	_imageDetails = [[NSMutableArray alloc] 
		initWithCapacity: [rawImageDetails count]];
	
	for (NSDictionary *rawDetails in rawImageDetails)
	{
		NSString *name = [rawDetails objectForKey: @"name"];
		NSString *prefix = [rawDetails objectForKey: @"prefix"];
		NSString *extension = [rawDetails objectForKey: @"extension"];
		CGFloat width = [[rawDetails objectForKey: @"width"] floatValue];
		CGFloat height = [[rawDetails objectForKey: @"height"] floatValue];
		NSString *fileSize = [rawDetails objectForKey: @"fileSize"];
		CGFloat tileSize = [[rawDetails objectForKey: @"tileSize"] floatValue];
		int levelsOfDetail = [[rawDetails objectForKey: @"levelsOfDetail"] intValue];
		
		FDImageDetails *details = [[FDImageDetails alloc] 
			initWithName: name 
				prefix: prefix 
				extension: extension 
				dimensions: CGSizeMake(width, height) 
				fileSize: fileSize 
				tileSize: CGSizeMake(tileSize, tileSize) 
				levelsOfDetail: levelsOfDetail];
		
		[_imageDetails addObject: details];
		
		[details release];
	}
	
	[rawImageDetails release];
	
	// Return initialized instance.
	return self;
}


#pragma mark -
#pragma mark Destructor

- (void)dealloc 
{
	// nil out delegates of any instance variables.
	_tableView.dataSource = nil;
	_tableView.delegate = nil;
	
	// Release instance variables.
	[_tableView release];
	
	[_imageDetails release];
	
	// Call the base destructor.
	[super dealloc];
}


#pragma mark -
#pragma mark Overridden Methods

- (BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewDidUnload
{
	// Call base implementation.
	[super viewDidUnload];
	
	// Release references to subviews of the controller's view. Only do this for objects that can be easily recreated.
	self.tableView = nil;
}

- (void)viewWillAppear: (BOOL)animated
{
	// Call base implementation.
	[super viewWillAppear: animated];
	
	[self _updateTableViewContentInset];
}

- (void)willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation 
	duration: (NSTimeInterval)duration
{
	[self _updateTableViewContentInset];
}


#pragma mark -
#pragma mark Private Methods

- (void)_updateTableViewContentInset
{
	// Because the controller wants fullscreen layout we need to set the top content inset of the table view to be the status bar height plus navigation bar height.
	CGFloat topInset = 0.0f;
	
	UIApplication *application = [UIApplication sharedApplication];
	
	// HACK: The height of the status bar should only be taken into account if it is visible and the view being shown is behind the status bar. If the controller is inside a UIPopoverController then the status bar height should be ignored. I'm not sure how to determine this 100% of the time. Checking if the view has a parent controller is a hack that works for this project because the FDImageListController is always presented inside some other controller except for the scenario where it is inside a UIPopoverController.
	if (application.statusBarHidden == NO 
		&& self.parentViewController != nil)
	{
		topInset += 20.0f;
	}
	
	topInset += self.navigationController.navigationBar.height;
	
	_tableView.contentInset = UIEdgeInsetsMake(topInset, 0.0f, 0.0f, 0.0f);
}


#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)tableView: (UITableView *)tableView 
	numberOfRowsInSection: (NSInteger)section
{
	NSInteger numberOfRows = [_imageDetails count];
	
	return numberOfRows;
}

- (UITableViewCell *)tableView: (UITableView *)tableView 
	cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: TableViewCellIdentifier];
	
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] 
			initWithStyle: UITableViewCellStyleSubtitle 
				reuseIdentifier: TableViewCellIdentifier] 
					autorelease];
	}
	
	FDImageDetails *imageDetails = [_imageDetails objectAtIndex: indexPath.row];
	
	NSString *subtitle = [NSString stringWithFormat: @"%.0fx%.0f, %@, %.0fx%.0f, %d Levels of Detail", 
		imageDetails.dimensions.width, 
		imageDetails.dimensions.height, 
		imageDetails.fileSize, 
		imageDetails.tileSize.width, 
		imageDetails.tileSize.height, 
		imageDetails.levelsOfDetail];
	
	cell.textLabel.text = imageDetails.name;
	cell.detailTextLabel.text = subtitle;
	
	return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate Methods

- (void)tableView: (UITableView *)tableView 
	didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath: indexPath 
		animated: YES];
	
	FDImageDetails *imageDetails = [_imageDetails objectAtIndex: indexPath.row];
	
	[_delegate imageListController: self 
		selectedImageDetails: imageDetails];
}


@end // @implementation FDImageListController