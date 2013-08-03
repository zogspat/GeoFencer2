//
//  ViewAllRegionsAsPins.m
//  Tsker
//
//  Created by Donal Hanna on 12/06/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//

// Design decision: going to take the region data from 

#import "ViewAllRegionsAsPins.h"

@interface ViewAllRegionsAsPins ()

@end

@implementation ViewAllRegionsAsPins
@synthesize mapCentre;
@synthesize mapOutlet;
@synthesize coordinate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.mapOutlet.delegate = self;
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];

    NSArray *regionArray = [[locationManager monitoredRegions] allObjects];
    NSLog(@"~~~~~~~~>  there are %i regions currently being monitored", [regionArray count]);
    
    if ([regionArray count] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh-oh!"
                                                        message:@"No regions currently monitored"
                                                       delegate: nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        CLRegion *firstRegion = regionArray[0];
        mapCentre = firstRegion.center;
        for (CLRegion *eachRegion in regionArray)
        {
            
            NSLog(@"I see a name called %@", eachRegion.identifier);
            CLLocationCoordinate2D myCord = eachRegion.center;
            MyAnnotation *tmpPin = [[MyAnnotation alloc] initWithCoordinate:myCord];
            tmpPin.title = eachRegion.identifier;
            float tmpLat = myCord.latitude;
            float tmpLong = myCord.longitude;
            NSString *subTitle = [[NSString alloc] initWithFormat:@"Lat: %f, Long: %f", tmpLat, tmpLong];
            tmpPin.subtitle = subTitle;
    //        NSString *latString = [ tmpLat];
    //        NSString *subTitle = [tmpLat stringByAppendingString:@" Lat, "];
    //        subTitle = [subTitle stringByAppendingString: [geoFenceInstance.longitude stringValue]];
    //        subTitle = [subTitle stringByAppendingString:@ " Long"];
    //        
            [mapOutlet addAnnotation:tmpPin];
            MKCircle *tmpCircle = [MKCircle circleWithCenterCoordinate:myCord radius:eachRegion.radius];
            [self.mapOutlet addOverlay:tmpCircle];
        }
    }
    //[super viewDidLoad];
	// Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MKOverlayView *) mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay]
    ;
    circleView.strokeColor = [UIColor redColor];
    circleView.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.4];
    return circleView;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    NSLog(@"------------->>> didUpdateUserLocation being called");
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(mapCentre, 800, 800);
    [self.mapOutlet setRegion:[self.mapOutlet regionThatFits:region] animated:YES];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"------------->>> didUpdateToLocation being called");

}


@end
