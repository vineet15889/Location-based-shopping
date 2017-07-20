#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <UIKit/UIView.h>
#import <CoreLocation/CoreLocation.h>
@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate,NSURLConnectionDataDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *map;
@property NSString * myString;
@property double lat;
@property double lon;
@property NSString* cat;
@property (nonatomic, strong) NSMutableArray *offers;
@property (nonatomic, retain) IBOutlet CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet UILabel *location;
@property (strong, nonatomic) IBOutlet UILabel *lables;
@property NSString *shopName;
@property (nonatomic, strong) NSMutableDictionary *anno;
@property MKCircleView *circleView;
@property MKCircle *circle;
@property NSString *launch;
@end
