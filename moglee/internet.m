#import "internet.h"

@implementation internet

- (BOOL)connectedToInternet
{
    
    NSURL *url=[NSURL URLWithString:@"http://www.moglee.in"];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"HEAD"];
    NSHTTPURLResponse *response;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: NULL];
    
    return ([response statusCode]==200)?YES:NO;
}

@end
