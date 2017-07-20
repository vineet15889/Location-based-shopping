#import "MyTabController.h"

@interface MyTabController ()

@end

@implementation MyTabController
@synthesize myCategory;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    // saving an NSString
    [prefs setObject:myCategory forKey:@"currentCategory"];
    [prefs synchronize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
