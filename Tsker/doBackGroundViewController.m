//
//  doBackGroundViewController.m
//  Tsker
//
//  Created by Donal Hanna on 23/05/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//

#import "doBackGroundViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MessageUI.h>
#import "MyCLController.h"

@interface doBackGroundViewController ()

@end

@implementation doBackGroundViewController

//@synthesize moc;
@synthesize managedObjectContext;
@synthesize sigChangeCount;
@synthesize allSigChangeDataArray;
@synthesize googHitsCount;
@synthesize geoFenceTotalCount;

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
    sigChangeCount = 0;
    allSigChangeDataArray = [[NSArray alloc] init];
    localNotification = [[UILocalNotification alloc] init];
    [UIApplication sharedApplication].applicationIconBadgeNumber=0;
    //localNotification.applicationIconBadgeNumber = -1;
    NSLog(@"viewWillAppear: dobackgroundvc");
    managedObjectContext = [[DatabaseHelper sharedInstance] managedObjectContext];
    
    NSFetchRequest *allChangeData = [[NSFetchRequest alloc] init];
    [allChangeData setEntity:[NSEntityDescription entityForName:@"SignificantChange" inManagedObjectContext:managedObjectContext]];
    [allChangeData setIncludesPropertyValues:NO];
    NSError *error = nil;
    allSigChangeDataArray = [managedObjectContext executeFetchRequest:allChangeData error:&error];
    sigChangeCount = [allSigChangeDataArray count];
    _sigChangeEventsLabel.text =  [NSString stringWithFormat:@"Significant Change events: %i", sigChangeCount];
    
    NSArray *allGoogHits = [[NSArray alloc] init];
    NSFetchRequest *googFetch = [[NSFetchRequest alloc] init];
    [googFetch setEntity:[NSEntityDescription entityForName:@"GooglePlaceResults" inManagedObjectContext:managedObjectContext]];
    [googFetch setIncludesPropertyValues:NO];
    NSError *readError = nil;
    allGoogHits = [managedObjectContext executeFetchRequest:googFetch error:&readError];
    googHitsCount = [allGoogHits count];
    _googleEventsTotalLabel.text =[NSString stringWithFormat:@"Google Hits: %i", googHitsCount] ;
    
    NSArray *allGeoFences = [[NSArray alloc] init];
    NSFetchRequest *fenceFetch = [[NSFetchRequest alloc] init];
    [fenceFetch setEntity:[NSEntityDescription entityForName:@"GeoFence" inManagedObjectContext:managedObjectContext]];
    [fenceFetch setIncludesPropertyValues:NO];
    NSError *fenceError = nil;
    allGeoFences = [managedObjectContext executeFetchRequest:fenceFetch error:&fenceError];
    geoFenceTotalCount = [allGeoFences count];
    _geoFenceTotalLabel.text = [NSString stringWithFormat:@"GeoFences set: %i", geoFenceTotalCount] ;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//
//- (IBAction)zapEphemRecsBtn:(id)sender
//{
//    
//    UIAlertView *resetEphem = [[UIAlertView alloc] initWithTitle:@"Delete all ephemeral data?"
//                                                               message:@"This cannot be undone"
//                                                              delegate: self
//                                                     cancelButtonTitle:@"cancel"
//                                                     otherButtonTitles:@"ok", nil];
//    [resetEphem show];
//}
//



-(NSString*) nSDataToHex:(NSData*)data
{
    const unsigned char *dbytes = [data bytes];
    NSMutableString *hexStr =
    [NSMutableString stringWithCapacity:[data length]*2];
    int i;
    for (i = 0; i < [data length]; i++) {
        [hexStr appendFormat:@"%02x ", dbytes[i]];
    }
    return [NSString stringWithString: hexStr];
}

//-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    
//    //NSString *tmpTitleString =@ "Delete all historic data?";
//    if ([alertView.title isEqualToString: @"Delete all ephemeral data?"])
//    {
//        if (buttonIndex == 0)
//        {
//            NSLog(@"Cancelling: buttonIndex: %i", buttonIndex);
//        }
//        
//        else
//        {
//            NSLog(@"zapping for real");
//            for (SignificantChange *tmpChange in allSigChangeDataArray)
//            {
//                [managedObjectContext deleteObject:tmpChange];
//            }
//            [managedObjectContext save:nil];
//            allSigChangeDataArray = nil;
//            sigChangeCount = 0;
//            
//            [_zapOutlet setTitle:[NSString stringWithFormat:@"Zap sig change records [%i]", sigChangeCount] forState:UIControlStateNormal];
//        }
//    }
//}


@end
