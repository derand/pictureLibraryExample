//
//  cDirectoryPD.h
//  Amagami
//
//  Created by maliy on 6/11/11.
//

#import <Foundation/Foundation.h>
#import "picturesViewController.h"
#import "abstractPictureDelegate.h"

@interface cDirectoryPD : NSObject <picturesViewControllerDelegate, abstractPictureDelegate>
{
	NSMutableArray *files;
	NSString *directory;
	
	BOOL showed;
}

+ (cDirectoryPD *) initWithDefaults;

@end
