#import "UserProfileViewController.h"
#import <FacebookSDK/FacebookSDK.h>
@interface UserProfileViewController ()
@end
@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    NSData *mydata = [[NSUserDefaults standardUserDefaults] objectForKey:@"myUser"];
    NSMutableDictionary *savedDict = [NSKeyedUnarchiver unarchiveObjectWithData:mydata];
    _lblUsername.text = [savedDict valueForKey:@"name"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - FBHandler delegate functions


#pragma mark - Event Handlers

- (IBAction)invite:(id)sender {
  
}


@end
