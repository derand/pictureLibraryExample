//
//  cFlickrPD.h
//  pictureLibraryExample
//
//  Created by maliy on 6/17/11.
//

#import <Foundation/Foundation.h>
#import "picturesViewController.h"
#import "abstractPictureDelegate.h"
#import "cFlickrManager.h"


@interface cFlickrPD : NSObject <picturesViewControllerDelegate, abstractPictureDelegate, cFlickrManagerDelegate>
{
	cFlickrManager *flickrManager;

	NSMutableArray *image_urls;
	
	picturesViewController *pvc;
	
	BOOL visible;
	BOOL waitingFirstImages;
	
	NSTimeInterval lastChangePageDate;
	CGFloat minimumPageChangeInterval;
	
}

+ (cFlickrPD *) initWithDefaults;

@end
