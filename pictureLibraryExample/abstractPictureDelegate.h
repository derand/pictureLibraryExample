//
//  abstractPictureDelegate.h
//  pictureLibraryExample
//
//  Created by maliy on 6/11/11.
//  Copyright 2011 interMobile. All rights reserved.
//

#import "picturesViewController.h"


@protocol abstractPictureDelegate <NSObject>
@optional
- (void) abstractPictureDelegateOnShow:(picturesViewController *) parent;
- (void) abstractPictureDelegateOnUnShow:(picturesViewController *) parent;
@end