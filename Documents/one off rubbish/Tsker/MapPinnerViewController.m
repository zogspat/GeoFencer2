//
//  MapPinnerViewController.m
//  Tsker
//
//  Created by Donal Hanna on 26/05/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//

// rather than messing around with protocols to hold state between the map view and the save action in the
// earlier screen I am going to use the ScratchFence Entity. It should always have between zero and one
// 'records' [whatever they are called in core data speak]. So the mechanism will be to check how many items
// it holds in viewWillAppear, and if there is a record in there, delete it. Then correspondly, on the save
// button action in the calling view, if ScratchFence is empty, provide a message that the region data has to be
// set.

// had a break and coming back to this: not sure if I'm actually using geoFence instance any more. Gone back to it
// after a little bit of confusion.
// Should probably check for scratch data in view will appear and go to the point defined by lat and long to initialise
// the map. Maybe....

#import "MapPinnerViewController.h"

@interface MapPinnerViewController ()

@end

@implementation MapPinnerViewController
@synthesize currentLat;
@synthesize currentLong;
@synthesize initialLocation;
@synthesize foundMyself;
@synthesize tapInterceptor;
// looks like I'm not using wallPin:
@synthesize wallPin;
@synthesize pinLat;
@synthesize pinLong;
@synthesize wallRadius;
@synthesize wallCircle;
@synthesize lastCordsOfCircle;
@synthesize geoFenceInstance;
//@synthesize  scratchDataForCurrentFence;
@synthesize managedObjectContext;
@synthesize scratchRadius;

#define METERS_PER_MILE 1609.344

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
    locationManager = [[CLLocationManager alloc] init];
//    locationManager.delegate = self;
//    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
//    locationManager.distanceFilter = 10;
//    [locationManager startUpdatingLocation];
    managedObjectContext = [[DatabaseHelper sharedInstance] managedObjectContext];
    // xxx note to self: won't be hard-wiring in the email and IP.
    geoFenceInstance = [[GeoWallData alloc] initWithWallData:[NSDate date] wallLat:0 wallLong:0 wallRadius:150 wallEmail:@"donal.hanna@the-plot.com" wallIPAddress:@"192.168.1.1" wallAction:@"email" wallName:@""];
                        
    foundMyself = FALSE;
    pinLat = 0;
    pinLong = 0;
    // for now:
    wallRadius = 150;
    //scratchDataForCurrentFence.radius = [NSNumber numberWithInt: wallRadius];
    geoFenceInstance.wallRadius = wallRadius;
    managedObjectContext = [[DatabaseHelper sharedInstance] managedObjectContext];
    //wallCircle = [[MKCircle alloc]init];
    tapInterceptor = [[WildCardGestureRecognizer alloc] init];
    // check the scratch data. If there is anything in there, delete it:
    //NSArray *result = [[NSArray alloc] init];
    //result = [self fetchArrayFromDBWithEntity:@"ScratchFence" forKey:@"radius" withPredicate:nil];
    //int numRecs = [result count];
    //NSLog(@"scratch data has %i records", numRecs);
    //if (numRecs > 0)
    //{
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
    
    self.mapOutlet.delegate = self;
    [self.mapOutlet addGestureRecognizer:tapInterceptor];
    [self.mapOutlet.userLocation addObserver:self
                                  forKeyPath:@"location"
                                     options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                                     context:NULL];
    NSString *jim = [[NSString alloc] init];
    jim =@ "boo";
    [NSThread detachNewThreadSelector:@selector(areWeThereYet:) toTarget:self withObject:jim];

}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([self.mapOutlet showsUserLocation])
    {
        MKUserLocation *userLocation = self.mapOutlet.userLocation;
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance (userLocation.location.coordinate, 500,500);
        [self.mapOutlet setRegion:region animated:YES];
        foundMyself = TRUE;
        NSLog(@"In observeValueForKeyPath and setting %f for lat", userLocation.location.coordinate.latitude);
        //scratchDataForCurrentFence.latitude = [NSNumber numberWithInt:userLocation.location.coordinate.latitude];
        //scratchDataForCurrentFence.longitude = [NSNumber numberWithInt:userLocation.location.coordinate.longitude];
        geoFenceInstance.wallLat = [NSNumber numberWithFloat:userLocation.location.coordinate.latitude];
        geoFenceInstance.wallLong = [NSNumber numberWithFloat:userLocation.location.coordinate.longitude];
        
    }
}

- (void) viewDidDisappear:(BOOL)animated
{
    //[self.mapOutlet.userLocation removeObserver:self forKeyPath:@"location"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *) areWeThereYet: (NSString *)jim
{
    NSLog(@"areWeThereYet");
    
    while (!tapInterceptor.baZinga)
    {
        //NSLog(@"Waiting...");
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.5]] ;
        
    }
    [self.mapOutlet.userLocation removeObserver:self forKeyPath:@"location"];
    
    [self.mapOutlet setUserTrackingMode:MKUserTrackingModeNone animated:NO];
    //NSLog(@"locationManager stopUpdatingLocation");
    // this works but zaps the pin:
    [self.mapOutlet setShowsUserLocation:NO];

    CLLocationCoordinate2D touchedSoDropHere = CLLocationCoordinate2DMake([geoFenceInstance.wallLat floatValue], [geoFenceInstance.wallLong floatValue]);
    MyAnnotation *desperate = [[MyAnnotation alloc] initWithCoordinate:touchedSoDropHere];
//
//    
//    MyAnnotation *desperate = [[MyAnnotation alloc] initWithCoordinate:touchedSoDropHere];
//    
    [self.mapOutlet addAnnotation:desperate];
    //this doesn't seem to work
    //[self.mapOutlet setUserTrackingMode:MKUserTrackingModeNone];
    // this doesn't work 
    //[locationManager stopUpdatingLocation];
    // so trying:
    //[locationManager stopMonitoringSignificantLocationChanges];
    //locationManager.delegate = nil;
    //[self.mapOutlet removeOverlay:wallCircle];
    NSLog(@"----> Bazinga");
    jim = @"jam";

    return jim;
}



- (IBAction)dropPin:(id)sender
{
    // This will become save
    NSLog(@"Set pressed");
    if (!pinLat == 0)
    {
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
        
    } else
    {
        NSLog(@"Pop up needed to say the location hasn't set");
    }
}

- (MKAnnotationView *) mapView: (MKMapView *) mapView viewForAnnotation: (id<MKAnnotation>) annotation {
    MKPinAnnotationView *pin = (MKPinAnnotationView *) [self.mapOutlet dequeueReusableAnnotationViewWithIdentifier: @"wallPin"];
    if (pin == nil) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"myPin"];
        pinLat = self.mapOutlet.userLocation.coordinate.latitude;
        pinLong = self.mapOutlet.userLocation.coordinate.longitude;
        self.showCords.text  = [NSString stringWithFormat:@"%f,  %f", pinLat, pinLong];
        [self.mapOutlet removeOverlay:wallCircle];
        wallCircle = [MKCircle circleWithCenterCoordinate:self.mapOutlet.userLocation.coordinate radius:wallRadius];
        // had a break and coming back to this: not sure if I'm actually using geoFence instance any more
        //geoFenceInstance.wallLat = self.mapOutlet.userLocation.coordinate.latitude;
        //geoFenceInstance.wallLong = self.mapOutlet.userLocation.coordinate.longitude;
        NSLog(@"In viewForAnnotation and setting %f for lat", self.mapOutlet.userLocation.location.coordinate.latitude);
        geoFenceInstance.wallLat = [NSNumber numberWithFloat:self.mapOutlet.userLocation.coordinate.latitude];
        geoFenceInstance.wallLong = [NSNumber numberWithFloat:self.mapOutlet.userLocation.coordinate.longitude];
        geoFenceInstance.wallRadius = wallRadius;
        [self.mapOutlet addOverlay:wallCircle];
    } else {
        pin.annotation = annotation;
    }
    pin.animatesDrop = NO;
    pin.draggable = YES;
    
    return pin;
}

- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)annotationView
didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState
{
    if (newState == MKAnnotationViewDragStateEnding)
    {
        CLLocationCoordinate2D droppedAt = annotationView.annotation.coordinate;
        NSLog(@"Pin dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);
        NSString *pinPosn = [NSString stringWithFormat:@"%f,  %f", droppedAt.latitude, droppedAt.longitude];
        self.showCords.text = pinPosn;
        pinLat = droppedAt.latitude;
        pinLong = droppedAt.longitude;
        // naughty - may not exist:
        [self.mapOutlet removeOverlay:wallCircle];
        //geoFenceInstance.wallLat = self.mapOutlet.userLocation.coordinate.latitude;
        //geoFenceInstance.wallLong = self.mapOutlet.userLocation.coordinate.longitude;
        NSLog(@"In didChangeDragState and setting %f for lat", self.mapOutlet.userLocation.location.coordinate.latitude);
        geoFenceInstance.wallLat = [NSNumber numberWithFloat:self.mapOutlet.userLocation.coordinate.latitude];
        geoFenceInstance.wallLong = [NSNumber numberWithFloat:self.mapOutlet.userLocation.coordinate.longitude];
        geoFenceInstance.wallRadius = wallRadius;
        wallCircle = [MKCircle circleWithCenterCoordinate:self.mapOutlet.userLocation.coordinate radius:wallRadius];
        [self.mapOutlet addOverlay:wallCircle];
    }
}

- (MKOverlayView *) mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay]
    ;
    circleView.strokeColor = [UIColor redColor];
    circleView.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.4];
    return circleView;
}


- (IBAction)segmentChanged:(id)sender
{
    if (segment.selectedSegmentIndex == 0)
    {
        NSLog(@"0");
        wallRadius = 150;
        geoFenceInstance.wallRadius = 150;
        [self.mapOutlet removeOverlay:wallCircle];
        wallCircle = [MKCircle circleWithCenterCoordinate:self.mapOutlet.userLocation.coordinate radius:wallRadius];
        [self.mapOutlet addOverlay:wallCircle];
    }
    else if (segment.selectedSegmentIndex == 1)
    {
        NSLog(@"1");
        wallRadius = 500;
        geoFenceInstance.wallRadius = 500;
        //scratchDataForCurrentFence.radius = [NSNumber numberWithInt:500];
        [self.mapOutlet removeOverlay:wallCircle];
        wallCircle = [MKCircle circleWithCenterCoordinate:self.mapOutlet.userLocation.coordinate radius:wallRadius];
        [self.mapOutlet addOverlay:wallCircle];
    }
    else if (segment.selectedSegmentIndex ==2)
    {
        NSLog(@"2");
        wallRadius = 1000;
        geoFenceInstance.wallRadius = 1000;
        //scratchDataForCurrentFence.radius = [NSNumber numberWithInt:1000];
        [self.mapOutlet removeOverlay:wallCircle];
        wallCircle = [MKCircle circleWithCenterCoordinate:self.mapOutlet.userLocation.coordinate radius:wallRadius];
        [self.mapOutlet addOverlay:wallCircle];
    }
}

- (NSMutableArray*)fetchArrayFromDBWithEntity:(NSString*)entityName forKey:(NSString*)keyName withPredicate:(NSPredicate*)predicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:keyName ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    if (predicate != nil)
        [request setPredicate:predicate];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    if (mutableFetchResults == nil) {
        NSLog(@"%@", error);
    }
    return mutableFetchResults;
}

@end
