//
//  cExample2PD.m
//  pictureLibraryExample
//
//  Created by maliy on 6/11/11.
//

#import "cExample2PD.h"


@implementation cExample2PD

#pragma mark lifeCycle

+ (cExample2PD *) initWithDefaults
{
	cExample2PD *rv = [[[cExample2PD alloc] init] autorelease];
	return rv;
}


#pragma mark picturesViewControllerDelegate

- (NSInteger) picturesViewControllerPicturesCount:(picturesViewController *) sender
{
	return -1;
}

- (UIImage *) picturesViewController:(picturesViewController *) sender imageById:(NSInteger) idx
{
	return [UIImage imageNamed:[NSString stringWithFormat:@"%02d.jpg", idx%4]];
}



@end
