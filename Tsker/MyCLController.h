//
//  MyCLController.h
//  Tsker
//
//  Created by Donal Hanna on 25/05/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface MyCLController : NSObject <CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
}

@property (nonatomic, retain) CLLocationManager *locationManager;

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;


@end
