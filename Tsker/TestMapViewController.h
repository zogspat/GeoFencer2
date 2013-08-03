//
//  TestMapViewController.h
//  Tsker
//
//  Created by Donal Hanna on 16/06/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "GeoWallData.h"
#import "MyAnnotation.h"
#import "DatabaseHelper.h"
#import "ScratchFence.h"
#import "constants.h"

@interface TestMapViewController : ViewController <MKMapViewDelegate, MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
    NSString * title;
    NSString * subtitle;
    IBOutlet UISegmentedControl *segment;
}

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

- (IBAction)segmentPressed:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *latLongLabel;

@property float pinLat;
@property float pinLong;
@property MKCircle *wallCircle;
@property GeoWallData *geoFenceInstance;
@property int wallRadius;
@property int locationUpdateCount;
@property bool currentLocationPinDropped;
@property CLLocationCoordinate2D droppedAt;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
