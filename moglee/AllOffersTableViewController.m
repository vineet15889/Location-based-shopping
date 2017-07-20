#import "CustomTableViewCell.h"
#import "MYUtil.h"
#import "AllOffersTableViewController.h"
#import "internet.h"

@interface AllOffersTableViewController ()
{
    NSMutableData *webData;
    NSURLConnection *connection;
    NSCache *imageCache;
}

@end

@implementation AllOffersTableViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *myCat = [prefs stringForKey:@"currentCategory"];
    _cat = myCat;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [[self tableView] setDelegate:self];
    [[self tableView]setDataSource:self];
    if (!_myState) {
        UIEdgeInsets inset = UIEdgeInsetsMake(63, 0, 0, 0);
        self.tableView.contentInset = inset;
    }
    imageCache = [[NSCache alloc] init];
    [self fetchData];
    
}
-(void)viewDidAppear:(BOOL)animated{
    NSData *dataSave = [NSKeyedArchiver archivedDataWithRootObject:@"NO"];
    [[NSUserDefaults standardUserDefaults] setObject:dataSave forKey:@"launch"];
    
}
-(void)fetchData{
    [_rotate startAnimating];
    internet *myclass = [[internet alloc]init];
    if ([myclass connectedToInternet]) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *myCat = [prefs stringForKey:@"currentCategory"];
        _cat = myCat;
        NSDictionary *dictionary = @{@"category":_cat};
        NSError *error = nil;
         NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
            if (error){
                NSString *err = [[NSString alloc]initWithFormat:@"%@",error ];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                message:err
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                [_rotate stopAnimating];
            }
            
            // create the request
            
            NSURL *url = [NSURL URLWithString:@"http://moglee.in/all_offer.php"];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:data];
            // examine the response
            
            NSURLResponse *requestResponse;
            NSData *requestHandler = [NSURLConnection sendSynchronousRequest:request returningResponse:&requestResponse error:&error];
            if (error){
                NSString *err = [[NSString alloc]initWithFormat:@"%@",error ];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                message:err
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                [_rotate stopAnimating];
                
            }else{
                
                NSMutableDictionary * dict=[NSJSONSerialization JSONObjectWithData:requestHandler options:NSJSONReadingMutableContainers error:&error];
                if([NSJSONSerialization isValidJSONObject:dict]){
                    NSDictionary *allDataDict = [NSJSONSerialization JSONObjectWithData:requestHandler options:0 error:nil];
                    NSMutableArray * arrayOfEntery = [allDataDict objectForKey:@"feed"];
                    self.offers = [arrayOfEntery mutableCopy];
                    [_rotate stopAnimating];
                }
            }
    
        dispatch_async(dispatch_get_main_queue(), ^{
            [_rotate stopAnimating];
            [_rotate setHidden:YES];
            [_myTable reloadData];
        });
    });
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet!"
                                                        message:@"The Internet connection appears to be offline"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [_rotate stopAnimating];
        _offers = nil;
        [_myTable reloadData];
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
            if ([segue.identifier isEqualToString:@"all"]) {
                if ([segue.destinationViewController isKindOfClass:[VendorViewController class]]) {
                    [self prepareVendorViewController:segue.destinationViewController
                                       toDisplayoffer:self.offers[indexPath.row]];
                    
                    
                }
            }
        }
    }
}

@end
