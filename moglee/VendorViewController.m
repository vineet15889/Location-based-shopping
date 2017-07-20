#import "VendorViewController.h"
#import "MYUtil.h"
#import "internet.h"
@interface VendorViewController ()
@end
@implementation VendorViewController
@synthesize venderName = _venderName;
@synthesize offerEnd =_offerEnd;
@synthesize openningTime = _openningTime;
@synthesize image = _image;
@synthesize address = _address;

- (void)viewDidLoad {
   [super viewDidLoad];
    [self.view bringSubviewToFront:_rorateView];
    [_rotate startAnimating];
}

-(void)viewDidAppear:(BOOL)animated{
    [self.view bringSubviewToFront:_rorateView];
    self.relatedOffers = nil;
    [_rotate startAnimating];
   [super viewDidAppear:YES];    
    _image.image = [UIImage imageNamed:@"placeholder"];
    NSData *dataSave = [NSKeyedArchiver archivedDataWithRootObject:@"YES"];
    [[NSUserDefaults standardUserDefaults] setObject:dataSave forKey:@"launch"];
    if (![_offers count]) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"vendorOffer"];
        NSDictionary *savedArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        self.offers = savedArray;
    }
    
    if ([_offers valueForKeyPath:@"vendor_name"]) {
        _venderName.text = [_offers valueForKeyPath:@"vendor_name"];
    }
    if ([_offers valueForKeyPath:@"vendor_location"]) {
        _sublocation.text = [[NSString stringWithFormat:@"(%@)",[_offers valueForKeyPath:@"vendor_location"]]capitalizedString];
        
        _venderName.text = [[_offers valueForKeyPath:@"vendor_name"]capitalizedString];
    }
    
    if ([_offers valueForKeyPath:@"offer_desc"]) {
        _off.text =[[_offers valueForKey:@"offer_desc"]capitalizedString];
    }
    if ([_offers valueForKeyPath:@"vendor_address"]) {
        _address.text = [[_offers valueForKeyPath:@"vendor_address"]capitalizedString];
    }
    
    if ([_offers valueForKeyPath:@"opening_hours"]) {
        _openningTime.text = [[_offers valueForKeyPath:@"opening_hours"]capitalizedString];
    }
    if ([_offers valueForKeyPath:@"rating"]) {
        _reting.text = [_offers valueForKeyPath:@"rating"];
    }
    if ([_offers valueForKeyPath:@"offer_valid_upto"]) {
        _offerEnd.text = [_offers valueForKeyPath:@"offer_valid_upto"];
    }
    if ([_offers valueForKeyPath:@"rating"]) {
        _reting.text = [_offers valueForKeyPath:@"rating"];
    }else{
        _reting.text = @"0";
    }
    
    [self getImage];
    [_reletedViewOffer setHidden:NO];
    [self getReleted];

}

-(void)getImage{
    internet *myclass = [[internet alloc]init];
    if ([myclass connectedToInternet]) {

    if ([_offers valueForKeyPath:@"offer_image"]) {
        dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(q, ^{
            /* Fetch the image from the server... */
            NSURL *aURL = [NSURL URLWithString:[[_offers valueForKeyPath:@"offer_image"] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
            UIImage *aImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:aURL]];
            UIImage *image = [MYUtil imageWithImage:aImage scaledToSize:CGSizeMake(267, 189)];
            aImage = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                /* This is the main thread again, where we set the tableView's image to
                 be what we just fetched. */
                _image.image = image;
              
            });
        });
    }}else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet!"
                                                        message:@"No working internet connection is found. If Wi-FI is enabled, try disabling Wi-Fi or try another Wi-Fi hotspot"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [self.view sendSubviewToBack:_rorateView];
        [_rotate stopAnimating];
    }

}

-(void)viewDidDisappear:(BOOL)animated{
    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(q, ^{

    NSData *dataSave = [NSKeyedArchiver archivedDataWithRootObject:nil];
    [[NSUserDefaults standardUserDefaults] setObject:dataSave forKey:@"vendorOffer"];
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    });

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)fav:(id)sender {
    [self.view bringSubviewToFront:_rorateView];
    [_rotate startAnimating];
    internet *myclass = [[internet alloc]init];
    if ([myclass connectedToInternet]) {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *myStringName = [prefs stringForKey:@"currentCategory"];
    NSData *mydata = [[NSUserDefaults standardUserDefaults] objectForKey:@"myUser"];
    NSMutableDictionary *savedDict = [NSKeyedUnarchiver unarchiveObjectWithData:mydata];
    NSString *userId = [savedDict valueForKey:@"id"];
   
    NSString *VenderValue = [_offers valueForKey:@"vendor_id"];
    NSString *offerValue = [_offers valueForKey:@"offer_id"];
    if (offerValue && VenderValue && myStringName &&  userId){
        
        NSDictionary *dictionary = @{@"vendor_id": VenderValue ,@"offer_id": offerValue, @"user_id": userId ,@"category": myStringName };
            NSError *error = nil;
            NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
            if (error)
            {
                [self.view sendSubviewToBack:_rorateView];
                [_rotate stopAnimating];
                NSString *err = [[NSString alloc]initWithFormat:@"%@",error ];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                message:err
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }

            
            // create the request
            
            NSURL *url = [NSURL URLWithString:@"http://moglee.in/vendor.php"];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:data];
            // examine the response
            NSURLResponse *requestResponse;
            NSData *requestHandler = [NSURLConnection sendSynchronousRequest:request returningResponse:&requestResponse error:nil];
          
                
        [self.view sendSubviewToBack:_rorateView];
        [_rotate stopAnimating];
                NSString *requestReply = [[NSString alloc] initWithBytes:[requestHandler bytes] length:[requestHandler length] encoding:NSASCIIStringEncoding];
                     if (requestReply) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:requestReply
                                                                        message:@""
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                        [alert show];
                        
           }
    }
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet!"
                                                        message:@"No working internet connection is found. If Wi-FI is enabled, try disabling Wi-Fi or try another Wi-Fi hotspot"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [self.view sendSubviewToBack:_rorateView];
        [_rotate stopAnimating];

    }
}

-(void)getReleted{
    internet *myclass = [[internet alloc]init];
    if ([myclass connectedToInternet]) {
        dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(q, ^{
        NSDictionary *dictionary = @{@"offer_id":[_offers valueForKeyPath:@"offer_id"],@"vender_id": [_offers valueForKeyPath:@"vendor_id"],@"category": [_offers valueForKeyPath:@"vendor_type"]};
           
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
        }
        
        NSURL *url = [NSURL URLWithString:@"http://moglee.in/related_offer.php"];
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
        }else{
            
            NSMutableDictionary * dict=[NSJSONSerialization JSONObjectWithData:requestHandler options:NSJSONReadingMutableContainers error:&error];
            if([NSJSONSerialization isValidJSONObject:dict]){
                NSDictionary *allDataDict = [NSJSONSerialization JSONObjectWithData:requestHandler options:0 error:nil];
                NSArray * arrayOfEntery = [allDataDict objectForKey:@"feed"];
                self.relatedOffers = arrayOfEntery;
                if ([self.relatedOffers count]) {
                    _noRelatedOffer.text =@"";
                    [_noRelatedOffer removeFromSuperview];
                }
                arrayOfEntery = nil;
            }
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view sendSubviewToBack:_rorateView];
            [_rotate stopAnimating];
            [self getimageV];
        });
    });
 }else{
     [self.view sendSubviewToBack:_rorateView];
     [_rotate stopAnimating];
    }

}

-(void)getimageV{
    internet *myclass = [[internet alloc]init];
    if ([myclass connectedToInternet]) {
    NSUInteger x =[_relatedOffers count];
    self.scrollViewtest.contentSize = CGSizeMake(x*152, _scrollViewtest.frame.size.height);
    for (int pos=0; pos<[_relatedOffers count]; pos++) {       
        
        UIButton* aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [aButton setTag:pos];
        [aButton setBackgroundColor:[UIColor redColor]];
        [aButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        CGRect buttonFrame = CGRectMake(pos*150, 0, 158, 70);
        buttonFrame.size = CGSizeMake(140, 90);
        aButton.frame = buttonFrame;       
        [self.reletedViewOffer addSubview:aButton];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *myOrigan = [_relatedOffers objectAtIndex:pos];
            NSURL *aURL = [NSURL URLWithString:[[myOrigan valueForKeyPath:@"offer_image"]stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
            UIImage *aImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:aURL]];
            UIImage *image = [MYUtil imageWithImage:aImage scaledToSize:CGSizeMake(158, 70)];
            aImage = nil;
            if(image)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                [aButton setBackgroundImage:image forState:normal];
                    
                });
            }
        });
        
    }
    }else{
        [self.view sendSubviewToBack:_rorateView];
        [_rotate stopAnimating];
    }
}

- (void)buttonClicked:(UIButton*)button {  [self.view bringSubviewToFront:_rorateView];
    [_rotate startAnimating];
    [_reletedViewOffer setHidden:YES];
     _offers =nil;
     _offers = [_relatedOffers objectAtIndex:[button tag]];
    NSArray * allSubviews = [self.reletedViewOffer subviews];
    for(UIView *view in allSubviews)
    {
        if([view isMemberOfClass:[UIButton class]])
        {
            [view removeFromSuperview];
        }
    }    
     [self viewDidLoad];
     [self viewDidAppear:YES];
}

@end
