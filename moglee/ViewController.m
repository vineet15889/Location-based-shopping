#import "ViewController.h"
#import "MyTabController.h"
#import "HUD.h"
#import "internet.h"
@interface ViewController ()
@property NSString *pass;
@property BOOL login;
@end
@implementation ViewController
@synthesize rotate =_rotate;
@synthesize pass = _pass;

- (void)viewDidLoad {
    [super viewDidLoad];
   NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"myUser"];
    NSArray *savedArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSString *loginString = [savedArray valueForKey:@"login"];
   if ([loginString isEqualToString:@"yes"]) {
   [self.view sendSubviewToBack:_childview];
   NSString* mystring = [savedArray valueForKey:@"dailyReward"];
   int i = [mystring doubleValue];
   i=i+1;
   NSString * reValue = [[NSString alloc]initWithFormat:@"%d",i];
   [savedArray setValue: reValue forKey:@"dailyReward"];
   NSData *dataSave = [NSKeyedArchiver archivedDataWithRootObject:savedArray];
   [[NSUserDefaults standardUserDefaults] setObject:dataSave forKey:@"myUser"];
   
   }
    [self rotateImageView]; // Start amimation when screen loaded
    if (![@"1" isEqualToString:[[NSUserDefaults standardUserDefaults]
                                objectForKey:@"aValue"]]) {
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"aValue"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //Action here
        
    }
    self.loginButton.delegate = self;
    self.loginButton.readPermissions = @[@"public_profile", @"email",@"user_friends"];
    
   
}

-(void)dismissKeyboard {
    [_userName resignFirstResponder];
    [_password resignFirstResponder];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"myUser"];
    NSArray *savedArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSString *loginString = [savedArray valueForKey:@"login"];
    if ([loginString isEqualToString:@"yes"]) {
        [self.view sendSubviewToBack:_childview];      

    }else{
        [self.view bringSubviewToFront:_childview];
    }
    NSData *dataSave = [NSKeyedArchiver archivedDataWithRootObject:@"NO"];
    [[NSUserDefaults standardUserDefaults] setObject:dataSave forKey:@"launch"];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"myUser"];
    NSArray *savedArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSString *loginString = [savedArray valueForKey:@"login"];
    if ([loginString isEqualToString:@"yes"]) {
        [self.view sendSubviewToBack:_childview];
    }else{
        [self.view bringSubviewToFront:_childview];
    }

   
}

-(void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView{
    
}

-(void)loginViewShowingLoggedInUser:(FBLoginView *)loginView{
    _login = YES;
  [self.view sendSubviewToBack:_childview];
    
}

-(void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user{
   
    NSData *mydata = [[NSUserDefaults standardUserDefaults] objectForKey:@"myUser"];
    NSMutableDictionary *savedDict = [NSKeyedUnarchiver unarchiveObjectWithData:mydata];
    if ([savedDict valueForKey:@"name"]) {
    }else{
    NSMutableDictionary *myUser = [[NSMutableDictionary alloc]init];
    [myUser setValue:[user objectForKey:@"id"] forKey:@"id"];
    [myUser setValue:[user objectForKey:@"gender"] forKey:@"sex"];
    [myUser setValue:[user objectForKey:@"email"] forKey:@"email"];
    [myUser setValue:[user objectForKey:@"gender"] forKey:@"gender"];
    [myUser setValue: user.name forKey:@"name"];
    [myUser setValue: @"facebook" forKey:@"type"];
    [myUser setValue: @"100" forKey:@"rewards"];
    [myUser setValue: @"1" forKey:@"dailyReward"];
    [myUser setValue: @"yes" forKey:@"login"];
    NSData *dataSave = [NSKeyedArchiver archivedDataWithRootObject:myUser];
    [[NSUserDefaults standardUserDefaults] setObject:dataSave forKey:@"myUser"];
    
    _userName.text = @"";
    _password.text = @"";
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

// Rotating the Image (Ring)

- (void) rotateImageView{
static CGFloat rotation = 0;
[UIView animateWithDuration: 4
                      delay: 0
                    options: UIViewAnimationOptionCurveLinear
                 animations:
 ^{
     rotation += M_PI/4;
     _rotate.transform = CGAffineTransformMakeRotation(rotation);
 }
                 completion: ^(BOOL finished){
     [self rotateImageView];
 }
 ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// Prepare segue for passing value

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"showShoping"]) {
        _pass = @"shop";
        MyTabController *mvc = (MyTabController *)segue.destinationViewController;
        mvc.myCategory = _pass;
    }
    if ([[segue identifier] isEqualToString:@"showTravel"]) {
        _pass = @"travel";
        MyTabController *mvc = (MyTabController *)segue.destinationViewController;
        mvc.myCategory = _pass;
    }
    if ([[segue identifier] isEqualToString:@"showFood"]) {
        _pass = @"food";
        MyTabController *mvc = (MyTabController *)segue.destinationViewController;
        mvc.myCategory = _pass;
    }

}

- (IBAction)login:(id)sender {
    [HUD showUIBlockingIndicatorWithText:@"Loging"];
    internet *myclass = [[internet alloc]init];
    if ([myclass connectedToInternet]) {    
    dispatch_queue_t fetchQ = dispatch_queue_create("login", NULL);
    dispatch_async(fetchQ, ^{
    NSDictionary *dictionary = @{@"name": _userName.text ,@"password": _password.text};
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    if (error)
    {
        [HUD hideUIBlockingIndicator];
        NSString *err = [[NSString alloc]initWithFormat:@"%@",error ];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                        message:err
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }

        
    // create the request

    NSURL *url = [NSURL URLWithString:@"http://moglee.in/users.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:data];
    // examine the response
    NSURLResponse *requestResponse;
    NSData *requestHandler = [NSURLConnection sendSynchronousRequest:request returningResponse:&requestResponse error:&error];
        if (error)
        {
            [HUD hideUIBlockingIndicator];
            NSString *err = [[NSString alloc]initWithFormat:@"%@",error ];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                            message:err
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }

     NSMutableDictionary * dict=[NSJSONSerialization JSONObjectWithData:requestHandler options:NSJSONReadingMutableContainers error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
       [HUD hideUIBlockingIndicator];

    if([NSJSONSerialization isValidJSONObject:dict]){
        NSDictionary *allDataDict = [NSJSONSerialization JSONObjectWithData:requestHandler options:0 error:nil];
        NSMutableArray * arrayOfEntery = [allDataDict objectForKey:@"feed"];
        NSArray *userData = [arrayOfEntery objectAtIndex:0];
        NSMutableDictionary *myUser = [[NSMutableDictionary alloc]init];
        [myUser setValue:[userData valueForKey:@"user_id"] forKey:@"id"];
        [myUser setValue:[userData valueForKey:@"user_id"] forKey:@"email"];
        [myUser setValue:[userData valueForKey:@"username"] forKey:@"name"];
        [myUser setValue:[userData valueForKey:@"phone_no"] forKey:@"mobile"];
        [myUser setValue:[userData valueForKey:@"password"] forKey:@"password"];
        [myUser setValue: @"manual" forKey:@"type"];
        [myUser setValue: @"100" forKey:@"rewards"];
        [myUser setValue: @"1" forKey:@"dailyReward"];
        [myUser setValue: @"yes" forKey:@"login"];
        NSData *dataSave = [NSKeyedArchiver archivedDataWithRootObject:myUser];
        [[NSUserDefaults standardUserDefaults] setObject:dataSave forKey:@"myUser"];
       
         [self.view sendSubviewToBack:_childview];
        _userName.text = @"";
        _password.text = @"";
       
    }else{
        
        NSString *requestReply = [[NSString alloc] initWithBytes:[requestHandler bytes] length:[requestHandler length] encoding:NSASCIIStringEncoding];
        
        
            [HUD hideUIBlockingIndicator];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                            message:requestReply
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
       

        if ([requestReply isEqualToString:@""]) {
            [HUD hideUIBlockingIndicator];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet!"
                                                            message:@"No working internet connection is found. If Wi-FI is enabled, try disabling Wi-Fi or try another Wi-Fi hotspot"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];

        }
        
    }
            
            
        });
    });
    [_password resignFirstResponder];
    [_userName resignFirstResponder];
   

    }else{
        [HUD hideUIBlockingIndicator];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet!"
                                                        message:@"No working internet connection is found. If Wi-FI is enabled, try disabling Wi-Fi or try another Wi-Fi hotspot"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
 }

@end
