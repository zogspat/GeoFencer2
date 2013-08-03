//
//  ManageData.m
//  Tsker
//
//  Created by Donal Hanna on 31/07/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//

#import "ManageData.h"

@interface ManageData ()

@end

@implementation ManageData

@synthesize managedObjectContext;

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

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)zapGoogleData:(id)sender
{
    NSLog(@"zapGoogleData");
    UIAlertView *resetGoog = [[UIAlertView alloc] initWithTitle:@"Delete all Google Places data?"
                                                         message:@"This cannot be undone"
                                                        delegate: self
                                               cancelButtonTitle:@"cancel"
                                               otherButtonTitles:@"ok", nil];
    [resetGoog show];
}

- (IBAction)zapSigChangeData:(id)sender
{
    NSLog(@"zapSigChangeData");
    UIAlertView *resetSigChange = [[UIAlertView alloc] initWithTitle:@"Delete all significant location change data?"
                                                         message:@"This cannot be undone"
                                                        delegate: self
                                               cancelButtonTitle:@"cancel"
                                               otherButtonTitles:@"ok", nil];
    [resetSigChange show];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    //NSString *tmpTitleString =@ "Delete all historic data?";
    if ([alertView.title isEqualToString: @"Delete all Google Places data?"])
    { 
        if (buttonIndex == 0)
        {
            NSLog(@"Cancelling: buttonIndex: %i", buttonIndex);
        }
        
        else
        {
            NSLog(@"zapping google data here");
            managedObjectContext = [[DatabaseHelper sharedInstance] managedObjectContext];
            NSFetchRequest *allGoogData = [[NSFetchRequest alloc] init];
            [allGoogData setEntity:[NSEntityDescription entityForName:@"GooglePlacesResult" inManagedObjectContext:managedObjectContext]];
            NSError *error = nil;
            [allGoogData setIncludesPropertyValues:NO];
            NSArray *allGoogDataArray = [[NSArray alloc] init];
            allGoogDataArray = [managedObjectContext executeFetchRequest:allGoogData error:&error];
            for (GooglePlaceResults *tmpChange in allGoogDataArray)
            {
                [managedObjectContext deleteObject:tmpChange];
            }
            [managedObjectContext save:nil];
        }
    }
    else if ([alertView.title isEqualToString: @"Delete all significant location change data?"])
    {
        if (buttonIndex == 0)
        {
            NSLog(@"Cancelling: buttonIndex: %i", buttonIndex);
        }
        
        else
        {
            NSLog(@"zapping sig change data here");
            managedObjectContext = [[DatabaseHelper sharedInstance] managedObjectContext];
            NSFetchRequest *allChangeData = [[NSFetchRequest alloc] init];
            [allChangeData setEntity:[NSEntityDescription entityForName:@"SignificantChange" inManagedObjectContext:managedObjectContext]];
            NSError *error = nil;
            [allChangeData setIncludesPropertyValues:NO];
            NSArray *allSigChangeDataArray = [[NSArray alloc] init];
            allSigChangeDataArray = [managedObjectContext executeFetchRequest:allChangeData error:&error];
            for (SignificantChange *tmpChange in allSigChangeDataArray)
            {
                [managedObjectContext deleteObject:tmpChange];
            }
            [managedObjectContext save:nil];

            //            for (SignificantChange *tmpChange in allSigChangeDataArray)
            //            {
            //                [managedObjectContext deleteObject:tmpChange];
            //            }
            //            [managedObjectContext save:nil];
            //            allSigChangeDataArray = nil;
            //            sigChangeCount = 0;
            //
            //            [_zapOutlet setTitle:[NSString stringWithFormat:@"Zap sig change records [%i]", sigChangeCount] forState:UIControlStateNormal];
        }
    }
}


@end
