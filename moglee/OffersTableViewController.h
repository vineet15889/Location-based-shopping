#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface OffersTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate,NSURLConnectionDataDelegate>
@property (nonatomic, strong) NSArray *offers;
@property (weak, nonatomic) IBOutlet UITableView *myTable;
@property BOOL launch;

@end
