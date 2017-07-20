#import "SignUpViewController.h"
#import "ViewController.h"
#import "HUD.h"
#import "internet.h"
@interface SignUpViewController ()

@end

@implementation SignUpViewController

-(void)dismissKeyboard {
    [_password resignFirstResponder];
    [_mobile resignFirstResponder];
    [_name resignFirstResponder];
    [_email resignFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}

- (IBAction)createAccount:(id)sender {
    [HUD showUIBlockingIndicatorWithText:@"SignUp"];
    internet *myclass = [[internet alloc]init];
    if ([myclass connectedToInternet]) {
    
    if ([self NSStringIsValidEmail:_email.text]) {
        NSString * stringMobi = _mobile.text;
        if ([stringMobi length] < 10  || [stringMobi length] > 10   ) {
            [HUD hideUIBlockingIndicator];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                            message:@"Invalid Mobile"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
        }else{
         NSString * stringPass = _password.text;
        if ([stringPass length] < 6) {
            [HUD hideUIBlockingIndicator];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                            message:@"Password lenth must be 6"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
      
        }else{
    
    dispatch_queue_t fetchQ = dispatch_queue_create("login", NULL);
    dispatch_async(fetchQ, ^{
   NSDictionary *dictionary = @{@"username": _name.text,@"email": _email.text,@"mobile": _mobile.text,@"pass": _password.text};
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
           
            NSString *outputY = @"Sucessfully registered";
            NSString *newOutputY = [NSString stringWithFormat:@"\"%@\"", outputY];
        dispatch_async(dispatch_get_main_queue(), ^{
            [HUD hideUIBlockingIndicator];
            if ([responseString isEqualToString:newOutputY]) {
                double delayInSeconds = 1.5;                
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [HUD hideUIBlockingIndicator];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                    message:responseString
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];

                    [self.navigationController popViewControllerAnimated:YES];
                });
            }else {
                [HUD hideUIBlockingIndicator];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:responseString
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];

            }
        });
    });
          }
        }
    }else{
        NSString *test;
        test=_email.text;
        if ([ test isEqualToString:@""]) {
            [HUD hideUIBlockingIndicator];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                            message:@"Some fields are Missing"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }else{
            [HUD hideUIBlockingIndicator];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                            message:@"Invalid email address"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
          }
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"signup"]) {
      
  }
}

@end
