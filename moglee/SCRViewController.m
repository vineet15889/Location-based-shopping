#import "SCRViewController.h"
#import "MYUtil.h"
#import "HUD.h"
#import "internet.h"
@interface SCRViewController ()
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) UITextField *activeField;

@end

@implementation SCRViewController
-(void)dismissKeyboard {
    [_name resignFirstResponder];
    [_email resignFirstResponder];
    [_mobile resignFirstResponder];
    [_address resignFirstResponder];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    NSData *mydata = [[NSUserDefaults standardUserDefaults] objectForKey:@"myUser"];
    NSMutableDictionary *savedDict = [NSKeyedUnarchiver unarchiveObjectWithData:mydata];
    _name.text = [savedDict valueForKey:@"name"];
    _email.text = [savedDict valueForKey:@"email"];
    _mobile.text = [savedDict valueForKey:@"mobile"];
    _address.text = [savedDict valueForKey:@"address"];
    _selectedDate.text = [savedDict valueForKey:@"bday"];
    //forKey:@"gender"];
    
   if ([[savedDict valueForKey:@"type"] isEqualToString:@"facebook"]) {
       
    }
    if ([savedDict valueForKey:@"image"]) {
         _manualProfilePic.image = [savedDict valueForKey:@"image"];
    }    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
}

- (void)viewDidLoad{
    [super viewDidLoad];
     [_dateView setHidden:YES];
    self.loginButton.delegate = self;
    self.loginButton.readPermissions = @[@"public_profile", @"email"];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

-(void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user{
    NSData *mydata = [[NSUserDefaults standardUserDefaults] objectForKey:@"myUser"];
    NSMutableDictionary *savedDict = [NSKeyedUnarchiver unarchiveObjectWithData:mydata];
    if ([savedDict valueForKey:@"image"]) {
        
    }else{
        [HUD showUIBlockingIndicatorWithText:@"Fetching Facebook Data"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL *aURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=90&height=90", [user objectID]]];
            UIImage *imageBig = [UIImage imageWithData:[NSData dataWithContentsOfURL:aURL]];
            if(imageBig)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                     _manualProfilePic.image = nil;
                    UIImage *image = [MYUtil imageWithImage:imageBig scaledToSize:CGSizeMake(90, 90)];
                    _manualProfilePic.image = image;
                    [savedDict setObject:image forKey:@"image"];
                    NSData *dataSave = [NSKeyedArchiver archivedDataWithRootObject:savedDict];
                    [[NSUserDefaults standardUserDefaults] setObject:dataSave forKey:@"myUser"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    [HUD hideUIBlockingIndicator];                    
                    
                });
            }
        });
    }
    

    }

- (IBAction)logout:(id)sender {
    
    if (FBSession.activeSession.isOpen)
    {
        [FBSession.activeSession closeAndClearTokenInformation];
    }
    NSData *dataSave = [NSKeyedArchiver archivedDataWithRootObject:nil];
    [[NSUserDefaults standardUserDefaults] setObject:dataSave forKey:@"myUser"];
    _name.text = @"";
    _email.text = @"";
    _mobile.text = @"";
    _address.text = @"";
    _manualProfilePic.image = nil;
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.navigationController popViewControllerAnimated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    });
    
    
}

- (IBAction)createAccount:(id)sender {
    [self dismissKeyboard];
    [HUD showUIBlockingIndicatorWithText:@"Updating"];
    NSData *mydata = [[NSUserDefaults standardUserDefaults] objectForKey:@"myUser"];
    NSMutableDictionary *savedDict = [NSKeyedUnarchiver unarchiveObjectWithData:mydata];
    if ([[savedDict valueForKey:@"type"] isEqualToString:@"facebook"]) {
       
        NSString *myLogin = [[NSString alloc]initWithFormat:@"%d",1];
        NSString *myBithday = [[NSString alloc]init];
        if (_selectedDate.text) {
            myBithday = _selectedDate.text;
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Birthday information!"
                                                            message:@"Please provide us a valid birthday information, Reward point only valid if your profile 100 % completed"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            myBithday = @"00/00/0000";
        }
      NSDictionary *dictionary = @{@"login_key": myLogin,@"edit_id": [savedDict valueForKey:@"id"],@"edit_name": _name.text,@"edit_email_id": _email.text,@"edit_phone": _mobile.text,@"edit_place": _address.text,@"edit_bday": myBithday};
     internet *myclass = [[internet alloc]init];
     if ([myclass connectedToInternet]) {
        if ([self NSStringIsValidEmail:_email.text]) {
            NSString * stringMobi = _mobile.text;
            if ([stringMobi length] < 10  || [stringMobi length] > 10   ) {
                [HUD hideUIBlockingIndicator];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                message:@"Invalid Mobile Number"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                
            }else{
                NSString * stringPass = _address.text;
                if (![stringPass length]) {
                    [HUD hideUIBlockingIndicator];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                    message:@"Give your place details"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                    
                }else{
                    
                    dispatch_queue_t fetchQ = dispatch_queue_create("login", NULL);
                    dispatch_async(fetchQ, ^{                     
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
                        NSURL *url = [NSURL URLWithString:@"http://moglee.in/users.php"];
                        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
                        [request setHTTPMethod:@"POST"];
                        [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
                        [request setHTTPBody:data];
                        
                        // issue the request
                        
                        NSURLResponse *response = nil;
                        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                        if (error){
                            NSString *err = [[NSString alloc]initWithFormat:@"%@",error ];
                            [HUD hideUIBlockingIndicator];
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                            message:err
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                            [alert show];
                        }
                        
                        // examine the response
                        NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
                        NSString *outputY = @"Sucessfully Updated";
                        NSString *newOutputY = [NSString stringWithFormat:@"\"%@\"", outputY];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [HUD hideUIBlockingIndicator];
                            if ([responseString isEqualToString:newOutputY]) {
                                
                                [savedDict setValue: _name.text forKey:@"name"];
                                [savedDict setValue: _email.text forKey:@"email"];
                                [savedDict setValue: _mobile.text forKey:@"mobile"];
                                [savedDict setValue: _address.text forKey:@"address"];
                                 [savedDict setValue: _selectedDate.text forKey:@"bday"];
                                NSData *dataSave = [NSKeyedArchiver archivedDataWithRootObject:savedDict];
                                [[NSUserDefaults standardUserDefaults] setObject:dataSave forKey:@"myUser"];
                                [HUD hideUIBlockingIndicator];
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:responseString
                                                                                message:@""
                                                                               delegate:nil
                                                                      cancelButtonTitle:@"OK"
                                                                      otherButtonTitles:nil];
                                [alert show];
                            }else{
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
    }else{
        NSString *myLogin = [[NSString alloc]initWithFormat:@"%d",0];
        NSDictionary *dictionary = @{@"login_key": myLogin,@"edit_name": _name.text,@"edit_email_id": _email.text,@"edit_phone": _mobile.text,@"edit_place": _address.text};
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
                    NSString * stringPass = _address.text;
                    if (![stringPass length]) {
                        [HUD hideUIBlockingIndicator];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                        message:@"Give your place details"
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                        [alert show];
                        
                    }else{
                        [HUD showUIBlockingIndicatorWithText:@"Updating"];
                        dispatch_queue_t fetchQ = dispatch_queue_create("login", NULL);
                        dispatch_async(fetchQ, ^{
                            //  NSDictionary *dictionary = @{@"username": _name.text,@"email": _email.text,@"mobile": _mobile.text,@"pass": _address.text};
                            NSError *error = nil;
                            NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
                            if (error){
                                NSString *err = [[NSString alloc]initWithFormat:@"%@",error ];
                                [HUD hideUIBlockingIndicator];
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                                message:err
                                                                               delegate:nil
                                                                      cancelButtonTitle:@"OK"
                                                                      otherButtonTitles:nil];
                                [alert show];
                            }
                            
                            
                            NSURL *url = [NSURL URLWithString:@"http://moglee.in/users.php"];
                            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
                            [request setHTTPMethod:@"POST"];
                            [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
                            [request setHTTPBody:data];
                            
                            // issue the request
                            
                            NSURLResponse *response = nil;
                            NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                            if (error){
                                NSString *err = [[NSString alloc]initWithFormat:@"%@",error ];
                                [HUD hideUIBlockingIndicator];
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                                message:err
                                                                               delegate:nil
                                                                      cancelButtonTitle:@"OK"
                                                                      otherButtonTitles:nil];
                                [alert show];
                            }
                            
                            // examine the response
                            NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];                           
                            NSString *outputY = @"Sucessfully Updated";
                            NSString *newOutputY = [NSString stringWithFormat:@"\"%@\"", outputY];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [HUD hideUIBlockingIndicator];
                                if ([responseString isEqualToString:newOutputY]) {
                                    
                                        [savedDict setValue: _name.text forKey:@"name"];
                                        [savedDict setValue: _email.text forKey:@"email"];
                                        [savedDict setValue: _mobile.text forKey:@"mobile"];
                                        [savedDict setValue: _address.text forKey:@"address"];
                                        [savedDict setValue: _selectedDate.text forKey:@"bday"];
                                        NSData *dataSave = [NSKeyedArchiver archivedDataWithRootObject:savedDict];
                                        [[NSUserDefaults standardUserDefaults] setObject:dataSave forKey:@"myUser"];
                                      [HUD hideUIBlockingIndicator];
                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:responseString
                                                                                        message:@""
                                                                                       delegate:nil
                                                                              cancelButtonTitle:@"OK"
                                                                              otherButtonTitles:nil];
                                        [alert show];
                                    

                                }else{
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
}

- (IBAction)cancel:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
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

- (IBAction)LoadImage:(id)sender {
    
    
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate=self;
    [picker setSourceType:(UIImagePickerControllerSourceTypePhotoLibrary)];
    [self presentViewController:picker animated:YES completion:Nil];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSData *mydata = [[NSUserDefaults standardUserDefaults] objectForKey:@"myUser"];
    NSMutableDictionary *savedDict = [NSKeyedUnarchiver unarchiveObjectWithData:mydata];    
    [picker dismissViewControllerAnimated:NO completion:nil];
    UIImageView *newImage = [[UIImageView alloc] initWithImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
     _manualProfilePic.image = nil;
    UIImage *image = [MYUtil imageWithImage:newImage.image scaledToSize:CGSizeMake(90, 90)];
    _manualProfilePic.image = image;
    [savedDict setObject:image forKey:@"image"];
    NSData *dataSave = [NSKeyedArchiver archivedDataWithRootObject:savedDict];
    [[NSUserDefaults standardUserDefaults] setObject:dataSave forKey:@"myUser"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
- (IBAction)pickerAction:(id)sender {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    
    NSString *formatedDate = [dateFormatter stringFromDate:self.datePicker.date];
    
    self.selectedDate.text =formatedDate;
}

- (IBAction)apper:(id)sender {
     [_dateView setHidden:NO];
}
- (IBAction)exit:(id)sender {
     [_dateView setHidden:YES];
}

@end
