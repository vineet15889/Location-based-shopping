#import "MyCustomAnnotation.h"
@implementation MyCustomAnnotation
-(id)initWithTitle:(NSString *)newTitle Location:(CLLocationCoordinate2D)coordinate{
    self = [super init];
    if (self) {
        _title = newTitle;
        _coordinate = coordinate;
}
    return self;
}
-(MKAnnotationView *)annotationView{
    MKAnnotationView *annotationView = [[MKAnnotationView alloc]initWithAnnotation:self reuseIdentifier:@"MyCustomAnnotation"];
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;    
    annotationView.image = [UIImage imageNamed:@"blackG.png"];
    UIButton * mybutton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [mybutton setBackgroundImage:[UIImage imageNamed:@"forword"] forState:normal];
    annotationView.rightCalloutAccessoryView = mybutton;
    UIImageView *lsfIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shop"]];
    annotationView.leftCalloutAccessoryView = lsfIconView;
    //annotationView.calloutOffset =[[UIButton alloc]init]
    return annotationView; 
     }
@end
