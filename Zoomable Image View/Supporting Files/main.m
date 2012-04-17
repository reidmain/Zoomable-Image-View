int main(int argc, char *argv[]) 
{
	// create root auto-release pool
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] 
		init];
	
	// start dispatch message pump
	int retVal = UIApplicationMain(argc, argv, nil, @"AppDelegate");
	
	// release pool when dispatcher completes
	[pool release];
	
	// return result
	return retVal;
}