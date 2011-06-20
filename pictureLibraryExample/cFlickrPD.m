//
//  cFlickrPD.m
//  pictureLibraryExample
//
//  Created by maliy on 6/17/11.
//

#import "cFlickrPD.h"


#define SEARCH_BEFORE	5


@interface cFlickrPD ()
@property (nonatomic, assign) picturesViewController *pvc;
@end



@implementation cFlickrPD
@synthesize pvc;

#pragma mark lifeCycle

+ (cFlickrPD *) initWithDefaults
{
	cFlickrPD *rv = [[[cFlickrPD alloc] init] autorelease];
	return rv;
}

- (id) init
{
	self = [super init];
	if (self)
	{
		image_urls = [[NSMutableArray alloc] init];
		visible = NO;
		waitingFirstImages = NO;

		flickrManager = [[cFlickrManager alloc] init];
		flickrManager.delegate = self;
		flickrManager.saveIamges = NO;
		
		lastChangePageDate = 0;
		minimumPageChangeInterval = 4.0;
	}
	return self;
}

- (void) dealloc
{
	[image_urls release];
	[flickrManager release];
	
	[super dealloc];
}


#pragma mark -

- (void) changePage
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(changePage) object:nil];
	
	NSTimeInterval currentDate = [[NSDate date] timeIntervalSinceReferenceDate];
	if (minimumPageChangeInterval<.1 || (currentDate-lastChangePageDate)>minimumPageChangeInterval)
	{
		if ((pvc.count-pvc.index)<3)
		{
			[pvc setIndex:pvc.count-1 animated:YES];
			lastChangePageDate = currentDate;
		}
	}
	else
	{
		[self performSelector:@selector(changePage) withObject:nil afterDelay:minimumPageChangeInterval-(currentDate-lastChangePageDate)+0.01];
	}
}

- (BOOL) checkInfo:(NSDictionary *) info
{
	return YES;
}

#pragma mark abstractPictureDelegate

- (void) abstractPictureDelegateOnShow:(picturesViewController *) parent
{
	visible = YES;
	[flickrManager search];
}

- (void) abstractPictureDelegateOnUnShow:(picturesViewController *) parent
{
	visible = NO;
}

#pragma mark picturesViewControllerDelegate

- (NSInteger) picturesViewControllerPicturesCount:(picturesViewController *) sender
{
	self.pvc = sender;
	return -1;
}

- (UIImage *) picturesViewController:(picturesViewController *) sender imageById:(NSInteger) idx
{
	if (idx<[image_urls count])
	{
		[flickrManager imageByInfo:[image_urls objectAtIndex:idx]];
	}
	else
	{
		waitingFirstImages = YES;
	}
	
	if (idx>[image_urls count]-SEARCH_BEFORE && !flickrManager.lastImage)
	{
		[flickrManager search];
	}
	return nil;
}

- (void) picturesViewController:(picturesViewController *) sender changeImageTo:(NSInteger) idx
{
	if (idx<[image_urls count])
	{
		NSLog(@"page %d - \"%@\"", idx+1, [[image_urls objectAtIndex:idx] objectForKey:@"tags"]);
	}
}



#pragma mark cFlickrManagerDelegate

- (void) flickrManager:(cFlickrManager *) sender searchedImages:(NSArray *) searchedImages onPage:(NSInteger) page
{
	for (NSDictionary *info in searchedImages)
	{
		if ([self checkInfo:info])
		{
			[image_urls addObject:info];
			if ([image_urls count]==1 && waitingFirstImages)
			{
				[flickrManager imageByInfo:[image_urls objectAtIndex:0]];
			}
			NSLog(@"- %@", [[flickrManager fileNameFromInfo:info] lastPathComponent]);
			waitingFirstImages = NO;
		}
	}
	NSLog(@"change search page to %d", page);
}

- (void) flickrManager:(cFlickrManager *) sender imageFileName:(NSString *) imageFileName forInfo:(NSDictionary *) info
{
	if (!visible)
		return;
	
	NSInteger i=0;
	for (NSDictionary *tmp in image_urls)
	{
		if (tmp==info)
		{
			break;
		}
		i++;
	}
	
	if (i<[image_urls count])
	{
		[pvc setImage:[UIImage imageWithContentsOfFile:imageFileName] forIndex:i];
	}
	
	if (i>=pvc.index)
	{
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(changePage) object:nil];
		
		[self performSelector:@selector(changePage) withObject:nil afterDelay:0.4f];
	}
}

@end
