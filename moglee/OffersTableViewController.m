#import "OffersTableViewController.h"
#import "CustomTableViewCell.h"
#import "VendorViewController.h"
#import "MYUtil.h"
@interface OffersTableViewController (){
    NSCache *imageCache;
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *rotate;
@end

@implementation OffersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIEdgeInsets inset = UIEdgeInsetsMake(63, 0, 0, 0);
    self.myTable.contentInset = inset;
     imageCache = [[NSCache alloc] init];
    [_rotate startAnimating];
    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(q, ^{
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"radiousOfferOnMap"];
        NSArray *savedArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSMutableArray *puredata = [[NSMutableArray alloc]init];
        for (NSArray *myArray in savedArray){
            if (![[myArray valueForKeyPath:@"offer_desc"] isEqualToString:@"no offer"]) {
                [puredata addObject:myArray];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.offers = puredata;
            [self.myTable reloadData];
            if (![self.offers count]) {
                [_rotate stopAnimating];
                [_rotate removeFromSuperview];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No offer!"
                                                                message:@"Sorry we unable to get any offer here. but still you can find offer from other location. "
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                
                
            }
            [_rotate stopAnimating];
            [_rotate removeFromSuperview];
        });
    });
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    NSData *dataSave = [NSKeyedArchiver archivedDataWithRootObject:@"NO"];
    [[NSUserDefaults standardUserDefaults] setObject:dataSave forKey:@"launch"];
    
}

- (void)setOffers:(NSArray *)offers{
    _offers = offers;
    [_myTable reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.offers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"cell";
     CustomTableViewCell *cell = [_myTable dequeueReusableCellWithIdentifier:@"cell"];
    
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

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
   
}
#pragma mark - Table view delegate

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
                     toDisplayoffer:(NSDictionary *)offer{
    mvc.offers = offer;
}

-(void)didReceiveMemoryWarning{
   [imageCache removeAllObjects];
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Display"]) {
                if ([segue.destinationViewController isKindOfClass:[VendorViewController class]]) {
                    [self prepareVendorViewController:segue.destinationViewController
                                     toDisplayoffer:self.offers[indexPath.row]];
  
                }
            }
        }
    }
}

@end
