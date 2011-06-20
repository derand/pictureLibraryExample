//
//  mainViewController.m
//  Amagami
//
//  Created by maliy on 6/4/11.
//

#import "mainViewController.h"
#import "picturesViewController.h"
#import "cExamplePD.h"
#import "cExample2PD.h"
#import "abstractPictureDelegate.h"
#import "cDirectoryPD.h"
//#import "cDanbooruPD.h"
#import "cFlickrPD.h"



@implementation mainViewController

- (id) init
{
    self = [super init];
    if (self)
	{
        // Custom initialization
		
		
		list = [[NSArray alloc] initWithObjects:
				[NSDictionary dictionaryWithObjectsAndKeys:
				 @"Example (simple)", @"title",
				 [cExamplePD initWithDefaults], @"delegate",
				 nil],
				[NSDictionary dictionaryWithObjectsAndKeys:
				 @"Example2 (infiniti count)", @"title",
				 [cExample2PD initWithDefaults], @"delegate",
				 nil],
				[NSDictionary dictionaryWithObjectsAndKeys:
				 @"Local files", @"title",
				 [cDirectoryPD initWithDefaults], @"delegate",
				 nil],
				[NSDictionary dictionaryWithObjectsAndKeys:
				 @"flickr", @"title",
				 [cFlickrPD initWithDefaults], @"delegate",
				 nil],
				nil];
    }
    return self;
}

- (void)dealloc
{
	[pvc release];
	
    [super dealloc];
}

#pragma mark -

- (void) initNavigaationBar
{
	self.navigationItem.title = NSLocalizedString(@"Pictures Library", @"");
}


#pragma mark tableView delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [list count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	UITableViewCell *rv = nil;
	
	static NSString *cellID = @"title_cell_ID";
	rv = [tableView dequeueReusableCellWithIdentifier:cellID];
	if (rv == nil)
	{
		rv = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
	}
	rv.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	NSDictionary *object = [list objectAtIndex:indexPath.row];
	rv.textLabel.text = NSLocalizedString([object objectForKey:@"title"], @"");

	return rv;
}

- (void) deselect
{
	[tv deselectRowAtIndexPath:[tv indexPathForSelectedRow] animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self performSelector:@selector(deselect) withObject:nil afterDelay:.5f];
	
	if (!pvc)
	{
		pvc = [[picturesViewController alloc] init];
		pvc.pagesWindow = 5;
	}
	NSDictionary *object = [list objectAtIndex:indexPath.row];
	id<abstractPictureDelegate, picturesViewControllerDelegate> engine = [object objectForKey:@"delegate"];
	pvc.index = 0;
	pvc.delegate = engine;
	
	if ([engine respondsToSelector:@selector(abstractPictureDelegateOnShow:)])
	{
		[engine abstractPictureDelegateOnShow:pvc];
	}

	[pvc reloadData];
	[self.navigationController pushViewController:pvc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat rv = tableView.rowHeight;
	return rv;
}


#pragma mark -

- (void) viewDidAppear:(BOOL)animated
{
	if (pvc.delegate)
	{
		id<abstractPictureDelegate, picturesViewControllerDelegate> engine = (id<abstractPictureDelegate, picturesViewControllerDelegate>)pvc.delegate;
		if ([engine respondsToSelector:@selector(abstractPictureDelegateOnUnShow:)])
		{
			[engine abstractPictureDelegateOnUnShow:pvc];
		}
	}
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation
{
	return YES;
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation
										  duration:(NSTimeInterval) duration
{
    CGRect screenRect = self.view.bounds;
//    CGRect rct;
    
	tv.frame = screenRect;
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
	[super loadView];
	
	CGRect applicationFrame = [[UIScreen mainScreen] bounds];
	UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
	
	// important for view orientation rotation
	contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);	
	self.view = contentView;	
	[contentView release];
	
	[self initNavigaationBar];

	tv = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
	tv.delegate = self;
	tv.dataSource = self;
	tv.autoresizesSubviews = YES;
	tv.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:tv];
	
    [self performSelector:@selector(checkSize) withObject:nil afterDelay:.05];
}

- (void) checkSize
{
    [self willAnimateRotationToInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation] duration:.0];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
	[tv release];
	tv = nil;
	[pvc release];
	pvc = nil;
}

@end
