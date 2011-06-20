//
//  mainViewController.h
//  pictureLibraryExample
//
//  Created by maliy on 6/4/11.
//

#import <UIKit/UIKit.h>

@class picturesViewController;

@interface mainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *tv;
	
	picturesViewController *pvc;
	
	NSArray *list;
}

@end
