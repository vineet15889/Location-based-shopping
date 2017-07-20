#import "FavTableViewController.h"
#import "internet.h"
#import "HUD.h"
@interface FavTableViewController ()
@property (nonatomic, strong) NSMutableArray *vendor;
@end
@implementation FavTableViewController

- (void)viewDidLoad{
[super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated{
     [_rotate startAnimating];
    internet *myclass = [[internet alloc]init];
    if ([myclass connectedToInternet]) {
        NSData *mydata = [[NSUserDefaults standardUserDefaults] objectForKey:@"myUser"];
        NSMutableDictionary *savedDict = [NSKeyedUnarchiver unarchiveObjectWithData:mydata];
        NSString *userId = [savedDict valueForKey:@"id"];
        dispatch_queue_t fetchQ = dispatch_queue_create("offers", NULL);
        dispatch_async(fetchQ, ^{
            NSDictionary *dictionary = @{@"id":userId};
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
            
            NSURL *url = [NSURL URLWithString:@"http://moglee.in/user_favourites.php"];
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
                    self.vendor = [arrayOfEntery mutableCopy];
                    [_rotate stopAnimating];
                }
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_rotate stopAnimating];
                [_rotateViews setHidden:YES];
                [_myTable reloadData];
            });
        });
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet!"
                                                        message:@"No working internet connection is found. If Wi-FI is enabled, try disabling Wi-Fi or try another Wi-Fi hotspot"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [_rotate stopAnimating];
        [_rotateViews setHidden:YES];

    }

}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    return [self.vendor count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Fav";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
     NSMutableArray *offer = self.vendor[indexPath.row];
     cell.textLabel.text = [[offer valueForKey:@"vendor_name"]capitalizedString];
    cell.detailTextLabel.text =[[offer valueForKey:@"vendor_address"]capitalizedString];
   
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [HUD showUIBlockingIndicatorWithText:@"Deleting"];
        internet *myclass = [[internet alloc]init];
        if ([myclass connectedToInternet]) {
        NSData *mydata = [[NSUserDefaults standardUserDefaults] objectForKey:@"myUser"];
        NSMutableDictionary *savedDict = [NSKeyedUnarchiver unarchiveObjectWithData:mydata];
        NSString *userId = [savedDict valueForKey:@"id"];
        NSDictionary *offer =[self.vendor objectAtIndex:indexPath.row];
        NSString *vendorId = [offer objectForKey:@"vender_id"];
        dispatch_queue_t fetchQ = dispatch_queue_create("login", NULL);
        dispatch_async(fetchQ, ^{
           
             NSDictionary *dictionary = @{@"del_id":userId,@"del_vender_id":vendorId};
            NSError *error = nil;
            NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
            if (error)
            {
               
                NSString *err = [[NSString alloc]initWithFormat:@"%@",error ];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                message:err
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                [HUD hideUIBlockingIndicator];
            }
            
            // create the request
            NSURL *url = [NSURL URLWithString:@"http://moglee.in/user_favourites.php"];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:data];
            
            // issue the request
            
            NSURLResponse *response = nil;
           [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            if (error)
            {
               
                NSString *err = [[NSString alloc]initWithFormat:@"%@",error ];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                message:err
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                [HUD hideUIBlockingIndicator];
            }
             
            // examine the response
          
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [HUD hideUIBlockingIndicator];
                [self.vendor removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
              });
          });
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet!"
                                                            message:@"No working internet connection is found. If Wi-FI is enabled, try disabling Wi-Fi or try another Wi-Fi hotspot"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [HUD hideUIBlockingIndicator];
            [_rotate stopAnimating];
            [_rotateViews setHidden:YES];
        }
        
        
      
        
   }

}

- (IBAction)del:(id)sender {
    internet *myclass = [[internet alloc]init];
    if ([myclass connectedToInternet]) {
        NSData *mydata = [[NSUserDefaults standardUserDefaults] objectForKey:@"myUser"];
        NSMutableDictionary *savedDict = [NSKeyedUnarchiver unarchiveObjectWithData:mydata];
        NSString *userId = [savedDict valueForKey:@"id"];
        // NSLog(@"%@",dictionary);
        dispatch_queue_t fetchQ = dispatch_queue_create("login", NULL);
        dispatch_async(fetchQ, ^{
            NSDictionary *dictionary = @{@"del_all_id":userId};
            NSError *error = nil;
            NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
            if (error)
            {
                
                NSString *err = [[NSString alloc]initWithFormat:@"%@",error ];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                message:err
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            
            // create the request
            NSURL *url = [NSURL URLWithString:@"http://moglee.in/user_favourites.php"];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:data];
            
            // issue the request
            
            NSURLResponse *response = nil;
            [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            if (error)
            {
                
                NSString *err = [[NSString alloc]initWithFormat:@"%@",error ];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                message:err
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            
            // examine the response
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
            });
        });
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet!"
                                                        message:@"No working internet connection is found. If Wi-FI is enabled, try disabling Wi-Fi or try another Wi-Fi hotspot"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [_rotate stopAnimating];
        [_rotateViews setHidden:YES];
        
    }
    _vendor = nil;
    [_myTable reloadData];
}


@end