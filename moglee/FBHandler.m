#import "FBHandler.h"
@implementation FBHandler
@synthesize fbDelegate;

-(void)inviteFriends
{
    if ([[FBSession activeSession] isOpen])
    {
        NSMutableDictionary* params =  [NSMutableDictionary dictionaryWithObjectsAndKeys:nil];
        [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                      message:[self getInviteFriendMessage]
                                                        title:nil
                                                   parameters:params
                                                      handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error)
         {
             if (error)
             {
                 [self requestFailedWithError:error];
             }
             else
             {
                 if (result == FBWebDialogResultDialogNotCompleted)
                 {
                     [self requestFailedWithError:nil];
                 }
                 else if([[resultURL description] hasPrefix:@"fbconnect://success?request="])
                 {
                     // Facebook returns FBWebDialogResultDialogCompleted even user
                     // presses "Cancel" button, so we differentiate it on the basis of
                     // url value, since it returns "Request" when we ACTUALLY
                     // completes Dialog
                     [self requestSucceeded];
                 }
                 else
                 {
                     // User Cancelled the dialog
                     [self requestFailedWithError:nil];
                 }
             }
         }
         ];
        
    }
    else
    {
        /*
         * open a new session with publish permission
         */
        [FBSession openActiveSessionWithPublishPermissions:[NSArray arrayWithObject:@"publish_stream"]
                                           defaultAudience:FBSessionDefaultAudienceFriends
                                              allowLoginUI:YES
                                         completionHandler:^(FBSession *session, FBSessionState status, NSError *error)
         {
             if (!error && status == FBSessionStateOpen)
             {
                 NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:nil];
                 [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                               message:[self getInviteFriendMessage]
                                                                 title:nil
                                                            parameters:params
                                                               handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error)
                  {
                      if (error)
                      {
                          [self requestFailedWithError:error];
                      }
                      else
                      {
                          if (result == FBWebDialogResultDialogNotCompleted)
                          {
                              [self requestFailedWithError:nil];
                          }
                          else if([[resultURL description] hasPrefix:@"fbconnect://success?request="])
                          {
                              // Facebook returns FBWebDialogResultDialogCompleted even user
                              // presses "Cancel" button, so we differentiate it on the basis of
                              // url value, since it returns "Request" when we ACTUALLY
                              // completes Dialog
                              [self requestSucceeded];
                          }
                          else
                          {
                              // User Cancelled the dialog
                              [self requestFailedWithError:nil];
                          }
                          
                      }
                  }];
             }
             else
             {
                 [self requestFailedWithError:error];
             }
         }];
    }
    
}

- (void)requestSucceeded
{
    NSLog(@"requestSucceeded");
    id owner = [fbDelegate class];
    SEL selector = NSSelectorFromString(@"OnFBSuccess");
    NSMethodSignature *sig = [owner instanceMethodSignatureForSelector:selector];
    _callback = [NSInvocation invocationWithMethodSignature:sig];
    [_callback setTarget:owner];
    [_callback setSelector:selector];
    
#if !__has_feature(objc_arc)
    [_callback retain];
#endif
    
    [_callback invokeWithTarget:fbDelegate];
}

- (void)requestFailedWithError:(NSError *)error
{
    NSLog(@"requestFailed");
    id owner = [fbDelegate class];
    SEL selector = NSSelectorFromString(@"OnFBFailed:");
    NSMethodSignature *sig = [owner instanceMethodSignatureForSelector:selector];
    _callback = [NSInvocation invocationWithMethodSignature:sig];
    [_callback setTarget:owner];
    [_callback setSelector:selector];
    [_callback setArgument:&error atIndex:2];
    
#if !__has_feature(objc_arc)
    [_callback retain];
#endif
    
    [_callback invokeWithTarget:fbDelegate];
}

-(NSString *)getInviteFriendMessage
{
    return @"I found this app amazing and would like you to join as well.";
}

@end