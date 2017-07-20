#import "MapViewController.h"
#import "MyTabController.h"
#import "MyCustomAnnotation.h"
#import "VendorViewController.h"
#import "AllOffersTableViewController.h"
@interface MapViewController ()
@property bool firstLaunch;
@property (weak, nonatomic) IBOutlet UILabel *area;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UISearchBar *search;
@property (weak, nonatomic) IBOutlet UIView *rotateViews;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *rotate;
@property BOOL count;
@property double regionarea;

@end

@implementation MapViewController
@synthesize map = _map;
@synthesize myString;
@synthesize firstLaunch;
@synthesize locationManager =_locationManager;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setTabBarVisible:(BOOL)visible animated:(BOOL)animated {
    if ([self tabBarIsVisible] == visible) return;
    CGRect frame = self.tabBarController.tabBar.frame;
    CGFloat height = frame.size.height;
    CGFloat offsetY = (visible)? -height : height;
   
    CGFloat duration = (animated)? 0.3 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        self.tabBarController.tabBar.frame = CGRectOffset(frame, 0, offsetY);
        self.tabBarController.tabBar.hidden = (visible)? NO : YES;
    }];
    
}

- (BOOL)tabBarIsVisible {
    return self.tabBarController.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame);
}

-(void)dismissKeyboard {
    [_search resignFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated{
    [_map removeOverlay:_circle];
    _circle =nil;
    _circleView = nil;
    [super viewWillAppear:YES];
    [self setTabBarVisible:NO animated:NO];
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"launch"];
    _launch = [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    if ([_launch isEqualToString:@"YES"]) {
        [self setTabBarVisible:YES animated:NO];
        NSData *dataSave = [NSKeyedArchiver archivedDataWithRootObject:@"NO"];
        [[NSUserDefaults standardUserDefaults] setObject:dataSave forKey:@"launch"];
    }else{
    [_map removeOverlay:_circle];
    _circle =nil;
    _circleView = nil;
    //Hiding The Keyboard on Tab *******
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    [self getCurrentLocation];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *myCat = [prefs stringForKey:@"currentCategory"];
    _cat = myCat;
    [self setTitleArea]; // Set Location Title
    firstLaunch = YES;
    _count = YES;
   [self.view bringSubviewToFront:_topView];
     _lables.text = @"Searching";
    [_rotate startAnimating];
    [_topView bringSubviewToFront:_rotateViews];
    [_rotateViews setHidden:NO];
   [self removeAllPinsButUserLocation2];
    }
    
}

-(void)viewDidDisappear:(BOOL)animated{
     [super viewDidDisappear:YES];
    [_rotate stopAnimating];
   
}

-(void) getCurrentLocation{
    self.map.delegate = self;
    [self.map setShowsUserLocation:YES];
    self.locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    [_locationManager startUpdatingLocation];
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    if (firstLaunch) {
        [self updateLabel];
        [self setTitleArea];
        firstLaunch = NO;
    }
}

- (void) updateLabel{
    _lat = [[NSString stringWithFormat:@"%f", _locationManager.location.coordinate.latitude] doubleValue];
    _lon = [[NSString stringWithFormat:@"%f", _locationManager.location.coordinate.longitude] doubleValue];
}

- (void)removeAllPinsButUserLocation2{
    id userLocation = [_map userLocation];
    NSMutableArray *pins = [[NSMutableArray alloc] initWithArray:[_map annotations]];
    if ( userLocation != nil ) {
        [pins removeObject:userLocation]; // avoid removing user location off the map
    }
    [_map removeAnnotations:pins];
    pins = nil;
}

-(void)setTitleArea{
    MKCoordinateRegion region;
    region = MKCoordinateRegionMakeWithDistance(_locationManager.location.coordinate,1500,1500);
    [_map setRegion:region animated:NO];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:self.locationManager.location
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       
                       if (error){
                           if (_count) {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet!"
                                                                               message:@"No working internet connection is found. If Wi-FI is enabled, try disabling Wi-Fi or try another Wi-Fi hotspot"
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil];
                               [alert show];

                               [_rotate stopAnimating];
                                _lables.text = @"";
                               [_topView sendSubviewToBack:_rotateViews];
                               [_rotateViews setHidden:YES];
                               
                               [self.navigationController popViewControllerAnimated:YES];
                               _count = NO;
                           }
                           
                           return;
                        }                       
                       CLPlacemark *placemark = [placemarks objectAtIndex:0];
                       NSString *loc = [[NSString alloc]initWithFormat:@"%@",placemark.subLocality ];
                       _area.text = loc;
                       if (_area.text) {
                           [_rotate stopAnimating];
                           _lables.text = @"";
                           [_topView sendSubviewToBack:_rotateViews];
                            [_rotateViews setHidden:YES];
                          
                       }
       }];
}

#pragma mark - MKMapViewDelegate methods.

- (void)mapView:(MKMapView *)map didAddAnnotationViews:(NSArray *)views{

}

 - (void)getmapset{
    MKCoordinateRegion region;
      region = MKCoordinateRegionMakeWithDistance(_locationManager.location.coordinate,1500,1500);
    [_map setRegion:region animated:NO];
   }

// Set the region for selected option

- (IBAction)firstDistance:(id)sender {
    _regionarea = .25;
    [self getLocation:_regionarea];
}
- (IBAction)secondDistance:(id)sender {
    _regionarea = .5;
    [self getLocation:_regionarea];

}
- (IBAction)thirdDistance:(id)sender {
    _regionarea = 1;
    [self getLocation:_regionarea];
}
- (void)getLocation:(int)regionArea  {
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.backgroundColor = [UIColor blackColor];
    spinner.center = self.view.center;
    [self.view addSubview:spinner];
    if (_circle) {
        [_map removeOverlay:_circle];
    }
   
  
    dispatch_queue_t fetchQ = dispatch_queue_create("offers", NULL);
    dispatch_async(fetchQ, ^{
        [spinner startAnimating];
        NSDictionary *dictionary = @{@"latitude":[NSString stringWithFormat:@"%.20lf", _lat],@"longitude":[NSString stringWithFormat:@"%.20lf", _lon],@"category": _cat, @"radius": [NSString stringWithFormat:@"%.20lf", _regionarea]};
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
        if (error)
            NSLog(@"%s: JSON encode error: %@", __FUNCTION__, error);
        
        // create the request
        
        NSURL *url = [NSURL URLWithString:@"http://moglee.in/search_location.php"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:data];
        // examine the response
        
        NSURLResponse *requestResponse;
        NSData *requestHandler = [NSURLConnection sendSynchronousRequest:request returningResponse:&requestResponse error:&error];
        if (error){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet!"
                                                             message:@"No working internet connection is found. If Wi-FI is enabled, try disabling Wi-Fi or try another Wi-Fi hotspot"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
           
            

        }else{
       
        NSMutableDictionary * dict=[NSJSONSerialization JSONObjectWithData:requestHandler options:NSJSONReadingMutableContainers error:&error];
            if([NSJSONSerialization isValidJSONObject:dict]){
                NSDictionary *allDataDict = [NSJSONSerialization JSONObjectWithData:requestHandler options:0 error:nil];
                NSMutableArray * arrayOfEntery = [allDataDict objectForKey:@"feed"];
                 self.offers = arrayOfEntery;
                NSData *dataSave = [NSKeyedArchiver archivedDataWithRootObject:self.offers];
                [[NSUserDefaults standardUserDefaults] setObject:dataSave forKey:@"radiousOfferOnMap"];
                arrayOfEntery = nil;
              
            }
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [spinner stopAnimating];
           
            [self.view sendSubviewToBack:_topView];
            if (_regionarea ==.25) {
                if(![_offers count]){
                    [self setalert:_regionarea];
                }
                MKCoordinateRegion region;
                region = MKCoordinateRegionMakeWithDistance(_locationManager.location.coordinate,600,600);
                [_map setRegion:region animated:YES];
                 [_circleView removeFromSuperview];
                _circle= [MKCircle circleWithCenterCoordinate:_locationManager.location.coordinate radius:300];
                [_map addOverlay:_circle];
                
            }else if(_regionarea ==.5){
                if(![_offers count]){
                    [self setalert:_regionarea];
                }
                MKCoordinateRegion region;
                region = MKCoordinateRegionMakeWithDistance(_locationManager.location.coordinate,1200,1200);
                [_map setRegion:region animated:YES];
                [_circleView removeFromSuperview];
                
                _circle = [MKCircle circleWithCenterCoordinate:_locationManager.location.coordinate radius:600];
                [_map addOverlay:_circle];
                
            }else if(_regionarea ==1){
                if(![_offers count]){
                    [self setalert:_regionarea];
                }
                MKCoordinateRegion region;
                region = MKCoordinateRegionMakeWithDistance(_locationManager.location.coordinate,2500,2500);
                [_map setRegion:region animated:YES];
                 [_circleView removeFromSuperview];
                
                _circle = [MKCircle circleWithCenterCoordinate:_locationManager.location.coordinate radius:1200];
                [_map addOverlay:_circle];
            }
            else if(_regionarea ==20){
                if(![_offers count]){
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No merchant in your radius. Why not check out our other offers? "
                                                                    message:@""
                                                                   delegate:self
                                                          cancelButtonTitle:@"No!"
                                                          otherButtonTitles:@"Go", nil];
                    alert.tag = 10;
                    [alert show];
                }
                MKCoordinateRegion region;
                region = MKCoordinateRegionMakeWithDistance(_locationManager.location.coordinate,41000,41000);
                [_map setRegion:region animated:YES];
                [_circleView removeFromSuperview];
                _circle = [MKCircle circleWithCenterCoordinate:_locationManager.location.coordinate radius:20500];
                [_map addOverlay:_circle];
            }

            [self drowAnnotation];

            [self setTabBarVisible:YES animated:NO];
        });
    });    
}
-(void)setalert:(double)area{
    float myArea = area;
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.##"];
    NSString * mySString = [[NSString alloc]initWithFormat:@"No merchant in %@ km radius, Search a bigger radius?",[fmt stringFromNumber:[NSNumber numberWithFloat:myArea]] ];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:mySString
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Go!", nil];
    int areaInt = area*1000;
       alert.tag = areaInt;
    
    [alert show];

}
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        
    }
    else if (buttonIndex == 1) {
        
        if (alertView.tag == 250) {
            _regionarea = .5;
            [self getLocation:_regionarea];
        }else if(alertView.tag == 500){
            _regionarea = 1;
            [self getLocation:_regionarea];
        }else if(alertView.tag == 1000){
            _regionarea = 20;
            [self getLocation:_regionarea];
        }else if (alertView.tag == 10){
            [self performSegueWithIdentifier: @"showAll" sender: self];
            
        }

    }
    
}
-(void)drowAnnotation{
    NSMutableArray *anArray = [[NSMutableArray alloc]init];
    dispatch_queue_t fetchQ = dispatch_queue_create("mapAnnotation", NULL);
    dispatch_async(fetchQ, ^{
        for (int i=0; i<[self.offers count]; i++) {
            NSArray *anno = [self.offers objectAtIndex:i];
            CLLocationCoordinate2D myCoordinate;
            myCoordinate.longitude = [[anno valueForKey:@"longitude"] doubleValue];
            myCoordinate.latitude = [[anno valueForKey:@"latitude"]doubleValue];
            MyCustomAnnotation *annotation = [[MyCustomAnnotation alloc]initWithTitle:[[anno valueForKey:@"vendor_name"]capitalizedString] Location:myCoordinate];
            NSString * offerSub = [[NSString alloc]initWithFormat:@"%@",[[anno valueForKey:@"offer_desc"]capitalizedString]];
            annotation.subtitle = offerSub;
            [anArray addObject:annotation];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.map addAnnotations:anArray];
        });
    });
    anArray = nil;
}
// Custom Annotation
- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{
    
    if ([annotation isKindOfClass:[MyCustomAnnotation class ]]) {
        MyCustomAnnotation *myLocation = (MyCustomAnnotation*)annotation;
        MKAnnotationView * annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MyCustomAnnotation"];
        if(annotationView == nil){
            annotationView = myLocation.annotationView;
        }else
            annotationView.annotation = annotation;
        return annotationView;
        
    }else
        return nil;
}
- (MKOverlayView *)mapView:(MKMapView *)map viewForOverlay:(id <MKOverlay>)overlay{
    _circleView = [[MKCircleView alloc] initWithOverlay:overlay];
    _circleView.strokeColor = [[UIColor redColor ]colorWithAlphaComponent:0.6];
    _circleView.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
    return _circleView;
}
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    [self performSegueWithIdentifier:@"MYVendor" sender:self];
    _shopName = nil;
    _shopName =view.annotation.title;
    for (int i=0; i<[self.offers count]; i++) {
        self.anno = [self.offers objectAtIndex:i];
        if ([[[self.anno valueForKey:@"vendor_name"] capitalizedString] isEqualToString:_shopName]) {
        break;
       }
   }
    NSData *dataSave = [NSKeyedArchiver archivedDataWithRootObject:self.anno];
    [[NSUserDefaults standardUserDefaults] setObject:dataSave forKey:@"vendorOffer"];
    self.anno = nil;
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"showAll"]) {
        AllOffersTableViewController *mvc = (AllOffersTableViewController *)segue.destinationViewController;
        mvc.myState = YES;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
