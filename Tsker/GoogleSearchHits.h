//
//  GoogleSearchHits.h
//  Tsker
//
//  Created by Donal Hanna on 28/07/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "GooglePlaceResults.h"
#import "DatabaseHelper.h"
#import "MyAnnotation.h"
//<CLLocationManagerDelegate, MKMapViewDelegate>
@interface GoogleSearchHits : UIViewController <MKMapViewDelegate, MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
    NSString * title;
}

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSArray *allGoogHits;

//- (id)initWithCoordinates:(CLLocationCoordinate2D)location placeName:(NSString *)placeName description:(NSString *)description;

@end
