#import "Loading.h"

@implementation Loading

#define LABEL_WIDTH 80
#define LABEL_HEIGHT 20

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((self.bounds.size.width-LABEL_WIDTH)/2+20,
                                                                   (self.bounds.size.height-LABEL_HEIGHT)/2,
                                                                   LABEL_WIDTH,
                                                                   LABEL_HEIGHT)];
        label.text = @"Loading…";
        label.center = self.center;
        UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        spinner.frame = CGRectMake(label.frame.origin.x - LABEL_HEIGHT - 5,
                                   label.frame.origin.y,
                                   LABEL_HEIGHT,
                                   LABEL_HEIGHT);
        [spinner startAnimating];
        [self addSubview: spinner];
        [self addSubview: label];
    }
    return self;
}

@end
