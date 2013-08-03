//
//  AppDelegate.m
//  Tsker
//
//  Created by Donal Hanna on 23/05/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//

#import "AppDelegate.h"
#import "MyCLController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <MailCore/MailCore.h>

@implementation AppDelegate

#define weatherForHuntingdonURL [NSURL URLWithString: @"http://api.worldweatheronline.com/free/v1/weather.ashx?q=Huntingdon&format=json&key=7ec93enseab47ag96z676ftr"]

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1

@synthesize bgTask;
@synthesize timer;
@synthesize expirationHandler;
@synthesize jobExpired;
@synthesize persistenceCheck;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    
    //UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    //GeoFencesTableViewController *controller = (GeoFencesTableViewController *)navigationController.topViewController;
    //controller.managedObjectContext = self.managedObjectContext;
    
    // weather: - not convinced I'm going to keep this:
//    persistenceCheck = 0;
//    dispatch_async(kBgQueue, ^{
//    NSData* data = [NSData dataWithContentsOfURL:
//                    weatherForHuntingdonURL];
//    [self performSelectorOnMainThread:@selector(fetchedData:)
//                           withObject:data waitUntilDone:YES];
//
//});
    // ----> Comment out for redirect to Xcode log:
    
    //[self redirectConsoleLogToDocumentFolder];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"");
    if ([CLLocationManager significantLocationChangeMonitoringAvailable])
    {
        [locationManager stopMonitoringSignificantLocationChanges];
        // not sure if this needs to cycle through all of the regions as well...
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"applicationWillTerminate: I'm being whacked!!");
}




- (void)applicationDidEnterBackground:(UIApplication *)application {
    
        
    NSLog(@"applicationDidEnterBackground");
    //CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    //UIApplication*    app = [UIApplication sharedApplication];
    // experiment to try this without the VOIP:
    
//    BOOL backgroundAccepted = [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{ [self backgroundHandler]; }];
//    if (backgroundAccepted)
//    {
//        NSLog(@"VOIP backgrounding accepted");
//        [self bgStuff];
//    }
    
    [self bgStuff];
    // it's better to move "dispatch_block_t expirationHandler"
    // into your headerfile and initialize the code somewhere else
    // i.e.
    // - (void)applicationDidFinishLaunching:(UIApplication *)application {
    //
    // expirationHandler = ^{ ... } }
    // because your app may crash if you initialize expirationHandler twice.
    // also need to kill this if we go back into foreground. one to puzzle over...
//    dispatch_block_t expirationHandler;
//    expirationHandler = ^{
//        
//        [app endBackgroundTask:bgTask];
//        bgTask = UIBackgroundTaskInvalid;
//        
//        
//        bgTask = [app beginBackgroundTaskWithExpirationHandler:expirationHandler];
//    };
//    
//    bgTask = [app beginBackgroundTaskWithExpirationHandler:expirationHandler];
//    
//    
//    // Start the long-running task and return immediately.
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        // inform others to stop tasks, if you like
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"MyApplicationEntersBackground" object:self];
//        
//        // do your background work here
//        NSLog(@"I is for real");
//        [self bgStuff];
//    });

    
}


-(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //[self sendBackgroundLocationToServer:newLocation];
    NSLog(@"locationManager: didUpdateToLocation");
    //NSDate *alertTime = [[NSDate date] dateByAddingTimeInterval:10];
    UIApplication* app = [UIApplication sharedApplication];
    localNotification = [[UILocalNotification alloc] init];
    //NSString *locationInfo = [newLocation description];
    // not using this for the notification - yet....
    if (oldLocation)
    {
        float lat = newLocation.coordinate.latitude;
        float lng = newLocation.coordinate.longitude;
        NSString *bodyString = [NSString stringWithFormat:@"Significant change: %f, %f", lat, lng];
        localNotification.alertBody = bodyString;
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        localNotification.fireDate = [NSDate date];
        //NSUInteger nextBadgeNumber = [[[UIApplication sharedApplication] scheduledLocalNotifications] count] + 1;
        localNotification.applicationIconBadgeNumber++; // = nextBadgeNumber;
        [app scheduleLocalNotification:localNotification];
    }
}

-(void) locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
  //[self sendBackgroundLocationToServer:newLocation];
    NSLog(@"locationManager  didEnterRegion: %@", region.description);
    //NSDate *alertTime = [[NSDate date] dateByAddingTimeInterval:10];
    UIApplication* app = [UIApplication sharedApplication];
    localNotification = [[UILocalNotification alloc] init];
    NSString *regionID =@ "Entering ";
    regionID = [regionID stringByAppendingString:region.identifier];
    localNotification.alertBody = regionID;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.fireDate = [NSDate date];
    localNotification.soundName = @"alarmsound.caf";
    //NSUInteger nextBadgeNumber = [[[UIApplication sharedApplication] scheduledLocalNotifications] count] + 1;
    localNotification.applicationIconBadgeNumber++; // = nextBadgeNumber;
    [app scheduleLocalNotification:localNotification];
    [self emailUpdate:regionID body:@"and all is well"];
    if ([region.identifier isEqualToString: @"Kings Cross Station"])
    {
        NSLog(@"Kings Cross - trying to email Sarah");
        NSString *sarahSubject =@"I promise I will change this";
        NSString *sarahBody =@"This is an automated message, and I'm in Kings Cross.";
        [self sarahMmailUpdate:sarahSubject body:sarahBody];
    }
}

-(void) locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"locationManager didExitRegion");
    UIApplication* app = [UIApplication sharedApplication];
    NSString *regionID =@ "Leaving ";
    regionID = [regionID stringByAppendingString:region.identifier];
    NSLog(@"locationManager didExitRegion: %@", regionID);
    localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = regionID;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.fireDate = [NSDate date];
    localNotification.soundName = @"alarmsound.caf";
    //NSUInteger nextBadgeNumber = [[[UIApplication sharedApplication] scheduledLocalNotifications] count] + 1;
    localNotification.applicationIconBadgeNumber++; // = nextBadgeNumber;
    [app scheduleLocalNotification:localNotification];
}

-(void) locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    NSLog(@"Region monitoring failed with error: %@", [error localizedDescription]);
}

-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"locationManager failed with error: %@", [error localizedDescription]);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"didChangeAuthorizationStatus");
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{
    NSLog(@"didChangeAuthorizationStatus");
}

-(void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager
{
    NSLog(@"locationManagerDidResumeLocationUpdates");
}

-(void) bgStuff
{
    NSLog(@"bgStuff");
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [CLLocationManager regionMonitoringAvailable];
    //[CLLocationManager regionMonitoringEnabled];
    [locationManager startMonitoringSignificantLocationChanges];
    //[locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    //[locationManager setDistanceFilter:500];
    //[locationManager startUpdatingLocation];
//    bigChange = [CLLocationManager significantLocationChangeMonitoringAvailable];
//    CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake(52.338092,-0.159945);
//    
//    dNaHouse = [[CLRegion alloc] initCircularRegionWithCenter:coordinates radius:150 identifier:@"DNA"];
//    [locationManager startMonitoringForRegion:dNaHouse];
//    //52.329543,-0.179021
//    // train station: 52.330461,-0.191059
//    
//    CLLocationCoordinate2D homeCoordinates = CLLocationCoordinate2DMake(52.329543,-0.179021);
//    atHome = [[CLRegion alloc] initCircularRegionWithCenter:homeCoordinates radius:150 identifier:@"Home Sweet Home"];
//    [locationManager startMonitoringForRegion:atHome];
//    
//    CLLocationCoordinate2D trainStationCoOrds = CLLocationCoordinate2DMake(52.330461,-0.191059);
//    trainRegion = [[CLRegion alloc] initCircularRegionWithCenter:trainStationCoOrds radius:150 identifier:@"Huntingdon Train Station"];
//    [locationManager startMonitoringForRegion:trainRegion];
//    
//    CLLocationCoordinate2D kxStationCoOrds = CLLocationCoordinate2DMake(51.531307,-0.123017);
//    kingsCross = [[CLRegion alloc] initCircularRegionWithCenter:kxStationCoOrds radius:150 identifier:@"Kings Cross Station"];
//    [locationManager startMonitoringForRegion:kingsCross];
//    
//    CLLocationCoordinate2D graysInnCrds = CLLocationCoordinate2DMake(51.526314,-0.116043);
//    CLRegion *graysInn = [[CLRegion alloc] initCircularRegionWithCenter:graysInnCrds radius:150 identifier:@"Grays Inn Rd"];
//    [locationManager startMonitoringForRegion:graysInn];
//    
//    // Paternoster: 51.514663,-0.098649
//    
//    CLLocationCoordinate2D paterNosterCrds = CLLocationCoordinate2DMake(51.514663,-0.098649);
//    CLRegion *paterNoster = [[CLRegion alloc] initCircularRegionWithCenter:paterNosterCrds radius:150 identifier:@"Grays Inn Rd"];
//    [locationManager startMonitoringForRegion:paterNoster];
//    
//    // Newgate St: 51.516461,-0.099864
//    
//    CLLocationCoordinate2D newGateCrds = CLLocationCoordinate2DMake(51.514663,-0.098649);
//    CLRegion *newGate = [[CLRegion alloc] initCircularRegionWithCenter:newGateCrds radius:150 identifier:@"Grays Inn Rd"];
//    [locationManager startMonitoringForRegion:newGate];
    
    
}

- (void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    
    NSDictionary *huntingDonData = [json objectForKey:@"data"];
    // this is weird:
    NSArray *currentData = [huntingDonData objectForKey:@"current_condition"];
    // unless I parse via the array item at index 0, I can't get the named objectForKeys out
    NSDictionary *allKeys = [currentData objectAtIndex:0];
    NSString *thereYet = [allKeys objectForKey:@"temp_C"];
    NSLog(@"stuff: %@", thereYet);

}


- (void)backgroundHandler
{
    persistenceCheck++;
    NSLog(@"### -->count for persistence check %i", persistenceCheck);
    // try to do sth. According to Apple we have ONLY 30 seconds to perform this Task!
    // Else the Application will be terminated!
    UIApplication* app = [UIApplication sharedApplication];
    NSArray*    oldNotifications = [app scheduledLocalNotifications];
    
    // Clear out the old notification before scheduling a new one.
    if ([oldNotifications count] > 0) [app cancelAllLocalNotifications];
    // may not need to do this every time: i.e., add the regions to the locationManager etc:
    // given the test below, disabling this for now:
    //[self bgStuff];
    NSArray *regionArray = [[locationManager monitoredRegions] allObjects]; // the all objects is the key
    for (int i = 0; i < [regionArray count]; i++)
    {
        CLRegion *vTmpRegion = [regionArray objectAtIndex:i];
        NSString *tmpDescrpn = vTmpRegion.description;
        NSLog(@"Region monitored: %@", tmpDescrpn);
    }
    
    // Create a new notification
    UILocalNotification* alarm = [[UILocalNotification alloc] init];
    if (alarm)
    {
        alarm.fireDate = [NSDate date];
        alarm.timeZone = [NSTimeZone defaultTimeZone];
        alarm.repeatInterval = 0;
        //alarm.soundName = @"alarmsound.caf";
        NSString *bodyString =@ "Interation #  ";
        NSString *persistString = [NSString stringWithFormat:@"%i", persistenceCheck];
        bodyString =  [bodyString stringByAppendingString:persistString];
        NSString *regionCountString =[NSString stringWithFormat:@"%i", [regionArray count]];
        bodyString = [bodyString stringByAppendingString:@". Regions: "];
        bodyString = [bodyString stringByAppendingString: regionCountString];
        alarm.alertBody = bodyString;
        
        [app scheduleLocalNotification:alarm];
    }
}
//- (void)fetchedData:(NSData *)responseData {
-(void) emailUpdate:(NSString *)subject body:(NSString *) body
{
    CTCoreMessage *testMsg = [[CTCoreMessage alloc] init];
    
    [testMsg setTo:[NSSet setWithObject:[CTCoreAddress addressWithName:@"Donal" email:@"donal.hanna@the-plot.com"]]];
    [testMsg setFrom:[NSSet setWithObject:[CTCoreAddress addressWithName:@"Donal" email:@"donal.hanna@the-plot.com"]]];
    [testMsg setBody:body];
    [testMsg setSubject:subject];
    
    NSError *sendError;
    BOOL success = [CTSMTPConnection sendMessage:testMsg server:@"smtp.the-plot.com" username:@"donal.hanna+the-plot.com" password:@"Randomi2e" port:587 connectionType:CTSMTPConnectionTypeStartTLS useAuth:YES error:&sendError];
    if (!success)
    {
        NSLog(@"%@", [sendError userInfo]);
    }

}

-(void) sarahMmailUpdate:(NSString *)subject body:(NSString *) body
{
    CTCoreMessage *testMsg = [[CTCoreMessage alloc] init];
    
    [testMsg setTo:[NSSet setWithObject:[CTCoreAddress addressWithName:@"Donal" email:@"sarah.hanna@the-plot.com"]]];
    [testMsg setFrom:[NSSet setWithObject:[CTCoreAddress addressWithName:@"Donal" email:@"donal.hanna@the-plot.com"]]];
    [testMsg setBody:body];
    [testMsg setSubject:subject];
    
    NSError *sendError;
    BOOL success = [CTSMTPConnection sendMessage:testMsg server:@"smtp.the-plot.com" username:@"donal.hanna+the-plot.com" password:@"Randomi2e" port:587 connectionType:CTSMTPConnectionTypeStartTLS useAuth:YES error:&sendError];
    if (!success)
    {
        NSLog(@"%@", [sendError userInfo]);
    }
    
}

- (void) redirectConsoleLogToDocumentFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"console.log"];
    freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
}




@end
