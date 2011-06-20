//
//  cDirectoryPD.m
//  pictureLibraryExample
//
//  Created by maliy on 6/11/11.
//

#import "cDirectoryPD.h"


#define LAST_FILE_NAME	@"directoryLastFileName"

@implementation cDirectoryPD

#pragma mark lifeCycle

+ (cDirectoryPD *) initWithDefaults
{
	cDirectoryPD *rv = [[[cDirectoryPD alloc] init] autorelease];
	return rv;
}

- (id) init
{
	self = [super init];
	if (self)
	{
		files = [[NSMutableArray alloc] init];
		directory = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] retain];

		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSDictionary *appDefaults = nil;
		appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
					   @"",					LAST_FILE_NAME,
					   nil];
		[defaults registerDefaults:appDefaults];
		
		showed = NO;
	}
	return self;
}

- (void) dealloc
{
	[directory release];
	[files release];

	[super dealloc];
}

#pragma mark -

- (void) readDirectory
{
	if ([files count])
		return;

	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *err;
	NSArray *arr = [fm contentsOfDirectoryAtPath:directory error:&err];
	NSLog(@"%@", arr);
	
	[files removeAllObjects];
	NSString *fullFileName;
	for (NSString *f in arr)
	{
		BOOL dirFlag = NO;
		fullFileName = [directory stringByAppendingPathComponent:f];
		if ([fm fileExistsAtPath:fullFileName isDirectory:&dirFlag])
		{
			[files addObject:fullFileName];
		}
	}
}


#pragma mark abstractPictureDelegate

- (void) abstractPictureDelegateOnShow:(picturesViewController *) parent
{
	showed = YES;
	NSString *lastFileName = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_FILE_NAME];
	NSLog(@"%s - %@", __FUNCTION__, [lastFileName lastPathComponent]);
	[files removeAllObjects];
	[self readDirectory];
	
	NSInteger idx = 0;
	if ([lastFileName length])
	{
		for (NSString *fn in files)
		{
			if ([lastFileName isEqualToString:fn])
			{
				parent.index = idx;
				break;
			}
			idx++;
		}
	}
}

- (void) abstractPictureDelegateOnUnShow:(picturesViewController *) parent
{
	showed = NO;
}


#pragma mark picturesViewControllerDelegate

- (NSInteger) picturesViewControllerPicturesCount:(picturesViewController *) sender
{
	[self readDirectory];
	return [files count];
}

- (UIImage *) picturesViewController:(picturesViewController *) sender imageById:(NSInteger) idx
{
	UIImage *rv = nil;
	if (idx<[files count])
	{
		NSString *fileName = [files objectAtIndex:idx];
		rv = [UIImage imageWithContentsOfFile:fileName];
	}
	return rv;
}

- (void) picturesViewController:(picturesViewController *) sender changeImageTo:(NSInteger) idx
{
	if (!showed)
		return;

	if (idx<[files count])
	{
		NSString *fileName = [files objectAtIndex:idx];
		
		[[NSUserDefaults standardUserDefaults] setObject:fileName forKey:LAST_FILE_NAME];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}


@end
