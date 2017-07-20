#import <UIKit/UIKit.h>
#import "VendorViewController.h"
@interface AllOffersTableViewController : UITableViewController
@property (nonatomic, strong) NSMutableArray *offers;
@property (weak, nonatomic) IBOutlet UITableView *myTable;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *rotate;
@property NSString* cat;
@property BOOL myState;
@end
