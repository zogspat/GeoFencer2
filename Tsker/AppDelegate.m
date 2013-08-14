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
#import "constants.h"

@implementation AppDelegate

#define googleURLasString @"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=LAT,LONG&radius=500&types=bar&sensor=true&key=AddYourOwnKeyHere"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1

@synthesize bgTaskforWoL;
@synthesize timer;
@synthesize expirationHandler;
@synthesize jobExpired;
@synthesize persistenceCheck;
@synthesize managedObjectContext;
@synthesize regionActionMapping;
@synthesize settingsDict;
@synthesize ssidName;
@synthesize googleHitCount;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"didFinishLaunchingWithOptions - entering");

    // test wifi functionality:
//    id networkInfo = [self fetchSSIDInfo];
//    NSDictionary *tmpNetworkInfoDict = networkInfo;
//    NSString *ssidName = [tmpNetworkInfoDict valueForKey:@"SSID"];
//    NSLog(@"I think the ssid is %@", ssidName);
    
    UIApplication* app = [UIApplication sharedApplication];
    NSArray*    oldNotifications = [app scheduledLocalNotifications];
    NSLog(@"Old notification queue has %i items", [oldNotifications count]);
    if ([oldNotifications count] > 0)
        [app cancelAllLocalNotifications];
    // toggle this off and on to log to phone vs console:
    [self redirectConsoleLogToDocumentFolder];
    managedObjectContext = [[DatabaseHelper sharedInstance] managedObjectContext];
    
    // http://stackoverflow.com/questions/10977679/recieving-location-updates-after-app-is-terminated
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    // not convinced based on link above so... 
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsAnnotationKey])
    {
        NSLog(@"UIApplicationLaunchOptionsAnnotationKey didFinishLaunchingWithOptions restart!");
        locationManager = [[CLLocationManager alloc] init];
        [locationManager setDelegate:self];
        [CLLocationManager regionMonitoringAvailable];
        //[CLLocationManager regionMonitoringEnabled];
        [locationManager startMonitoringSignificantLocationChanges];
        UILocalNotification *altRestartNotify = [[UILocalNotification alloc] init];
        NSString *bodyString = [NSString stringWithFormat:@"UIApplicationLaunchOptionsAnnotationKey: I died but I'm back!"];
        altRestartNotify.alertBody = bodyString;
        altRestartNotify.timeZone = [NSTimeZone defaultTimeZone];
        altRestartNotify.fireDate = [NSDate date];
        //NSUInteger nextBadgeNumber = [[[UIApplication sharedApplication] scheduledLocalNotifications] count] + 1;
        //localNotification.applicationIconBadgeNumber++; // = nextBadgeNumber;
        [app scheduleLocalNotification:altRestartNotify];

    }
    //... 06/08: adding this:
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey])
    {
        locationManager = [[CLLocationManager alloc] init];
        [locationManager setDelegate:self];
        [CLLocationManager regionMonitoringAvailable];
        //[CLLocationManager regionMonitoringEnabled];
        [locationManager startMonitoringSignificantLocationChanges];
        /// and:
        NSLog(@"UIApplicationLaunchOptionsLocationKey didFinishLaunchingWithOptions restart!");
        // dying here with NSInvalidArgumentException. Possibly because re-using the same variable,
        // localNotification, which is being set with multiple vals:
        UILocalNotification *restartNotify = [[UILocalNotification alloc] init];
        NSString *bodyString = [NSString stringWithFormat:@"UIApplicationLaunchOptionsLocationKey: I died but I'm back!"];
        restartNotify.alertBody = bodyString;
        restartNotify.timeZone = [NSTimeZone defaultTimeZone];
        restartNotify.fireDate = [NSDate date];
        //NSUInteger nextBadgeNumber = [[[UIApplication sharedApplication] scheduledLocalNotifications] count] + 1;
        //localNotification.applicationIconBadgeNumber++; // = nextBadgeNumber;
        [app scheduleLocalNotification:restartNotify];
    }
    if (regionActionMapping == nil)
    {
        // residue of getting confused when trying to add objects to an NSDictionary [not a mutable one]
        // one object at a time. Leaving for now :)
        NSLog(@"regionActionMapping is nil");
        regionActionMapping = [[NSMutableDictionary alloc] init];
    }
    [self prepFenceActionLookup];
    NSLog(@"~~~~> Everybody up - stuff to do!! prepFenceAction has %i items!!", [regionActionMapping count]);
    [self prepSettingsData];
    NSLog(@"didFinishLaunchingWithOptions - leaving");
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
    //[[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"applicationDidBecomeActive");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"applicationWillTerminate: I'm being whacked!!");
}




- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"applicationDidEnterBackground");
    [self bgStuff];
}


-(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // check the value for sigChangeFnBool:
    [self prepSettingsData];
    NSLog(@"Value for sig change boolean is %@", [settingsDict valueForKey:@"sigChangeFnBool"]);
    if ([settingsDict valueForKey:@"sigChangeFnBool"])
    {
        //[self sendBackgroundLocationToServer:newLocation];
        NSLog(@"locationManager: didUpdateToLocation");
        //NSDate *alertTime = [[NSDate date] dateByAddingTimeInterval:10];
        UIApplication* app = [UIApplication sharedApplication];
        UILocalNotification *changeNotification = [[UILocalNotification alloc] init];
        //NSString *locationInfo = [newLocation description];
        // not using this for the notification - yet....
        if (oldLocation)
        {
            float lat = newLocation.coordinate.latitude;
            float lng = newLocation.coordinate.longitude;
            NSString *urlWithLat = [googleURLasString stringByReplacingOccurrencesOfString:@"LAT" withString:[NSString stringWithFormat:@"%f", lat]];
            NSString *urlWithLong = [urlWithLat stringByReplacingOccurrencesOfString:@"LONG" withString:[NSString stringWithFormat:@"%f", lng]];
            NSString *urlWithKey = [urlWithLong stringByReplacingOccurrencesOfString:@"AddYourOwnKeyHere" withString:GOOGLEAPIKEY];
            NSLog(@"google url: %@", urlWithKey);
            NSURL *googURL = [NSURL URLWithString: urlWithKey];
            dispatch_async(kBgQueue, ^{
                NSData* googData = [NSData dataWithContentsOfURL:
                                googURL];
                [self performSelectorOnMainThread:@selector(fetchedData:)
                                       withObject:googData waitUntilDone:YES];
            });
            NSLog(@"Prepping a sig change local notification");
            // GeoFence *newFenceToInsert = [NSEntityDescription insertNewObjectForEntityForName:@"GeoFence" inManagedObjectContext:managedObjectContext];
            SignificantChange *changeToAdd = [NSEntityDescription insertNewObjectForEntityForName:@"SignificantChange" inManagedObjectContext:managedObjectContext];
            [changeToAdd setDate:[NSDate date]];
            [changeToAdd setLatitude:[[NSNumber alloc] initWithFloat:lat]];
            [changeToAdd setLongitude:[[NSNumber alloc] initWithFloat:lng]];
            [changeToAdd setDescripString:@"{SC}Significant Change"];
            [managedObjectContext save:nil];
            NSString *bodyString = [NSString stringWithFormat:@"Significant change: %f, %f", lat, lng];
            changeNotification.alertBody = bodyString;
            changeNotification.timeZone = [NSTimeZone defaultTimeZone];
            changeNotification.fireDate = [NSDate date];
            //NSUInteger nextBadgeNumber = [[[UIApplication sharedApplication] scheduledLocalNotifications] count] + 1;
            //localNotification.applicationIconBadgeNumber++; // = nextBadgeNumber;
            [app scheduleLocalNotification:changeNotification];
        }
    }
}

-(void) locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    // bit of a test: not picking this up in did enter foreground.
    [self prepSettingsData];
    [self prepFenceActionLookup];
    NSString *requiredAction = [regionActionMapping objectForKey:region.identifier];
    NSLog(@"****---->>>> didEnterRegion: action is %@ ", requiredAction);
    NSLog(@"Based on a region identifier of %@", region.identifier);
    NSLog(@"regionActionMapping has %i items", [regionActionMapping count]);

    if ([settingsDict valueForKey:@"sigChangeFnBool"])
    {
        float lat = region.center.latitude;
        float lng = region.center.longitude;
        SignificantChange *changeToAdd = [NSEntityDescription insertNewObjectForEntityForName:@"SignificantChange" inManagedObjectContext:managedObjectContext];
        [changeToAdd setDate:[NSDate date]];
        [changeToAdd setLatitude:[[NSNumber alloc] initWithFloat:lat]];
        [changeToAdd setLongitude:[[NSNumber alloc] initWithFloat:lng]];
        [changeToAdd setDescripString:@"{EnR}Entered Region"];
        [managedObjectContext save:nil];
    }
    NSString *regionID =@ "Entering ";
    regionID = [regionID stringByAppendingString:region.identifier];
    if ([requiredAction isEqualToString:@"Local Notification"])
    {
        NSLog(@"didEnterRegion: action Local Notification: locationManager  didEnterRegion: %@", region.description);
        //NSDate *alertTime = [[NSDate date] dateByAddingTimeInterval:10];
        UIApplication* app = [UIApplication sharedApplication];
        UILocalNotification *enterNotification = [[UILocalNotification alloc] init];
        enterNotification.alertBody = regionID;
        enterNotification.timeZone = [NSTimeZone defaultTimeZone];
        enterNotification.fireDate = [NSDate date];
        enterNotification.soundName = @"alarmsound.caf";
        //NSUInteger nextBadgeNumber = [[[UIApplication sharedApplication] scheduledLocalNotifications] count] + 1;
        enterNotification.applicationIconBadgeNumber++; // = nextBadgeNumber;
        [app scheduleLocalNotification:enterNotification];
    }
    else if ([requiredAction isEqualToString:@"Email"])
    {
        // email seems to really hold up the main thread so:
        //[self emailUpdate:regionID body:@"and all is well"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"didEnterRegion: action email: %@", regionID);
            NSLog(@"regionActionMapping dictionary has %i items", [regionActionMapping count]);
            [self emailUpdate:regionID body:@"and all is well"];; // 1
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Back from email"); // 2
            });
        });
    }
    else if ([requiredAction isEqualToString:@"Wake on LAN"])
    {
        NSLog(@"didEnterRegion: action: Wake on LAN: %@", regionID);
        [self extendedBGWoL];
    }
}

-(void) locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [self prepSettingsData];
    NSLog(@"Value for sig change boolean is %@", [settingsDict valueForKey:@"sigChangeFnBool"]);
    if ([settingsDict valueForKey:@"sigChangeFnBool"])
    {
        float lat = region.center.latitude;
        float lng = region.center.longitude;
        SignificantChange *changeToAdd = [NSEntityDescription insertNewObjectForEntityForName:@"SignificantChange" inManagedObjectContext:managedObjectContext];
        [changeToAdd setDate:[NSDate date]];
        [changeToAdd setLatitude:[[NSNumber alloc] initWithFloat:lat]];
        [changeToAdd setLongitude:[[NSNumber alloc] initWithFloat:lng]];
        [changeToAdd setDescripString:@"{ExR}Exited Region"];
        [managedObjectContext save:nil];
        NSLog(@"locationManager didExitRegion");
        UIApplication* app = [UIApplication sharedApplication];
        NSString *regionID =@ "Leaving ";
        regionID = [regionID stringByAppendingString:region.identifier];
        NSLog(@"locationManager didExitRegion: %@", regionID);
        
        UILocalNotification *exitNotification = [[UILocalNotification alloc] init];
        exitNotification.alertBody = regionID;
        exitNotification.timeZone = [NSTimeZone defaultTimeZone];
        exitNotification.fireDate = [NSDate date];
        exitNotification.soundName = @"alarmsound.caf";
        exitNotification.alertAction =@"OK";
        //NSUInteger nextBadgeNumber = [[[UIApplication sharedApplication] scheduledLocalNotifications] count] + 1;
        exitNotification.applicationIconBadgeNumber++; // = nextBadgeNumber;
        [app scheduleLocalNotification:exitNotification];
    }
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
}


// http://stackoverflow.com/questions/3928861/best-practice-to-send-a-lot-of-data-in-background-on-ios4-device
// need to invalidate the extension request

- (void) extendedBGWoL
{
    NSLog(@"~~~~~>>>  ENTERING extendedBGWoL");
    UIApplication *app = [UIApplication sharedApplication];
    
    bgTaskforWoL = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTaskforWoL];
        bgTaskforWoL = UIBackgroundTaskInvalid;
    }];
    // start trying to send WoL packets here
    // first try and identify when the network is available:
    int attemptCount = 1;
    BOOL foundMyNetwork = FALSE;
    //for (int attemptAtNetworkCount = 0; attemptAtNetworkCount <= 19; attemptAtNetworkCount++)
    while ((attemptCount <= 18) && !(foundMyNetwork))
    {
        id networkInfo = [self fetchSSIDInfo];
        NSDictionary *tmpNetworkInfoDict = networkInfo;
        ssidName = [tmpNetworkInfoDict valueForKey:@"SSID"];
        NSLog(@"I think the ssid is %@", ssidName);
        if ([ssidName isEqualToString:HOMENETWORKSSID])
        {
            // no point in carrying on the for loop:
            NSLog(@"=======>>>>>>  We have found the home network!!!");
            // may need to replace the break with a boolean and test for it.
            foundMyNetwork = TRUE;
        }
        else
        {
            NSLog(@"%i: Sleeping for 30 secs. I think!", attemptCount);
            attemptCount++;
            [NSThread sleepForTimeInterval:30];
        }

    }
    // A word on the maths: beginBackgroundTaskWithExpirationHandler gives us 10 mins.
    // The delay below is 30 seconds: calling it 19 times to try to discover the home network
    // within the region. That leaves 30 seconds to then try to send the WoL packets. 100 of them,
    // just to be on the safe side! Actually the sleepfortimeinterval seems to be over 30 seconds.
    // Hence 18 attempts
        

    NSLog(@"is ssidName [%@] matching HOMENETWORKSSID [%@]?", ssidName, HOMENETWORKSSID);
    if ([ssidName isEqualToString:HOMENETWORKSSID])
    {
        // Let's send some WoL packets
        NSString *wolMACString = [settingsDict valueForKey:@"mACforWolIp"];
        NSString *wolIPSring = [settingsDict valueForKey:@"wolIP"];
        ArpFunctionality *arpStuff = [[ArpFunctionality alloc] init];
        NSArray *macAddrAsInts = [arpStuff convertMACStringToIntArray:wolMACString];
        for (int packetSendCount = 0; packetSendCount <= 100; packetSendCount++)
        {
            [arpStuff sendWoLPacket:macAddrAsInts inputIP:wolIPSring];
            NSLog(@"sending WoL packet %i to %@", packetSendCount, wolMACString);
        }
    }
    NSLog(@"~~~~~>>>  LEAVING extendedBGWoL");
}


//- (void)backgroundHandler
//{
//    persistenceCheck++;
//    NSLog(@"### -->count for persistence check %i", persistenceCheck);
//    // try to do sth. According to Apple we have ONLY 30 seconds to perform this Task!
//    // Else the Application will be terminated!
//    UIApplication* app = [UIApplication sharedApplication];
//    NSArray*    oldNotifications = [app scheduledLocalNotifications];
//    
//    // Clear out the old notification before scheduling a new one.
//    if ([oldNotifications count] > 0) [app cancelAllLocalNotifications];
//    // may not need to do this every time: i.e., add the regions to the locationManager etc:
//    // given the test below, disabling this for now:
//    //[self bgStuff];
//    NSArray *regionArray = [[locationManager monitoredRegions] allObjects]; // the all objects is the key
//    for (int i = 0; i < [regionArray count]; i++)
//    {
//        CLRegion *vTmpRegion = [regionArray objectAtIndex:i];
//        NSString *tmpDescrpn = vTmpRegion.description;
//        NSLog(@"Region monitored: %@", tmpDescrpn);
//    }
//    
//    // Create a new notification
//    UILocalNotification* alarm = [[UILocalNotification alloc] init];
//    if (alarm)
//    {
//        alarm.fireDate = [NSDate date];
//        alarm.timeZone = [NSTimeZone defaultTimeZone];
//        alarm.repeatInterval = 0;
//        //alarm.soundName = @"alarmsound.caf";
//        NSString *bodyString =@ "Iteration #  ";
//        NSString *persistString = [NSString stringWithFormat:@"%i", persistenceCheck];
//        bodyString =  [bodyString stringByAppendingString:persistString];
//        NSString *regionCountString =[NSString stringWithFormat:@"%i", [regionArray count]];
//        bodyString = [bodyString stringByAppendingString:@". Regions: "];
//        bodyString = [bodyString stringByAppendingString: regionCountString];
//        alarm.alertBody = bodyString;
//        
//        [app scheduleLocalNotification:alarm];
//    }
//}

-(void) emailUpdate:(NSString *)subject body:(NSString *) body
{
    CTCoreMessage *testMsg = [[CTCoreMessage alloc] init];
    NSLog(@"Trying to email region update to %@", [settingsDict valueForKey:@"toEmail"]);
    [testMsg setTo:[NSSet setWithObject:[CTCoreAddress addressWithName:[settingsDict valueForKey:@"toEmail"] email:[settingsDict valueForKey:@"toEmail"]]]];
    [testMsg setFrom:[NSSet setWithObject:[CTCoreAddress addressWithName:[settingsDict valueForKey:@"fromEmail"] email:[settingsDict valueForKey:@"fromEmail"]]]];
    [testMsg setBody:body];
    [testMsg setSubject:subject];
    
    NSError *sendError;
    BOOL success = [CTSMTPConnection sendMessage:testMsg server:[settingsDict valueForKey:@"smtpServer"] username:[settingsDict valueForKey:@"fromEmail"] password:[settingsDict valueForKey:@"smtpPasswd"] port:25 connectionType:CTSMTPConnectionTypePlain useAuth:YES error:&sendError];
    if (!success)
    {
        NSLog(@"%@", [sendError userInfo]);
    }
    NSLog(@"lasterror: %@", testMsg.lastError);
}


- (void) redirectConsoleLogToDocumentFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"console.log"];
    freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
}

- (void) prepFenceActionLookup
{
    // either on start or when the delegate based relaunch from action restarts, this gets called. Loads the GeoFence
    // metadata from CoreData, and populates a dictionary to create the link between the geofence name and the required action
    NSFetchRequest *allFences = [[NSFetchRequest alloc] init];
    [allFences setEntity:[NSEntityDescription entityForName:@"GeoFence" inManagedObjectContext:managedObjectContext]];
    
    [allFences setIncludesPropertyValues:NO];
    NSError *error = nil;
    NSArray *allFenceDataArray = [[NSArray alloc] init];
    allFenceDataArray = [managedObjectContext executeFetchRequest:allFences error:&error];
    NSLog(@"prepFenceActionLookup: geofenace data has %i records", [allFenceDataArray count]);
    // think the regions are hanging around after a reboot / reinstall. This is a sticking plaster:
    if ([allFenceDataArray count] == 0)
    {
        NSLog(@"allFenceDataArray is zero zapping monitored regions [%i]",[[locationManager monitoredRegions] count] );
        for (CLRegion *monitored in [locationManager monitoredRegions])
            [locationManager stopMonitoringForRegion:monitored];
    }
    NSLog(@"allFenceDataArray now has this many monitored regions [%i]",[[locationManager monitoredRegions] count] );
    //regionActionMapping = nil;
    //regionActionMapping = [NSDictionary alloc] ;
    for (GeoFence *tmpFence in allFenceDataArray)
    {
        [regionActionMapping setValue:tmpFence.action forKey:tmpFence.name];
        NSLog(@"prepFenceActionLookup: action is %@, name is %@", tmpFence.action, tmpFence.name);
    }
    NSLog(@"prepFenceActionLookup: leaving, and regionActionMapping has %i items", [regionActionMapping count]);

}

- (void) prepSettingsData
{
    // Loads already-created data from CoreData - need this for email addresses, smtp server detail etc.
    NSFetchRequest *settingsFetch = [[NSFetchRequest alloc] init];
    [settingsFetch setEntity:[NSEntityDescription entityForName:@"Settings" inManagedObjectContext:managedObjectContext]];
    [settingsFetch setIncludesPropertyValues:NO];
    NSError *error = nil;
    NSArray *allSettingsDataArray = [[NSArray alloc] init];
    allSettingsDataArray = [managedObjectContext executeFetchRequest:settingsFetch error:&error];
    NSLog(@"3");
    if (![allSettingsDataArray count] == 0)
    {
        settingsDict = allSettingsDataArray[0];
        NSLog(@"Reading the settings and here's one: %@", [settingsDict valueForKey:@"toEmail"]);
    }
    else
    {
        // first time through, so copy the presets from the constants.h, rinse and repeat:
        [self setSettingsDefaults];
    }
}

- (void) setSettingsDefaults
{
    NSLog(@"----------->>>> first time through: setSettingsDefaults: ");
    // this took a long time to spot:
    // segment controller defaults to 'on' from the storyboard
    Settings *inserterDefaultSettings = [NSEntityDescription insertNewObjectForEntityForName:@"Settings" inManagedObjectContext:managedObjectContext];
    [inserterDefaultSettings setToEmail:EMAILTO];
    [settingsDict setValue:EMAILTO forKey:@"toEmail"];
    [inserterDefaultSettings setFromEmail:EMAILFROM];
    [inserterDefaultSettings setSmtpServer:SMTPSERVER];
    [settingsDict setValue:SMTPSERVER forKey:@"smtpServer"];
    [inserterDefaultSettings setSmtpPasswd:SMTPPASSWD];
    [settingsDict setValue:SMTPPASSWD forKey:@"smtpPasswd"];
    [inserterDefaultSettings setWolIP:WOLIP];
    [settingsDict setValue:WOLIP forKey:@"wolIP"];
    [inserterDefaultSettings setGeoFenceMonitoring:[NSNumber numberWithBool:TRUE] ];
    // NOTE: not setting a default for monitoring - need to figure out how to switch it off!
    [inserterDefaultSettings setMACforWolIp:DEFAULTMAC];
    [settingsDict setValue:DEFAULTMAC forKey:@"mACforWolIp"];
    [settingsDict setValue:DEFAULTFORSIGCHANGEFN forKey:@"sigChangeFnBool"];
    NSError *error = nil;
    [managedObjectContext save:&error];
}

// notification experiement:

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notifcnAcked" object:nil];
}

- (void) notifcnAcked
{
    NSLog(@"notifcnAcked: OK pressed in notification");
}

- (id)fetchSSIDInfo
{
    NSArray *ifs = (__bridge id)CNCopySupportedInterfaces();
    NSLog(@"%s: Supported interfaces: %@", __func__, ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%s: %@ => %@", __func__, ifnam, info);
        if (info && [info count]) {
            break;
        }
    }
    return info ;
}

- (void)fetchedData:(NSData *)responseData
{
    // read the current list of stored google hits. Will test for duplicates before
    // saving new results:
    NSLog(@"fetchedData");
    NSArray *allGoogHits = [[NSArray alloc] init];
    NSFetchRequest *googFetch = [[NSFetchRequest alloc] init];
    [googFetch setEntity:[NSEntityDescription entityForName:@"GooglePlaceResults" inManagedObjectContext:managedObjectContext]];
    
    [googFetch setIncludesPropertyValues:NO];
    NSError *readError = nil;
    allGoogHits = [managedObjectContext executeFetchRequest:googFetch error:&readError];
    NSMutableArray *allLoggedGoogNames = [[NSMutableArray alloc] init];
    for (GooglePlaceResults *oneGoogHit in allGoogHits)
    {
        NSString *tmpName = oneGoogHit.locationName;
        [allLoggedGoogNames addObject:tmpName];
    }
    NSError* googError;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData //1
                          
                          options:kNilOptions
                          error:&googError];
    NSLog(@"json error: %@", googError);
    //NSLog(@"json: %@", json);
    googleHitCount = 0;
    for (NSDictionary *result in [json objectForKey:@"results"])
    {
        // so search the array of current data for the current bar name
        NSString *barName = [result objectForKey:@"name"];
        // problem with the quote marks around the result name so....
        //NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"'%@'", barName]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF = %@", barName];
        NSLog(@"got %@ already?", barName);
        NSArray *matchingNames = [allLoggedGoogNames filteredArrayUsingPredicate:predicate];
        // a zero length array of results means no hit: it's new:
        if ([matchingNames count]==0)
        {
            NSLog(@"I think it's new!");
            GooglePlaceResults *resultsToAdd = [NSEntityDescription insertNewObjectForEntityForName:@"GooglePlaceResults" inManagedObjectContext:managedObjectContext];
            [resultsToAdd setLocationDate:[NSDate date]];

            [resultsToAdd setLocationName:barName];
            NSDictionary *location = [[result objectForKey:@"geometry"] objectForKey:@"location"];
            NSNumber *latitude = [[NSNumber alloc] initWithFloat:[[location objectForKey:@"lat"] floatValue]];
            NSNumber *longitude = [[NSNumber alloc] initWithFloat:[[location objectForKey:@"lng"] floatValue]];
            [resultsToAdd setLocationLat:latitude];
            [resultsToAdd setLocationLong:longitude];
            NSLog(@"pub is called %@", barName);
            NSLog(@"lat is %f", [latitude floatValue]);
            NSLog(@"long is %f", [longitude floatValue]);
            googleHitCount++;
        } else {
            NSLog(@"Nope, got %@ already", barName);
        }
    }
    [managedObjectContext save:nil];
    // This is temporary. This gets called on a separate thread, so should return the notification a few seconds after
    // the initial significant change popup:
    NSString *bodyString = [NSString stringWithFormat:@"Google just returned %i results", googleHitCount];
    UILocalNotification *googNotification = [[UILocalNotification alloc] init];
    googNotification.alertBody = bodyString;
    googNotification.timeZone = [NSTimeZone defaultTimeZone];
    googNotification.fireDate = [NSDate date];
    UIApplication* app = [UIApplication sharedApplication];
    [app scheduleLocalNotification:googNotification];
}

@end
