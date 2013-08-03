//
//  CreateGeoFenceViewController.m
//  Tsker
//
//  Created by Donal Hanna on 01/06/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//

// setaction is going to default to true for now

#import "CreateGeoFenceViewController.h"
#import "constants.h"

@interface CreateGeoFenceViewController ()

@end

@implementation CreateGeoFenceViewController
@synthesize managedObjectContext;
@synthesize setFenceLocationRadiusDone;
@synthesize setNameDone;
@synthesize geoFenceInstance;
@synthesize scratchDataForCurrentFence;
@synthesize setActionDone;
@synthesize nameInputToTextField;

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
    _fenceNameTextField.text = @"";
    setFenceLocationRadiusDone = FALSE;
    setNameDone = FALSE;
    // just for now.......................
    setActionDone = TRUE;
    NSFetchRequest *allScratches = [[NSFetchRequest alloc] init];
    [allScratches setEntity:[NSEntityDescription entityForName:@"ScratchFence" inManagedObjectContext:managedObjectContext]];
    geoFenceInstance = [[GeoWallData alloc] initWithWallData:[NSDate date] wallLat:0 wallLong:0 wallRadius:0 wallEmail:@"" wallIPAddress:@"" wallAction:@"" wallName:@""];
    [allScratches setIncludesPropertyValues:NO];
    NSError *error = nil;
    NSArray *scratches = [managedObjectContext executeFetchRequest:allScratches error:&error];
    NSLog(@"scratch data has %i records", [scratches count]);
    if ([scratches count] == 1)
    {
        NSString *tmpDescrn = [scratches[0] description];
        NSLog(@"%@", tmpDescrn);
        setFenceLocationRadiusDone = TRUE;

        scratchDataForCurrentFence = scratches[0];

        NSNumber *verytmp = scratchDataForCurrentFence.latitude;
        NSLog(@"just in case: %f", [verytmp floatValue]);
        
        //NSLog(scratches[0]);
        geoFenceInstance.wallDate = scratchDataForCurrentFence.date;
        geoFenceInstance.wallLat = scratchDataForCurrentFence.latitude;
        geoFenceInstance.wallLong = scratchDataForCurrentFence.longitude;
        geoFenceInstance.wallRadius = [scratchDataForCurrentFence.radius integerValue];
        NSLog(@"Lat is %@", scratchDataForCurrentFence.latitude);
        geoFenceInstance.wallLat = scratchDataForCurrentFence.latitude;
        NSLog(@"Is it still...? %@", geoFenceInstance.wallLat);
        NSLog(@"--> and the radius is %i", geoFenceInstance.wallRadius);
    }
}


- (void)viewDidLoad
{
    
    // just examples of setting data. will probably zap all of viewdidload
    [super viewDidLoad];
    managedObjectContext = [[DatabaseHelper sharedInstance] managedObjectContext];
//	// Do any additional setup after loading the view.
//    NSMutableArray *fenceNames = [[NSMutableArray alloc] init];
//    [fenceNames addObject:@"Work"];
//    [fenceNames addObject:@"Home"];
//    [fenceNames addObject:@"En route"];
//    NSNumber *tmpRadius = [[NSNumber alloc] initWithInt:150];
//    
//    for (NSString *arryValueName in fenceNames)
//    {
//        GeoFence *fence = (GeoFence *) [NSEntityDescription insertNewObjectForEntityForName:@"GeoFence" inManagedObjectContext:managedObjectContext];
//        [fence setName:arryValueName];
//        [fence setRadius:tmpRadius];
//    }
//    
//    NSMutableArray *result = [[NSMutableArray alloc] init];
//    result = [self fetchArrayFromDBWithEntity:@"GeoFence" forKey:@"name" withPredicate:nil];
//    
//    for (GeoFence *fence in result) {
//        NSLog(@"%@; %@", [fence name], [fence radius]);
//    }

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)setNameForFence:(id)sender
{
    BOOL nameInputMatchesExisting = FALSE;
    nameInputToTextField = _fenceNameTextField.text;
    NSLog(@"setNameForFence %@", _fenceNameTextField.text);
    NSError *error = nil;
    NSFetchRequest *allFences = [[NSFetchRequest alloc] init];
    [allFences setEntity:[NSEntityDescription entityForName:@"GeoFence" inManagedObjectContext:managedObjectContext]];
    
    [allFences setIncludesPropertyValues:NO];
    NSArray *allFenceDataArray = [managedObjectContext executeFetchRequest:allFences error:&error];
    
    NSLog(@"geofenace data has %i records", [allFenceDataArray count]);
    // there is something wrong wit this:
//    NSFetchRequest *hallFences = [[NSFetchRequest alloc] init];
//    NSArray *allFenceDataArray = [managedObjectContext executeFetchRequest:hallFences error:&error];
//    
    for (GeoFence *tmpFence in allFenceDataArray)
    {
        
        if ([tmpFence.name isEqualToString:nameInputToTextField])
        {
            NSLog(@"got a dupe");
            nameInputMatchesExisting = TRUE;
        }
    }

    if (nameInputMatchesExisting)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh-Oh!!"
                                                        message:@"The names need to be unique, as that's how you'll manage them later. Show some imagination"
                                                       delegate: nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else if (! [nameInputToTextField isEqualToString:@""])
    {
        NSLog(@"You put something in there");
        setNameDone = TRUE;
    }
    else
    {
        NSLog(@"blank");
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}



- (IBAction)savePressed:(id)sender
{
    NSLog(@"save pressed");
    // want to validate that all data is set for this geofence. Then check that we
    // haven't hit the maximum number of fences [10]
    if (setNameDone && setFenceLocationRadiusDone && setActionDone)
    {
        // check number of records
        // what about uniqueness?
        NSFetchRequest *allFences = [[NSFetchRequest alloc] init];
        [allFences setEntity:[NSEntityDescription entityForName:@"GeoFence" inManagedObjectContext:managedObjectContext]];

        [allFences setIncludesPropertyValues:NO];
        NSError *error = nil;
        NSArray *allFenceDataArray = [managedObjectContext executeFetchRequest:allFences error:&error];

        NSLog(@"geofenace data has %i records", [allFenceDataArray count]);
        if ([allFenceDataArray count] >= 10)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh-Oh!!"
                                                            message:@"Max Geofences is 10. Delete one before saving a new one, you feckless gobsheen"
                                                           delegate: nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            // save the new geofence data - and create it????
            GeoFence *newFenceToInsert = [NSEntityDescription insertNewObjectForEntityForName:@"GeoFence" inManagedObjectContext:managedObjectContext];
            [newFenceToInsert setName:_fenceNameTextField.text];
            [newFenceToInsert setRadius:scratchDataForCurrentFence.radius];
            [newFenceToInsert setLatitude:scratchDataForCurrentFence.latitude];
            [newFenceToInsert setLongitude:scratchDataForCurrentFence.longitude];
            [newFenceToInsert setAction:FENCEACTION];
            [newFenceToInsert setEmail:EMAILTO];
            [newFenceToInsert setDate:scratchDataForCurrentFence.date];
            [newFenceToInsert setTargetIP:FENCETARGETIP];
            // I think this persists between runs etc
            [managedObjectContext save:nil];
            NSLog(@"====>>> Updated with new geofence");
            // confirm save; remove scratch; update _fenceNameTextField.text:
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
            
            NSString *confirmString =[@"Saved geofence " stringByAppendingString:_fenceNameTextField.text];
            _fenceNameTextField.text = @"";
            
            // before confirming, create the region:
            CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake([scratchDataForCurrentFence.latitude floatValue], [scratchDataForCurrentFence.longitude floatValue]);
            CLRegion *tmpRegion = [[CLRegion alloc] initCircularRegionWithCenter:coordinates radius:[scratchDataForCurrentFence.radius floatValue] identifier:nameInputToTextField];
            CLLocationManager *locationManager = [[CLLocationManager alloc] init];
            [locationManager setDelegate:self];
            [CLLocationManager regionMonitoringAvailable];
            // may not need to do this but...
            [locationManager startMonitoringSignificantLocationChanges];
            [locationManager startMonitoringForRegion:tmpRegion];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Done!"
                                                            message:confirmString
                                                           delegate: nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh-Oh!!"
                                                        message:@"Set location details, actions, and a name for the geofence"
                                                       delegate: nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
}
@end
