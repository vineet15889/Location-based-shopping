#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
@interface ViewController : UIViewController <FBLoginViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *rotate;
@property (weak, nonatomic) IBOutlet UIButton *profile;
@property (readonly, copy) NSString *mySearch;
@property (weak, nonatomic) IBOutlet UIView *childview;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet FBLoginView *loginButton;
@end

