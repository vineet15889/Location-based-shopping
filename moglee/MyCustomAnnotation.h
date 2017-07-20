#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface MyCustomAnnotation : NSObject <MKAnnotation>
@property int tag;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic)NSString *title;
@property (copy, nonatomic)NSString *subtitle;
-(id)initWithTitle:(NSString*)newTitle Location:(CLLocationCoordinate2D)coordinate;
-(MKAnnotationView*)annotationView;
@end
