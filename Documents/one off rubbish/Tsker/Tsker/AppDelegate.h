//
//  AppDelegate.h
//  Tsker
//
//  Created by Donal Hanna on 23/05/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//

// got a problem with the first view controller not being the one that loads the core data
// this looks promising:
// http://stackoverflow.com/questions/6652432/where-to-implement-core-data

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MyCLController.h"
//#import "WildCardGestureRecognizer.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

{
    bool bigChange;
    CLLocationManager *locationManager ;
    UILocalNotification *localNotification;
    CLRegion *dNaHouse;
    CLRegion *trainRegion;
    CLRegion *atHome;
    CLRegion *kingsCross;
    UIBackgroundTaskIdentifier bgTask;
}

@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) UIBackgroundTaskIdentifier bgTask;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) dispatch_block_t expirationHandler;
@property (assign, nonatomic) BOOL jobExpired;
@property int persistenceCheck;


@end
