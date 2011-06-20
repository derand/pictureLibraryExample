//
//  cNetwork.m
//  pictureLibraryExample
//
//  Created by maliy on 6/11/11.
//

#import "cNetwork.h"
#import "inetwork.h"
#import "ocJSON.h"


static cNetwork *network = nil;

@interface cNetwork ()
@property (nonatomic, retain) NSString *flickrAPIserver;
@end

@implementation cNetwork
@synthesize flickrAPIkey;
@synthesize flickrAPIserver;

#pragma mark lifeCycle

+ (cNetwork *) defaultNetwork
{
	if (!network)
	{
		network = [[cNetwork alloc] init];
	}
	return network;
}

- (id) init
{
	self = [super init];
	if (self)
	{
		queriesDict = [[NSMutableDictionary alloc] init];
		self.flickrAPIserver = @"http://api.flickr.com/services/rest/";
	}
	return self;
}

- (void) dealloc
{
	self.flickrAPIserver = nil;
	self.flickrAPIkey = nil;
	[queriesDict release];
	
	[super dealloc];
}

#pragma mark -

- (void) removeQueryFromDict:(restQuery *) query
{
	if (query)
	{
		[query cancelConnection];
		[queriesDict removeObjectForKey:query];
		if ([queriesDict count]==0)
		{
			UIApplication *application = [UIApplication sharedApplication];
			application.networkActivityIndicatorVisible = NO;
		}
	}
}

#pragma mark -

- (int) image:(NSString *) url saveToFile:(NSString *) fn andInfo:(id) info target:(id) target selector:(SEL) aSelector
{
	
	for (restQuery *rq in [queriesDict allKeys])
	{
		if ([fn isEqualToString:rq.outputFile])
		{
			return -1;
		}
	}
//	NSLog(@"getting image: %@", url);
	
	transportQuery *tq = [[transportQuery alloc] initWithQuery:nil responder:target function:aSelector info:info];
	[queriesDict setObject:tq forKey:[tq query]];
	
	//	[tq.query useCookies:YES];
	tq.query.outputFile = fn;
	[tq.query   queryToAddress:[NSURL URLWithString:url]
					 usingVerb:@"GET" 
					 parametrs:nil
					 mimneType:nil 
						object:self
				   responseSel:@selector(__imageByUrl:data:)];
	[tq release];
	
	return 0;
}

- (void) __imageByUrl:(restQuery *) query data:(NSData *)data
{
	NSError *err = query.error;
	
	NSString *contentType = [[query allHeadersFields] objectForKey:@"Content-Type"];
	transportQuery *tq = [queriesDict objectForKey:query];
	if (![contentType hasPrefix:@"text/html"] && !err)
	{
		UIImage *image=[UIImage imageWithData:data];
		[tq callResponderWithData:image error:err];
	}
	else
	{
		[tq callResponderWithData:nil error:err];
	}
	[self removeQueryFromDict:query];
//	[err release];
}

- (int) searchPage:(NSInteger) page withLimit:(NSInteger) limit andTags:(NSString *) tags onServer:(NSString *) server target:(id) target selector:(SEL) aSelector
{
	NSMutableDictionary *prms = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								 [NSString stringWithFormat:@"%d", limit], @"limit",
								 [NSString stringWithFormat:@"%d", page], @"page",
//								 tags, @"tags",
								 nil];
	if (tags && [tags length])
	{
		[prms setObject:tags forKey:@"tags"];
	}
	
	transportQuery *tq = [[transportQuery alloc] initWithQuery:nil responder:target function:aSelector info:nil];
	[queriesDict setObject:tq forKey:[tq query]];
	
	NSLog(@"+++ %@post/index.json", server);
	[[tq query]   queryToAddress:[NSURL URLWithString:[NSString stringWithFormat:@"%@post/index.json", server]] 
					   usingVerb:@"POST"
					   parametrs:prms 
					   mimneType:nil 
						  object:self
					 responseSel:@selector(__searchPurchaseImage:data:)];
	[tq release];
	
	return 0;
}

- (void) __searchPurchaseImage:(restQuery *) query data:(NSData *)data
{
	NSError *err = query.error;
	
	NSDictionary *rv = nil;
	if (!err)
	{
		rv = (NSDictionary *)[ocJSON parseData:data];
	}
	transportQuery *tq = [queriesDict objectForKey:query];
	[tq callResponderWithData:rv error:err];
	[rv release];
	
	[self removeQueryFromDict:query];
//	[err release];
}

#pragma mark -

- (int) placesByLatitude:(CGFloat) lat andLongitude:(CGFloat) lon andAccuracy:(eAccuracy) accuracy target:(id) target selector:(SEL) aSelector
{
	// api.flickr.com/services/rest/?method=flickr.places.findByLatLon&api_key=00ce04c45428667aacbdfbe4fb19eb84&lat=46.30&lon=30.45&format=json&nojsoncallback=1
	NSDictionary *prms = [NSDictionary dictionaryWithObjectsAndKeys:
						  [NSString stringWithFormat:@"%.6f", lat], @"lat",
						  [NSString stringWithFormat:@"%.6f", lon], @"lon",
						  [NSString stringWithFormat:@"%d", accuracy], @"accuracy",
						  flickrAPIkey, @"api_key",
						  @"flickr.places.findByLatLon", @"method",
						  @"json", @"format",
						  @"1", @"nojsoncallback",
						  nil];
	
	transportQuery *tq = [[transportQuery alloc] initWithQuery:nil responder:target function:aSelector info:nil];
	[queriesDict setObject:tq forKey:[tq query]];
	
	[[tq query]   queryToAddress:[NSURL URLWithString:flickrAPIserver] 
					   usingVerb:@"GET"
					   parametrs:prms 
					   mimneType:nil 
						  object:self
					 responseSel:@selector(__placesByLatitude:data:)];
	[tq release];
	
	return 0;
}

- (void) __placesByLatitude:(restQuery *) query data:(NSData *)data
{
	NSError *err = query.error;
	
	NSMutableArray *rv = nil;
	if (!err)
	{
		NSDictionary *tmp = (NSDictionary *)[ocJSON parseData:data];
		if ([tmp objectForKey:@"places"])
		{
			NSDictionary *tmp1 = [tmp objectForKey:@"places"];
			NSArray *places = [tmp1 objectForKey:@"place"];
			rv  = [[NSMutableArray alloc] init];
			for (tmp1 in places)
			{
				if ([tmp1 objectForKey:@"place_id"])
				{
					[rv addObject:[tmp1 objectForKey:@"place_id"]];
				}
			}
		}
		[tmp release];
	}
	transportQuery *tq = [queriesDict objectForKey:query];
	[tq callResponderWithData:rv error:err];
	[rv release];
	
	[self removeQueryFromDict:query];
}

- (int) searchByPlaceID:(NSString *) placeID withPage:(NSInteger) page andTags:(NSArray *) tags andLimit:(NSInteger) limit target:(id) target selector:(SEL) aSelector
{
	// api.flickr.com/services/rest/?method=flickr.places.findByLatLon&api_key=00ce04c45428667aacbdfbe4fb19eb84&lat=46.30&lon=30.45&format=json&nojsoncallback=1

	NSMutableDictionary *prms = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								 placeID, @"place_id",
								 [NSString stringWithFormat:@"%d", limit], @"per_page",
								 flickrAPIkey, @"api_key",
								 @"flickr.photos.search", @"method",
								 @"json", @"format",
								 @"1", @"nojsoncallback",
								 nil];
	if (page>1)
	{
		[prms setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
	}
	
	NSMutableString *tmpTags = [[NSMutableString alloc] init];
	for (NSString *str in tags)
	{
		if ([tmpTags length])
		{
			[tmpTags appendFormat:@",%@", str];
		}
		else
		{
			[tmpTags appendString:str];
		}
	}
	if ([tmpTags length])
	{
		[prms setObject:tmpTags forKey:@"tags"];
//		[prms setObject:@"all" forKey:@"tag_mode"];
	}
	[tmpTags release];
	
	transportQuery *tq = [[transportQuery alloc] initWithQuery:nil responder:target function:aSelector info:nil];
	[queriesDict setObject:tq forKey:[tq query]];
	
	[[tq query]   queryToAddress:[NSURL URLWithString:flickrAPIserver] 
					   usingVerb:@"GET"
					   parametrs:prms 
					   mimneType:nil 
						  object:self
					 responseSel:@selector(__searchByPlaceID:data:)];
	[tq release];
	
	return 0;
}


- (void) __searchByPlaceID:(restQuery *) query data:(NSData *)data
{
	NSError *err = query.error;
	
	NSDictionary *rv = nil;
	if (!err)
	{
		rv = (NSDictionary *)[ocJSON parseData:data];
	}
	transportQuery *tq = [queriesDict objectForKey:query];
	[tq callResponderWithData:rv error:err];
	[rv release];
	
	[self removeQueryFromDict:query];
}


@end
