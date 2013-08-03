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
#import "DatabaseHelper.h"
#import "SignificantChange.h"
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
- (IBAction)showAllChangeEvents:(id)sender;
- (IBAction)daySubtract:(id)sender;

- (IBAction)dayAdvance:(id)sender;
- (IBAction)todaysEvents:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *regionCountLabel;

@property (strong, nonatomic) IBOutlet UILabel *sigChangeCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *enteredRegionCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *exitedRegionLabelCount;



// first coordinate to centre the map on:
@property CLLocationCoordinate2D mapCentre;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSArray *allSigChangeDataArray;
@property (nonatomic, retain) NSDate *todaysDate;
@property int dayAdvanceCount;
@property (nonatomic, retain) NSMutableArray *allCurrentAnnotations;

@property int activeRegionCount;
@property int signifChangeCount;
@property int enterRegionCount;
@property int exitRegionCount;

//- (id)initWithCoordinates:(CLLocationCoordinate2D)location placeName:(NSString *)placeName description:(NSString *)description;

@end
