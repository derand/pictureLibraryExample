//
//  cExample2PD.h
//  Amagami
//
//  Created by maliy on 6/11/11.
//

#import <Foundation/Foundation.h>
#import "picturesViewController.h"
#import "abstractPictureDelegate.h"


@interface cExample2PD : NSObject <picturesViewControllerDelegate, abstractPictureDelegate>
{
}

+ (cExample2PD *) initWithDefaults;

@end
