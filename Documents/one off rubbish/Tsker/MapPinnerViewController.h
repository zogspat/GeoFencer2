//
//  MapPinnerViewController.h
//  Tsker
//
//  Created by Donal Hanna on 26/05/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "WildCardGestureRecognizer.h"
#import "MyAnnotation.h"
#import "GeoWallData.h"
#import "ScratchFence.h"
#import "DatabaseHelper.h"


@interface MapPinnerViewController : ViewController <CLLocationManagerDelegate, MKMapViewDelegate>
{
    CLLocationManager *locationManager;
    // The trick to the segmented control: 1. Put the IBOutlet ref in the interface by hand [not from the storyboard.
    // 2. connect it back to the control by hand. 3. Action added as normal from SB. [Did this by hand]
    IBOutlet UISegmentedControl *segment;
}


@property (strong, nonatomic) IBOutlet MKMapView *mapOutlet;

- (IBAction)dropPin:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *showCords;

@property (nonatomic, retain) CLLocation* initialLocation;

- (IBAction)segmentChanged:(id)sender;


@property float currentLat;
@property float currentLong;
@property bool foundMyself;
@property  WildCardGestureRecognizer *tapInterceptor;
@property MyAnnotation *wallPin;
@property float pinLat;
@property float pinLong;
@property MKCircle *wallCircle;
@property int wallRadius;
@property CLLocationCoordinate2D lastCordsOfCircle;

@property GeoWallData *geoFenceInstance;
//@property ScratchFence *scratchDataForCurrentFence;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

// need a property for this. Kind of a key field into the record where we set the temp data
@property int scratchRadius;



@end
