#import "MegaTableViewController.h"
#import "CustomTableViewCell.h"
#import "MYUtil.h"
@interface MegaTableViewController ()
{
    NSMutableData *webData;
    NSURLConnection *connection;
    NSCache *imageCache;
}

@property (weak, nonatomic) IBOutlet UITableView *myTable;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *rotate;
@end

@implementation MegaTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self tableView] setDelegate:self];
    [[self tableView]setDataSource:self];
    UIEdgeInsets inset = UIEdgeInsetsMake(63, 0, 0, 0);
    self.tableView.contentInset = inset;
    imageCache = [[NSCache alloc] init];
    [self fetchData];
   

}
-(void)viewDidAppear:(BOOL)animated{
    NSData *dataSave = [NSKeyedArchiver archivedDataWithRootObject:@"NO"];
    [[NSUserDefaults standardUserDefaults] setObject:dataSave forKey:@"launch"];
}
-(void)fetchData{
    [_rotate startAnimating];
    NSURL *url= [NSURL URLWithString:@"http://moglee.in/mega_offer_show.php"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (connection) {
        webData = [[NSMutableData alloc]init];
    }
 
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.offers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"megaCell";
    CustomTableViewCell *cell = [_myTable dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
     NSDictionary *offer = self.offers[indexPath.row];
    
    NSString* url = [offer objectForKey:@"offer_image"];
    
    UIImage *image = [imageCache objectForKey:url];
    
    if(image)
    {
        cell.cellImage.image = nil;
        cell.cellImage.image = image;
    }
    else
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL *aURL = [NSURL URLWithString:[[offer valueForKeyPath:@"offer_image"] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
            UIImage *imageBig = [UIImage imageWithData:[NSData dataWithContentsOfURL:aURL]];
            UIImage *image = [MYUtil imageWithImage:imageBig scaledToSize:CGSizeMake(150, 85)];
            
            if(image)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    CustomTableViewCell *cell =(CustomTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
                    if(cell)
                    {
                        cell.cellImage.image = nil;
                        cell.cellImage.image = image;
                    }
                });
                [imageCache setObject:image forKey:url];
            }else{
                cell.imageView.image = [UIImage imageNamed:@"placeholder"];
            }
        });
    }
    
    cell.offer.text = [[offer valueForKeyPath:@"offer_desc"]capitalizedString];
    cell.offerSub.text = [[offer valueForKeyPath:@"vendor_name"]capitalizedString];
    
    return cell;
}
- (void)didReceiveMemoryWarning {
    [imageCache removeAllObjects];
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [webData setLength:0];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [webData appendData:data];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet!"
                                                    message:@"No working internet connection is found. If Wi-FI is enabled, try disabling Wi-Fi or try another Wi-Fi hotspot"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [_rotate stopAnimating];
    [_rotate removeFromSuperview];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSDictionary *allDataDict = [NSJSONSerialization JSONObjectWithData:webData options:0 error:nil];
    NSMutableArray * arrayOfEntery = [allDataDict objectForKey:@"feed"];
    self.offers = arrayOfEntery;
    [_myTable reloadData];
    [_rotate stopAnimating];
   [_rotate removeFromSuperview];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    id detail = self.splitViewController.viewControllers[1];
    if ([detail isKindOfClass:[UINavigationController class]]) {
        detail = [((UINavigationController *)detail).viewControllers firstObject];
    }
    if ([detail isKindOfClass:[VendorViewController class]]) {
        [self prepareVendorViewController:detail toDisplayoffer:self.offers[indexPath.row]];
    }
}

#pragma mark - Navigation

- (void)prepareVendorViewController:(VendorViewController *)mvc
                     toDisplayoffer:(NSDictionary *)offer
{
   mvc.offers = offer;
 }

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [_myTable indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Display Mega"]) {
                if ([segue.destinationViewController isKindOfClass:[VendorViewController class]]) {
                    [self prepareVendorViewController:segue.destinationViewController
                                       toDisplayoffer:self.offers[indexPath.row]];
                    
                    
                }
            }
        }
    }
}

@end
