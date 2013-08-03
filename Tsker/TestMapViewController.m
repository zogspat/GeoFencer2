//
//  TestMapViewController.m
//  Tsker
//
//  Created by Donal Hanna on 16/06/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//

#import "TestMapViewController.h"

@interface TestMapViewController ()

@end

@implementation TestMapViewController
@synthesize pinLat;
@synthesize pinLong;
@synthesize wallCircle;
@synthesize geoFenceInstance;
@synthesize wallRadius;
@synthesize locationUpdateCount;
@synthesize currentLocationPinDropped;
@synthesize droppedAt;
@synthesize managedObjectContext;
// added this to get rid of the auto synth warning. does it break anyfink?
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
    managedObjectContext = [[DatabaseHelper sharedInstance] managedObjectContext];
    // delete any scratch data
    NSFetchRequest *allScratches = [[NSFetchRequest alloc] init];
    [allScratches setEntity:[NSEntityDescription entityForName:@"ScratchFence" inManagedObjectContext:managedObjectContext]];
    [allScratches setIncludesPropertyValues:NO];
    NSError *error = nil;
    NSArray *scratches = [managedObjectContext executeFetchRequest:allScratches error:&error];
    NSLog(@"scratch data has %i records", [scratches count]);
    for (NSManagedObject *oneScratch in scratches)
    {
        [managedObjectContext deleteObject:oneScratch];
    }
    
    geoFenceInstance = [[GeoWallData alloc] initWithWallData:[NSDate date] wallLat:0 wallLong:0 wallRadius:SMALL_RADIUS wallEmail:@"" wallIPAddress:@"" wallAction:@"" wallName:@""];
    currentLocationPinDropped = FALSE;
    locationUpdateCount = 0 ;
    wallRadius = SMALL_RADIUS;
    //wallCircle = [[MKCircle alloc] init];
    self.mapView.delegate = self;
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    // The three iterations is just a guess:
    if (locationUpdateCount < 3)
    {
//        MKCoordinateRegion mapRegion;
//        mapRegion.center = self.mapView.userLocation.coordinate;
//        mapRegion.span.latitudeDelta = 0.2;
//        mapRegion.span.longitudeDelta = 0.2;
//        
//        [self.mapView setRegion:mapRegion animated: YES];
        geoFenceInstance.wallLat = [NSNumber numberWithFloat: userLocation.coordinate.latitude];
        geoFenceInstance.wallLong = [NSNumber numberWithFloat:userLocation.coordinate.longitude];
        self.latLongLabel.text = [NSString stringWithFormat:@"Lat: %f, Long %f", [geoFenceInstance.wallLat floatValue], [geoFenceInstance.wallLong floatValue]];
        locationUpdateCount++;
        // this is just so the segment works without the user having dropped the pin:
        droppedAt = userLocation.coordinate;
        NSLog(@"locationUpdateCount: %i; Lat: %f", locationUpdateCount, userLocation.coordinate.latitude);
    }
    else
    {
        NSLog(@"Elsing: Lat is %f", [geoFenceInstance.wallLat floatValue]);
        // We only want to do this once, otherwise it will drop the pin again and again:
        if ((![geoFenceInstance.wallLat floatValue] == 0) && (currentLocationPinDropped == FALSE))
        {
            currentLocationPinDropped = TRUE;
            NSLog(@"~~~~~~~~~~~~~~~~~~~~8<");
            [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:FALSE];
            [self.mapView setShowsUserLocation:NO];
            coordinate= CLLocationCoordinate2DMake([geoFenceInstance.wallLat floatValue], [geoFenceInstance.wallLong floatValue]);
            MyAnnotation *myPin = [[MyAnnotation alloc] initWithCoordinate:coordinate];
            [self.mapView addAnnotation:myPin];
            // There is a duplicate. commenting out for now
            //wallCircle = [MKCircle circleWithCenterCoordinate:self.mapView.userLocation.coordinate radius:wallRadius];
            //[self.mapView addOverlay:wallCircle];
        }
    }
}

- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)annotationView
didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState
{
    // http://stackoverflow.com/questions/10733564/drag-an-annotation-pin-on-a-mapview
    NSLog(@"didChangeDragState");
    if (newState == MKAnnotationViewDragStateEnding)
    {
        droppedAt = annotationView.annotation.coordinate;
        NSLog(@"Pin dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);
        //NSString *pinPosn = [NSString stringWithFormat:@"%f,  %f", droppedAt.latitude, droppedAt.longitude];
        // This is the label at the top of the map:
        //self.showCords.text = pinPosn;
        pinLat = droppedAt.latitude;
        pinLong = droppedAt.longitude;
        // naughty - may not exist:        
        [self.mapView removeOverlay:wallCircle];
        
        //geoFenceInstance.wallLat = self.mapOutlet.userLocation.coordinate.latitude;
        //geoFenceInstance.wallLong = self.mapOutlet.userLocation.coordinate.longitude;
        NSLog(@"In didChangeDragState and setting %f for lat", self.mapView.userLocation.location.coordinate.latitude);
        // I've had a can of beer but I think this is wrong:
        //geoFenceInstance.wallLat = [NSNumber numberWithFloat:self.mapView.userLocation.coordinate.latitude];
        //geoFenceInstance.wallLong = [NSNumber numberWithFloat:self.mapView.userLocation.coordinate.longitude];
        geoFenceInstance.wallLat = [NSNumber numberWithFloat: droppedAt.latitude];
        geoFenceInstance.wallLong = [NSNumber numberWithFloat:droppedAt.longitude];
        geoFenceInstance.wallRadius = wallRadius;
        wallCircle = [MKCircle circleWithCenterCoordinate:droppedAt radius:wallRadius];
        [self.mapView addOverlay:wallCircle];
        self.latLongLabel.text = [NSString stringWithFormat:@"Lat: %f, Long %f", [geoFenceInstance.wallLat floatValue], [geoFenceInstance.wallLong floatValue]];
        // save
        
        // delete any previous instances of scratch data:
        NSFetchRequest *allScratches = [[NSFetchRequest alloc] init];
        [allScratches setEntity:[NSEntityDescription entityForName:@"ScratchFence" inManagedObjectContext:managedObjectContext]];
        [allScratches setIncludesPropertyValues:NO];
        NSError *error = nil;
        NSArray *scratches = [managedObjectContext executeFetchRequest:allScratches error:&error];
        NSLog(@"scratch data has %i records", [scratches count]);
        for (NSManagedObject *oneScratch in scratches)
        {
            [managedObjectContext deleteObject:oneScratch];
        }
        // then add a new one:
        ScratchFence *inserterScratchBoy = [NSEntityDescription insertNewObjectForEntityForName:@"ScratchFence" inManagedObjectContext:managedObjectContext];
        [inserterScratchBoy setDate:[NSDate date]];
        NSLog(@"=====> Setting Latitude: %f", [geoFenceInstance.wallLat floatValue]);
        //[inserterScratchBoy setLatitude:scratchDataForCurrentFence.latitude];
        //NSNumber *dontMeanIt = [[NSNumber alloc] initWithFloat:4];
        [inserterScratchBoy setLatitude:geoFenceInstance.wallLat];
        [inserterScratchBoy setLongitude:geoFenceInstance.wallLong];
        NSNumber *tmpRad = [NSNumber  numberWithInt:geoFenceInstance.wallRadius];
        [inserterScratchBoy setRadius:tmpRad];
        NSLog(@"Just saved scratch geofence data with radius %i", geoFenceInstance.wallRadius);
        
        
    }
}


- (MKAnnotationView *) mapView: (MKMapView *) mapView viewForAnnotation: (id<MKAnnotation>) annotation {
    MKPinAnnotationView *pin = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier: @"wallPin"];
    if (pin == nil) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"myPin"];
        pinLat = self.mapView.userLocation.coordinate.latitude;
        pinLong = self.mapView.userLocation.coordinate.longitude;
        //self.showCords.text  = [NSString stringWithFormat:@"%f,  %f", pinLat, pinLong];
        NSArray *pointsArray = [mapView overlays];
        [self.mapView removeOverlays:pointsArray];
        [self.mapView removeOverlay:wallCircle];
        wallCircle = [MKCircle circleWithCenterCoordinate:self.mapView.userLocation.coordinate radius:wallRadius];
        // had a break and coming back to this: not sure if I'm actually using geoFence instance any more
        //geoFenceInstance.wallLat = self.mapOutlet.userLocation.coordinate.latitude;
        //geoFenceInstance.wallLong = self.mapOutlet.userLocation.coordinate.longitude;
        NSLog(@"In viewForAnnotation and setting %f for lat", self.mapView.userLocation.location.coordinate.latitude);
        geoFenceInstance.wallLat = [NSNumber numberWithFloat:self.mapView.userLocation.coordinate.latitude];
        geoFenceInstance.wallLong = [NSNumber numberWithFloat:self.mapView.userLocation.coordinate.longitude];
        self.latLongLabel.text = [NSString stringWithFormat:@"Lat: %f, Long %f", [geoFenceInstance.wallLat floatValue], [geoFenceInstance.wallLong floatValue]];

        geoFenceInstance.wallRadius = wallRadius;
        [self.mapView addOverlay:wallCircle];
        // delete any previous instances of scratch data:
        NSFetchRequest *allScratches = [[NSFetchRequest alloc] init];
        [allScratches setEntity:[NSEntityDescription entityForName:@"ScratchFence" inManagedObjectContext:managedObjectContext]];
        [allScratches setIncludesPropertyValues:NO];
        NSError *error = nil;
        NSArray *scratches = [managedObjectContext executeFetchRequest:allScratches error:&error];
        NSLog(@"scratch data has %i records", [scratches count]);
        for (NSManagedObject *oneScratch in scratches)
        {
            [managedObjectContext deleteObject:oneScratch];
        }
        // then add a new one:
        ScratchFence *inserterScratchBoy = [NSEntityDescription insertNewObjectForEntityForName:@"ScratchFence" inManagedObjectContext:managedObjectContext];
        [inserterScratchBoy setDate:[NSDate date]];
        NSLog(@"=====> Setting Latitude: %f", [geoFenceInstance.wallLat floatValue]);
        //[inserterScratchBoy setLatitude:scratchDataForCurrentFence.latitude];
        //NSNumber *dontMeanIt = [[NSNumber alloc] initWithFloat:4];
        [inserterScratchBoy setLatitude:geoFenceInstance.wallLat];
        [inserterScratchBoy setLongitude:geoFenceInstance.wallLong];
        NSNumber *tmpRad = [NSNumber  numberWithInt:geoFenceInstance.wallRadius];
        [inserterScratchBoy setRadius:tmpRad];
        
        
        
    } else {
        pin.annotation = annotation;
    }
    pin.animatesDrop = NO;
    pin.draggable = YES;
    
    return pin;
}

- (MKOverlayView *) mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay]
    ;
    circleView.strokeColor = [UIColor redColor];
    circleView.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.4];
    return circleView;
}

- (IBAction)segmentPressed:(id)sender
{
    // Because the save is done in viewForAnnotation, setting the radius after
    // dropping the pin won't be reflected in the saved data.
    if (segment.selectedSegmentIndex == 0)
    {
        NSLog(@"segment: 0: %i", SMALL_RADIUS);
        wallRadius = SMALL_RADIUS;
        geoFenceInstance.wallRadius = SMALL_RADIUS;
        [self.mapView removeOverlay:wallCircle];
        wallCircle = [MKCircle circleWithCenterCoordinate:droppedAt radius:wallRadius];
        [self.mapView addOverlay:wallCircle];
    }
    else if (segment.selectedSegmentIndex == 1)
    {
        NSLog(@"segment 1: %i", MEDIUM_RADIUS);
        wallRadius = MEDIUM_RADIUS;
        geoFenceInstance.wallRadius = MEDIUM_RADIUS;
        //scratchDataForCurrentFence.radius = [NSNumber numberWithInt:500];
        [self.mapView removeOverlay:wallCircle];
        wallCircle = [MKCircle circleWithCenterCoordinate:droppedAt radius:wallRadius];
        [self.mapView addOverlay:wallCircle];
    }
    else if (segment.selectedSegmentIndex ==2)
    {
        NSLog(@"segment 2: %i", LARGE_RADIUS);
        wallRadius = LARGE_RADIUS;
        geoFenceInstance.wallRadius = LARGE_RADIUS;
        //scratchDataForCurrentFence.radius = [NSNumber numberWithInt:1000];
        [self.mapView removeOverlay:wallCircle];
        wallCircle = [MKCircle circleWithCenterCoordinate:droppedAt radius:wallRadius];
        [self.mapView addOverlay:wallCircle];
    }

}
@end
