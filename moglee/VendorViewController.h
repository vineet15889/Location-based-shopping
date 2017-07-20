#import <UIKit/UIKit.h>
@interface VendorViewController : UIViewController
@property NSString * openning;
@property (strong, nonatomic)  NSDictionary *offers;
@property (strong, nonatomic)  NSArray *relatedOffers;
@property (weak, nonatomic) IBOutlet UILabel *venderName;

@property (weak, nonatomic) IBOutlet UILabel *openningTime;
@property (weak, nonatomic) IBOutlet UILabel *offerEnd;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UILabel *reting;
@property (weak, nonatomic) IBOutlet UILabel *off;
@property (weak, nonatomic) IBOutlet UILabel *sublocation;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewtest;
@property (weak, nonatomic) IBOutlet UIView *reletedViewOffer;
@property (weak, nonatomic) IBOutlet UIView *rorateView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *rotate;
@property (weak, nonatomic) IBOutlet UILabel *noRelatedOffer;
@end
