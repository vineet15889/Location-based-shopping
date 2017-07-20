#import "forgotViewController.h"
#import "internet.h"
#import "HUD.h"
@interface forgotViewController ()
@end
@implementation forgotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

-(void)dismissKeyboard { 
    [_email resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)retrivePassword:(id)sender {
     [HUD showUIBlockingIndicatorWithText:@"Sending Mail"];
    internet *myclass = [[internet alloc]init];
    if ([myclass connectedToInternet]) {
  
    if ([self NSStringIsValidEmail:_email.text]) {
        NSDictionary *dictionary = @{@"email_id": _email.text};
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
        if (error){
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
        internet *myclass = [[internet alloc]init];
        if ([myclass connectedToInternet]) {
            NSURL *url = [NSURL URLWithString:@"http://moglee.in/users.php"];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:data];
            
            // issue the request
            
            NSURLResponse *response = nil;
            NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
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

            
            // examine the response
            
          NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
          [HUD hideUIBlockingIndicator];
           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:responseString
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }else{
            [HUD hideUIBlockingIndicator];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"Invalid email address"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    
    else{
        [HUD hideUIBlockingIndicator];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                        message:@"Invalid E-Mail"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
        
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

-(BOOL) NSStringIsValidEmail:(NSString *)checkString {
    BOOL stricterFilter = NO; 
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

@end
