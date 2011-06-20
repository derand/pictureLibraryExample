//
//  cExamplePD.m
//  Amagami
//
//  Created by maliy on 6/11/11.
//

#import "cExamplePD.h"


@implementation cExamplePD

#pragma mark lifeCycle

+ (cExamplePD *) initWithDefaults
{
	cExamplePD *rv = [[[cExamplePD alloc] init] autorelease];
	return rv;
}

#pragma mark abstractPictureDelegate

- (void) abstractPictureDelegateOnShow:(picturesViewController *) parent
{
}

- (void) abstractPictureDelegateOnUnShow:(picturesViewController *) parent
{
}

#pragma mark picturesViewControllerDelegate

- (NSInteger) picturesViewControllerPicturesCount:(picturesViewController *) sender
{
	return 1;
}

- (UIImage *) picturesViewController:(picturesViewController *) sender imageById:(NSInteger) idx
{
	return [UIImage imageNamed:[NSString stringWithFormat:@"%02d.jpg", idx%4]];
}


@end
