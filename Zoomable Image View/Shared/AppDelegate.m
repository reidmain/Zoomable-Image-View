#import "AppDelegate.h"
#import "FDRootViewController_iPhone.h"
#import "FDRootViewController_iPad.h"


#pragma mark Class Definition

@implementation AppDelegate


#pragma mark -
#pragma mark Destructor

- (void)dealloc
{
	// Release instance variables.
	[_mainWindow release];
	
	// Call the base destructor.
    [super dealloc];
}


#pragma mark -
#pragma mark UIApplicationDelegate Methods

- (BOOL)application: (UIApplication *)application 
	didFinishLaunchingWithOptions: (NSDictionary *)launchOptions
{
	// Create the main window.
	UIScreen *mainScreen = [UIScreen mainScreen];
	
	_mainWindow = [[UIWindow alloc] 
		initWithFrame: mainScreen.bounds];
	
	_mainWindow.backgroundColor = [UIColor whiteColor];
	
	// Show the main window.
    [_mainWindow makeKeyAndVisible];
	
	// Create the root view controller based on what platform the app is running on.
	UIDevice *currentDevice = [UIDevice currentDevice];
	
	UIUserInterfaceIdiom idiom = currentDevice.userInterfaceIdiom;
	
	if (idiom == UIUserInterfaceIdiomPad)
	{
		FDRootViewController_iPad *rootViewController = [[FDRootViewController_iPad alloc] 
			init];
		
		_mainWindow.rootViewController = rootViewController;
		
		[rootViewController release];
	}
	else
	{
		FDRootViewController_iPhone *rootViewController = [[FDRootViewController_iPhone alloc] 
			init];
		
		_mainWindow.rootViewController = rootViewController;
		
		[rootViewController release];
	}
	
	// Indicate success.
	return YES;
}


@end // @implementation AppDelegate