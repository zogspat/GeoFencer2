//
//  ViewAllRegionsAsPins.h
//  Tsker
//
//  Created by Donal Hanna on 12/06/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "MyAnnotation.h"
// not sure why: replicating functionality in doBGVC:
//#import "MyCLController.h"

@interface ViewAllRegionsAsPins : ViewController <CLLocationManagerDelegate, MKMapViewDelegate>
{
    //http://stackoverflow.com/questions/6495419/mkannotation-simple-example. susing myannotation.h
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
}
@property (strong, nonatomic) IBOutlet MKMapView *mapOutlet;
// first coordinate to centre the map on:
@property CLLocationCoordinate2D mapCentre;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location placeName:(NSString *)placeName description:(NSString *)description;

@end
