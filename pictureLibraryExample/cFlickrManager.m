//
//  cFlickrManager.m
//  Amagami
//
//  Created by maliy on 6/17/11.
//

#import <CoreLocation/CoreLocation.h>
#import "cFlickrManager.h"
#import "cNetwork.h"
#import "cTransportResponseInfo.h"


@interface cFlickrManager ()
@property (nonatomic, retain) cNetwork *network;
@property (nonatomic, retain) NSArray *placesIDs;

- (void) gettedLocation:(CLLocationCoordinate2D) coordinate;
@end


@implementation cFlickrManager
@synthesize network;
@synthesize placesIDs;
@synthesize delegate;
@synthesize saveIamges;
@synthesize lastImage;
@synthesize tags;

#pragma mark lifeCycle

- (id) init
{
	self = [super init];
	if (self)
	{
		self.network = [cNetwork defaultNetwork];
		network.flickrAPIkey = @"d6b091bd80d00a75162b180c3220dbbd";
		searchLimit = 50;
		searching = NO;
		lastImage = NO;
		tags = nil;
		self.tags = [NSArray arrayWithObjects:@"nature", nil];

		lastDownloadedImagesQuery = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) dealloc
{
	self.tags = nil;
	[lastDownloadedImagesQuery release];
	self.placesIDs = nil;
	self.network = nil;

	[super dealloc];
}


#pragma mark -

- (NSString *) fileNameFromInfo:(NSDictionary *) info
{
	NSString *fn = [NSString stringWithFormat:@"%@.jpg", [info objectForKey:@"id"]];
	fn = [fn lastPathComponent];
	NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fn];
	return fullPath;
}

- (NSString *) tmpFileNameFromInfo:(NSDictionary *) info
{
	NSString *fn = [NSString stringWithFormat:@"%@.jpg", [info objectForKey:@"id"]];
	fn = [fn lastPathComponent];
	NSString *fullPath = [NSTemporaryDirectory() stringByAppendingPathComponent:fn];
	return fullPath;
}

- (NSString *) imageURLfromInfo:(NSDictionary *) info
{
	NSString *rv = [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@_b.jpg",
					[info objectForKey:@"farm"],
					[info objectForKey:@"server"],
					[info objectForKey:@"id"],
					[info objectForKey:@"secret"]
					];
	return rv;
}

- (void) imageExistsByInfo:(NSDictionary *) info
{
	if (delegate)
	{
		NSString *fn = [self fileNameFromInfo:info];
		[delegate flickrManager:self imageFileName:fn forInfo:info];
	}
}



#pragma mark -

- (void) search
{
	if (placesIDs)
	{
		if (!searching)
		{
			if (placeNumber<[placesIDs count])
			{
				lastImage = NO;
				NSString *placeId = [placesIDs objectAtIndex:placeNumber];
				searching = YES;
				[network searchByPlaceID:placeId withPage:pageNumber andTags:tags andLimit:searchLimit target:self selector:@selector(__searchByPlaceID:)];
			}
			else
			{
				lastImage = YES;
			}
		}
	}
	else
	{
		[self gettedLocation:CLLocationCoordinate2DMake(46.30, 30.45)];
	}
}

- (void) __searchByPlaceID:(cTransportResponseInfo *) tri
{
	searching = NO;
	if (!tri.error)
	{
		pageNumber++;
		NSDictionary *data = tri.data;
		if ([data objectForKey:@"photos"])
		{
			data = [data objectForKey:@"photos"];
			NSInteger pages = [[data objectForKey:@"pages"] integerValue];
			NSMutableArray *photos = [[NSMutableArray alloc] init];
			for (NSDictionary *info in [data objectForKey:@"photo"])
			{
				[photos addObject:info];
			}

			if (delegate)
			{
				[delegate flickrManager:self searchedImages:photos onPage:pageNumber-1];
			}
			
			[photos release];

			if (pageNumber>pages)
			{
				placeNumber++;
				pageNumber = 1;
			}
		}
	}
}

- (void) gettedLocation:(CLLocationCoordinate2D) coordinate
{
//	[network placesByLatitude:coordinate.latitude andLongitude:coordinate.longitude andAccuracy:accuracyRegion target:self selector:@selector(__places:)];
	[network placesByLatitude:coordinate.latitude andLongitude:coordinate.longitude andAccuracy:accuracyWorld target:self selector:@selector(__places:)];
}

- (void) __places:(cTransportResponseInfo *) tri
{
	if (!tri.error)
	{
		NSLog(@"%@", tri.data);
		self.placesIDs = tri.data;
		placeNumber = 0;
		pageNumber = 1;
		[self search];
	}
}

- (void) imageByInfo:(NSDictionary *) imageInfo
{
	NSString *fileName = [self fileNameFromInfo:imageInfo];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:fileName])
	{
		NSString *tmpFileName = [self tmpFileNameFromInfo:imageInfo];
		[network image:[self imageURLfromInfo:imageInfo]
			saveToFile:tmpFileName
			   andInfo:imageInfo
				target:self selector:@selector(__image:)];
	}
	else
	{
		[self imageExistsByInfo:imageInfo];
	}
}

- (void) __image:(cTransportResponseInfo *) tri
{
	if (!tri.error)
	{
		NSString *fileName = [self fileNameFromInfo:tri.info];
		NSString *tmpFileName = [self tmpFileNameFromInfo:tri.info];
		NSError *err;
		NSFileManager *fm = [NSFileManager defaultManager];
		if (saveImages)
		{
			if ([fm moveItemAtPath:tmpFileName toPath:fileName error:&err])
			{
				[self imageExistsByInfo:tri.info];
			}
			else
			{
				NSLog(@"%@" ,err);
			}
		}
		else
		{
			if (delegate)
			{
				[delegate flickrManager:self imageFileName:tmpFileName forInfo:tri.info];
				
				[lastDownloadedImagesQuery addObject:tmpFileName];
				while ([lastDownloadedImagesQuery count]>10)
				{
					tmpFileName = [lastDownloadedImagesQuery objectAtIndex:0];
					if (![fm removeItemAtPath:tmpFileName error:&err])
					{
						NSLog(@"%@ %@", tmpFileName, err);
					}
					[lastDownloadedImagesQuery removeObjectAtIndex:0];
				}
			}
		}
		
	}
}


@end
