//
//  pictureLibraryExampleAppDelegate.m
//  pictureLibraryExample
//
//  Created by maliy on 6/20/11.
//  Copyright 2011 interMobile. All rights reserved.
//

#import "pictureLibraryExampleAppDelegate.h"
#import "mainViewController.h"

@implementation pictureLibraryExampleAppDelegate
@synthesize window;

#pragma mark -

- (void) clearTempDir
{
	NSString *directory = NSTemporaryDirectory();
    
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *err;
	NSArray *arr = [fm contentsOfDirectoryAtPath:directory error:&err];
    
	NSString *fullFileName;
	for (NSString *f in arr)
	{
		BOOL dirFlag = NO;
		fullFileName = [directory stringByAppendingPathComponent:f];
		if ([fm fileExistsAtPath:fullFileName isDirectory:&dirFlag])
		{
			NSLog(@"remove %@", f);
			if (![fm removeItemAtPath:fullFileName error:&err])
			{
				NSLog(@"%@", err);
			}
		}
	}
    
}

#pragma mark -

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	UIApplication *app = [UIApplication sharedApplication];
	app.idleTimerDisabled = YES;
	
	[self clearTempDir];
	
	mainViewController *mvc = [[mainViewController alloc] init];
	UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:mvc];
	nc.navigationBar.barStyle = UIBarStyleBlackOpaque;
	[mvc release];
	
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[self.window addSubview:nc.view];
	[self.window makeKeyAndVisible];
	
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [window release];
    [super dealloc];
}

@end
