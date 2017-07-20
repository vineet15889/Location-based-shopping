#import "AddBussViewController.h"
#import "internet.h"
#import "HUD.h"
@interface AddBussViewController ()
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) UITextField *activeField;
@end
@implementation AddBussViewController

-(void)dismissKeyboard {
    [_name resignFirstResponder];
    [_email resignFirstResponder];
    [_mobile resignFirstResponder];
    [_message resignFirstResponder];
}

-(void)viewDidAppear:(BOOL)animated{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                      attribute:NSLayoutAttributeLeading
                                                                      relatedBy:0
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1.0
                                                                       constant:0];
    [self.view addConstraint:leftConstraint];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                       attribute:NSLayoutAttributeTrailing
                                                                       relatedBy:0
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1.0
                                                                        constant:0];
    [self.view addConstraint:rightConstraint];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

}

- (IBAction)textFieldDidBeginEditing:(UITextField *)sender{
    self.activeField = sender;
}

- (IBAction)textFieldDidEndEditing:(UITextField *)sender{
    self.activeField = nil;
}

- (void) keyboardDidShow:(NSNotification *)notification{
    NSDictionary* info = [notification userInfo];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    kbRect = [self.view convertRect:kbRect fromView:nil];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbRect.size.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbRect.size.height;
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:self.activeField.frame animated:YES];
    }
}

- (void) keyboardWillBeHidden:(NSNotification *)notification{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)add:(id)sender {
    [self dismissKeyboard];
    [HUD showUIBlockingIndicatorWithText:@"Submitting"];
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
                NSString * stringPass = _message.text;
                if (![stringPass length]) {
                    [HUD hideUIBlockingIndicator];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                    message:@"Give some description"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                  
                }else{
                    
                    dispatch_queue_t fetchQ = dispatch_queue_create("login", NULL);
                    dispatch_async(fetchQ, ^{
                        NSDictionary *dictionary = @{@"name": _name.text,@"email": _email.text,@"mobile": _mobile.text,@"msg": _message.text};
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
                        NSURL *url = [NSURL URLWithString:@"http://moglee.in/add_business.php"];
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
                        NSString *outputY = @"Sucessfully Submitted";
                        NSString *newOutputY = [NSString stringWithFormat:@"\"%@\"", outputY];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [HUD hideUIBlockingIndicator];
                            if ([responseString isEqualToString:newOutputY]) {
                                double delayInSeconds = 1.5;
                                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                    [self.navigationController popViewControllerAnimated:YES];
                                    [HUD hideUIBlockingIndicator];
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                                    message:responseString
                                                                                   delegate:nil
                                                                          cancelButtonTitle:@"OK"
                                                                          otherButtonTitles:nil];
                                    [alert show];
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

-(BOOL) NSStringIsValidEmail:(NSString *)checkString{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

@end
