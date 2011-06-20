//
//  cNetwork.h
//  pictureLibraryExample
//
//  Created by maliy on 6/11/11.
//

#import <Foundation/Foundation.h>

typedef enum
{
	accuracyWorld = 1,
	accuracyCountry = 3,
	accuracyRegion = 6,
	accuracyCity = 11,
	accuracyStreet = 16
} eAccuracy;



@interface cNetwork : NSObject
{
	NSMutableDictionary *queriesDict;
	
	NSString *flickrAPIkey;
	NSString *flickrAPIserver;
}

@property (nonatomic, retain) NSString *flickrAPIkey;

+ (cNetwork *) defaultNetwork;

- (int) image:(NSString *) url saveToFile:(NSString *) fn andInfo:(id) info target:(id) target selector:(SEL) aSelector;

// danbooru calls
- (int) searchPage:(NSInteger) page withLimit:(NSInteger) limit andTags:(NSString *) tags onServer:(NSString *) server target:(id) target selector:(SEL) aSelector;

// flickr calls
- (int) placesByLatitude:(CGFloat) lat andLongitude:(CGFloat) lon andAccuracy:(eAccuracy) accuracy target:(id) target selector:(SEL) aSelector;
- (int) searchByPlaceID:(NSString *) placeID withPage:(NSInteger) page andTags:(NSArray *) tags andLimit:(NSInteger) limit target:(id) target selector:(SEL) aSelector;

@end
