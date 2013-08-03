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
@synthesize managedObjectContext;
@synthesize allSigChangeDataArray;
@synthesize todaysDate;
@synthesize dayAdvanceCount;
@synthesize allCurrentAnnotations;

@synthesize activeRegionCount;
@synthesize signifChangeCount;
@synthesize enterRegionCount;
@synthesize exitRegionCount;

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
    todaysDate = [NSDate date];
    allCurrentAnnotations = [[NSMutableArray alloc] init];
    activeRegionCount = 0;
    signifChangeCount = 0;
    enterRegionCount = 0;
    exitRegionCount = 0;
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    // very temp:
//    NSLog(@"region count: %i", [[locationManager monitoredRegions]count]);
//    for (CLRegion *monitored in [locationManager monitoredRegions])
//        [locationManager stopMonitoringForRegion:monitored];
//    NSLog(@"region count: %i", [[locationManager monitoredRegions]count]);
    //
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
            int tmpRad = eachRegion.radius;
            NSString *subTitle = [[NSString alloc] initWithFormat:@"Lat: %f, Long: %f, rad: %i", tmpLat, tmpLong, tmpRad];
            tmpPin.subtitle = subTitle;
            //tmpPin.annoType = @"region";
            //tmpPin.pinColor = MKPinAnnotationColorPurple;
    //        NSString *latString = [ tmpLat];
    //        NSString *subTitle = [tmpLat stringByAppendingString:@" Lat, "];
    //        subTitle = [subTitle stringByAppendingString: [geoFenceInstance.longitude stringValue]];
    //        subTitle = [subTitle stringByAppendingString:@ " Long"];
    //        
            [mapOutlet addAnnotation:tmpPin];
            [allCurrentAnnotations addObject:tmpPin];
            MKCircle *tmpCircle = [MKCircle circleWithCenterCoordinate:myCord radius:eachRegion.radius];

            [self.mapOutlet addOverlay:tmpCircle];
            activeRegionCount++;
        }
    }
    
    // significant change stuff;
    _regionCountLabel.text = [NSString stringWithFormat:@"%i", activeRegionCount];
    managedObjectContext = [[DatabaseHelper sharedInstance] managedObjectContext];
    allSigChangeDataArray = [[NSArray alloc]init];
    NSFetchRequest *allFences = [[NSFetchRequest alloc] init];
    [allFences setEntity:[NSEntityDescription entityForName:@"SignificantChange" inManagedObjectContext:managedObjectContext]];
    
    [allFences setIncludesPropertyValues:NO];
    NSError *error = nil;
    allSigChangeDataArray = [managedObjectContext executeFetchRequest:allFences error:&error];
    NSLog(@"geofenace data has %i records", [allSigChangeDataArray count]);
    
    
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


- (IBAction)showAllChangeEvents:(id)sender
{
    NSLog(@"Gerrofff: %i", [allSigChangeDataArray count]);
    signifChangeCount = 0;
    enterRegionCount = 0;
    exitRegionCount = 0;
    for (SignificantChange *tmpChange in allSigChangeDataArray)
    {
        float lat = [tmpChange.latitude floatValue];
        float lng = [tmpChange.longitude floatValue];
        
        CLLocationCoordinate2D changeCord = CLLocationCoordinate2DMake(lat, lng);
        MyAnnotation *changePin = [[MyAnnotation alloc] initWithCoordinate:changeCord];
        
        changePin.title = tmpChange.descripString;
        NSDate *changeDate = tmpChange.date;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = @"dd/MM/yy HH:mm:ss";
        NSString *dateString = [dateFormatter stringFromDate: changeDate];
        changePin.subtitle = dateString;
        [self.mapOutlet addAnnotation:changePin];
        [allCurrentAnnotations addObject:changePin];
         if ([changePin.title hasPrefix:@"{SC}"])
         {
             signifChangeCount++;
         } else
        if ([changePin.title hasPrefix:@"{EnR}"])
        {
            enterRegionCount++;
        }
        else
        if ([changePin.title hasPrefix:@"{ExR}"])
        {
            exitRegionCount++;
        }
        _sigChangeCountLabel.text = [NSString stringWithFormat:@"%i", signifChangeCount];
        _enteredRegionCountLabel.text = [NSString stringWithFormat:@"%i", enterRegionCount];
        _exitedRegionLabelCount.text = [NSString stringWithFormat:@"%i", exitRegionCount];
    }
}

- (IBAction)daySubtract:(id)sender
{
    signifChangeCount = 0;
    enterRegionCount = 0;
    exitRegionCount = 0;
    // do this twice and it will prob blow up. Actually just want to cycle through the allSigChangeDataArray
    [self.mapOutlet removeAnnotations:allCurrentAnnotations];
    if (dayAdvanceCount > -365)
    {
        dayAdvanceCount--;
    }
    NSLog(@"dayAdvanceCount: %i", dayAdvanceCount);
    // say that's -2. target day number is today - 2.
    int todaysDayCount = [self nthDayOfYear:todaysDate];
    int targetDayCount = todaysDayCount + dayAdvanceCount;
    
    for (SignificantChange *tmpChange in allSigChangeDataArray)
    {
        float lat = [tmpChange.latitude floatValue];
        float lng = [tmpChange.longitude floatValue];
        int thisPinDayCount = [self nthDayOfYear:tmpChange.date];
        NSLog(@"thisPinDayCount: %i", thisPinDayCount);
        //if (tmpChange.date) is today -1. Got a bit of date hacking to do. Especially for the first of the month. Ugh.
        // could go cheap and convert the day of the year to a number, and just not let the daychange thing go to less than zero.
        if (targetDayCount == thisPinDayCount)
        {
            NSLog(@"hit");
            CLLocationCoordinate2D changeCord = CLLocationCoordinate2DMake(lat, lng);
            MyAnnotation *changePin = [[MyAnnotation alloc] initWithCoordinate:changeCord];
            
            changePin.title = tmpChange.descripString;
            NSDate *changeDate = tmpChange.date;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            dateFormatter.dateFormat = @"dd/MM/yy HH:mm:ss";
            NSString *dateString = [dateFormatter stringFromDate: changeDate];
            changePin.subtitle = dateString;
            [self.mapOutlet addAnnotation:changePin];
            [allCurrentAnnotations addObject:changePin];
            if ([changePin.title hasPrefix:@"{SC}"])
            {
                signifChangeCount++;
            } else
                if ([changePin.title hasPrefix:@"{EnR}"])
                {
                    enterRegionCount++;
                }
                else
                    if ([changePin.title hasPrefix:@"{ExR}"])
                    {
                        exitRegionCount++;
                    }
        }
        _sigChangeCountLabel.text = [NSString stringWithFormat:@"%i", signifChangeCount];
        _enteredRegionCountLabel.text = [NSString stringWithFormat:@"%i", enterRegionCount];
        _exitedRegionLabelCount.text = [NSString stringWithFormat:@"%i", exitRegionCount];
    }
    
}

- (IBAction)dayAdvance:(id)sender
{
    signifChangeCount = 0;
    enterRegionCount = 0;
    exitRegionCount = 0;
    [self.mapOutlet removeAnnotations:allCurrentAnnotations];
    if (dayAdvanceCount < 364)
    {
        dayAdvanceCount++;
    }
    // say that's -2. target day number is today - 2.
    int todaysDayCount = [self nthDayOfYear:todaysDate];
    int targetDayCount = todaysDayCount + dayAdvanceCount;
    
    for (SignificantChange *tmpChange in allSigChangeDataArray)
    {
        float lat = [tmpChange.latitude floatValue];
        float lng = [tmpChange.longitude floatValue];
        int thisPinDayCount = [self nthDayOfYear:tmpChange.date];
        //if (tmpChange.date) is today -1. Got a bit of date hacking to do. Especially for the first of the month. Ugh.
        // could go cheap and convert the day of the year to a number, and just not let the daychange thing go to less than zero.
        if (targetDayCount == thisPinDayCount)
        {
            CLLocationCoordinate2D changeCord = CLLocationCoordinate2DMake(lat, lng);
            MyAnnotation *changePin = [[MyAnnotation alloc] initWithCoordinate:changeCord];
            
            changePin.title = tmpChange.descripString;
            NSDate *changeDate = tmpChange.date;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            dateFormatter.dateFormat = @"dd/MM/yy HH:mm:ss";
            NSString *dateString = [dateFormatter stringFromDate: changeDate];
            changePin.subtitle = dateString;
            [self.mapOutlet addAnnotation:changePin];
            [allCurrentAnnotations addObject:changePin];
            if ([changePin.title hasPrefix:@"{SC}"])
            {
                signifChangeCount++;
            } else
                if ([changePin.title hasPrefix:@"{EnR}"])
                {
                    enterRegionCount++;
                }
                else
                    if ([changePin.title hasPrefix:@"{ExR}"])
                    {
                        exitRegionCount++;
                    }
        }
        _sigChangeCountLabel.text = [NSString stringWithFormat:@"%i", signifChangeCount];
        _enteredRegionCountLabel.text = [NSString stringWithFormat:@"%i", enterRegionCount];
        _exitedRegionLabelCount.text = [NSString stringWithFormat:@"%i", exitRegionCount];
    }
}

- (IBAction)todaysEvents:(id)sender
{
    signifChangeCount = 0;
    enterRegionCount = 0;
    exitRegionCount = 0;
    [self.mapOutlet removeAnnotations:allCurrentAnnotations];
    dayAdvanceCount = 0;
    // say that's -2. target day number is today - 2.
    int todaysDayCount = [self nthDayOfYear:todaysDate];
    
    // adding zero but leaving this to be the same as above:
    int targetDayCount = todaysDayCount + dayAdvanceCount;
    
    for (SignificantChange *tmpChange in allSigChangeDataArray)
    {
        float lat = [tmpChange.latitude floatValue];
        float lng = [tmpChange.longitude floatValue];
        int thisPinDayCount = [self nthDayOfYear:tmpChange.date];
        //if (tmpChange.date) is today -1. Got a bit of date hacking to do. Especially for the first of the month. Ugh.
        // could go cheap and convert the day of the year to a number, and just not let the daychange thing go to less than zero.
        if (targetDayCount == thisPinDayCount)
        {
            CLLocationCoordinate2D changeCord = CLLocationCoordinate2DMake(lat, lng);
            MyAnnotation *changePin = [[MyAnnotation alloc] initWithCoordinate:changeCord];
            
            changePin.title = tmpChange.descripString;
            NSDate *changeDate = tmpChange.date;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            dateFormatter.dateFormat = @"dd/MM/yy HH:mm:ss";
            NSString *dateString = [dateFormatter stringFromDate: changeDate];
            changePin.subtitle = dateString;
            [self.mapOutlet addAnnotation:changePin];
            [allCurrentAnnotations addObject:changePin];
            if ([changePin.title hasPrefix:@"{SC}"])
            {
                signifChangeCount++;
            } else
                if ([changePin.title hasPrefix:@"{EnR}"])
                {
                    enterRegionCount++;
                }
                else
                    if ([changePin.title hasPrefix:@"{ExR}"])
                    {
                        exitRegionCount++;
                    }

        }
        _sigChangeCountLabel.text = [NSString stringWithFormat:@"%i", signifChangeCount];
        _enteredRegionCountLabel.text = [NSString stringWithFormat:@"%i", enterRegionCount];
        _exitedRegionLabelCount.text = [NSString stringWithFormat:@"%i", exitRegionCount];
    }
}


// http://stackoverflow.com/questions/13794895/how-do-i-change-the-pin-color-of-an-annotation-in-map-kit-view
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    //NSLog(@"viewForAnnotation");
    static NSString *identifier = @"MyLocation";
    if ([annotation isKindOfClass:[MyAnnotation class]])
    {
        //NSLog(@"iffing");
        MKAnnotationView *annotationView = (MKAnnotationView *) [mapOutlet dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil)
        {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            //annotationView.centerOffset = CGPointMake(-10, 0);
            //([myString hasPrefix:@"http"])
            if ([annotation.title hasPrefix:@"{SC}"])
            {
                //newString = [originalString substringFromIndex:[prefixToRemove length]];
                //NSString *tmpTitleString = [annotation.title substringFromIndex:[@"{SC}" length]];
                //annotationView.title = tmpTitleString;
                NSLog(@"viewForAnnotation: Significant Change");
                annotationView.image = [UIImage imageNamed:@"orangeSmall.png"];
                //signifChangeCount++;
            }
            else if ([annotation.title hasPrefix:@"{EnR}"])
            {
                NSLog(@"viewForAnnotation: Entered Region");
                annotationView.image = [UIImage imageNamed:@"greenSmall.png"];
                //enterRegionCount++;
            }
            else if ([annotation.title hasPrefix:@"{ExR}"])
            {
                NSLog(@"viewForAnnotation: Exited Region");
                annotationView.image = [UIImage imageNamed:@"purpleSmall.png"];
                //exitRegionCount++;
            }
            else
            {
                NSLog(@"viewForAnnotation red: %@", annotation.title);
                annotationView.image = [UIImage imageNamed:@"redSmall.png"];
            }
            //annotationView.image = [UIImage imageNamed:@"orangeSmall.png"];//here we use a nice image instead of the default pins
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

// - (id) initWithWallData: (NSDate *)wallDateData 
- (int) nthDayOfYear: (NSDate *)thisDate
{
    int dayOfYear = 0;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    dayOfYear = [gregorian ordinalityOfUnit:NSDayCalendarUnit inUnit:NSYearCalendarUnit forDate:thisDate];
    return dayOfYear;
    
}

@end
