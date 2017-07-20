
#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@protocol FBDelegate

@required

-(void) OnFBSuccess;
-(void) OnFBFailed : (NSError *)error;

@end

@interface FBHandler : NSObject
{
    NSInvocation *_callback;
}

@property (nonatomic, weak) id fbDelegate;

-(void)inviteFriends;

@end
