#import "RewardsViewController.h"

@interface RewardsViewController ()

@end

@implementation RewardsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
}
-(void)viewDidAppear:(BOOL)animated{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"myUser"];
    NSArray *savedArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSString *loginString = [savedArray valueForKey:@"rewards"];
    NSString *dailyReward = [savedArray valueForKey:@"dailyReward"];
        _loginPoint.text = loginString;
        _daily.text = dailyReward;
    
    int i = [loginString doubleValue] + [dailyReward doubleValue];
    NSString *myTotal = [[NSString alloc]initWithFormat:@"%d",i];
    _total.text = myTotal;    

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}
- (IBAction)referesh:(id)sender {
}
@end
