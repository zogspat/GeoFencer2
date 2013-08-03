//
//  GoogleSearchHits.m
//  Tsker
//
//  Created by Donal Hanna on 28/07/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//

#import "GoogleSearchHits.h"

@interface GoogleSearchHits ()

@end

@implementation GoogleSearchHits
@synthesize coordinate;
@synthesize title;
@synthesize allGoogHits;

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
    //_mapView.delegate = self;
    // Don't forget: http://stackoverflow.com/questions/3821515/viewforannotation-is-not-being-called
	NSManagedObjectContext *managedObjectContext = [[DatabaseHelper sharedInstance] managedObjectContext];
    allGoogHits = [[NSArray alloc] init];
    NSFetchRequest *googFetch = [[NSFetchRequest alloc] init];
    [googFetch setEntity:[NSEntityDescription entityForName:@"GooglePlaceResults" inManagedObjectContext:managedObjectContext]];
    
    [googFetch setIncludesPropertyValues:NO];
    NSError *error = nil;
    allGoogHits = [managedObjectContext executeFetchRequest:googFetch error:&error];
    NSLog(@"google data has %i records", [allGoogHits count]);
    for (GooglePlaceResults *oneGoogHit in allGoogHits)
    {
        float lat = [oneGoogHit.locationLat floatValue];
        float lng = [oneGoogHit.locationLong floatValue];
        CLLocationCoordinate2D locationCord = CLLocationCoordinate2DMake(lat, lng);
        MyAnnotation *googPin = [[MyAnnotation alloc] initWithCoordinate:locationCord];
        googPin.title = oneGoogHit.locationName;
        NSLog(@"location is called %@", googPin.title);
        NSDate *pinDate = oneGoogHit.locationDate;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = @"dd/MM/yy HH:mm:ss";
        NSString *dateString = [dateFormatter stringFromDate: pinDate];
        googPin.subtitle = dateString;
        [_mapView addAnnotation:googPin];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// http://stackoverflow.com/questions/13794895/how-do-i-change-the-pin-color-of-an-annotation-in-map-kit-view
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    NSLog(@"viewForAnnotation");
    static NSString *identifier = @"MyLocation";
    if ([annotation isKindOfClass:[MyAnnotation class]])
    {
        NSLog(@"iffing");
        MKAnnotationView *annotationView = (MKAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil)
        {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            //annotationView.centerOffset = CGPointMake(-10, 0);
            //([myString hasPrefix:@"http"])
            annotationView.image = [UIImage imageNamed:@"greenSmall.png"];
            

            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
        else
        {
            annotationView.annotation = annotation;
        }
        return annotationView;
    }
    
    return nil;
}


@end
