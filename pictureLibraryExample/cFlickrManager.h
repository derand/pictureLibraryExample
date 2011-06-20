//
//  cFlickrManager.h
//  Amagami
//
//  Created by maliy on 6/17/11.
//

#import <Foundation/Foundation.h>


@class cFlickrManager;
@class cNetwork;


@protocol cFlickrManagerDelegate <NSObject>
- (void) flickrManager:(cFlickrManager *) sender searchedImages:(NSArray *) searchedImages onPage:(NSInteger) page;
- (void) flickrManager:(cFlickrManager *) sender imageFileName:(NSString *) imageFileName forInfo:(NSDictionary *) info;
@end


@interface cFlickrManager : NSObject
{
	cNetwork *network;
	
	NSArray *placesIDs;
	NSInteger placeNumber;
	NSInteger pageNumber;
	NSInteger searchLimit;
	BOOL searching;
	NSArray *tags;
	
	BOOL saveImages;
	BOOL lastImage;
	
	id<cFlickrManagerDelegate> delegate;
	
	NSMutableArray *lastDownloadedImagesQuery;

}

@property (nonatomic, assign) id<cFlickrManagerDelegate> delegate;
@property (nonatomic, assign) BOOL saveIamges;
@property (nonatomic, readonly) BOOL lastImage;
@property (nonatomic, retain) NSArray *tags;

- (void) search;
- (void) imageByInfo:(NSDictionary *) imageInfo;

- (NSString *) fileNameFromInfo:(NSDictionary *) info;


@end
