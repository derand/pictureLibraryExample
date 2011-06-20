//
//  cExamplePD.h
//  Amagami
//
//  Created by maliy on 6/11/11.
//

#import <Foundation/Foundation.h>
#import "picturesViewController.h"
#import "abstractPictureDelegate.h"

@interface cExamplePD : NSObject <picturesViewControllerDelegate, abstractPictureDelegate>
{
}

+ (cExamplePD *) initWithDefaults;

@end
