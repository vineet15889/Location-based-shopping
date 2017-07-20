//
//  AppDelegate.h
//  moglee
//
//  Created by Moglee on 31/03/15.
//  Copyright (c) 2015 Moglee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UIWindow *window;

@end

