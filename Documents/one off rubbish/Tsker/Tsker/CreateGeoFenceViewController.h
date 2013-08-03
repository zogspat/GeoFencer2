//
//  CreateGeoFenceViewController.h
//  Tsker
//
//  Created by Donal Hanna on 01/06/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatabaseHelper.h"
#import "GeoFence.h"
#import "GeoWallData.h"
#import "ScratchFence.h"


@interface CreateGeoFenceViewController : UIViewController <UITextFieldDelegate, CLLocationManagerDelegate>

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property BOOL setFenceLocationRadiusDone;
@property BOOL setNameDone;
@property BOOL setActionDone;
@property GeoWallData *geoFenceInstance;
@property ScratchFence *scratchDataForCurrentFence;
- (IBAction)setNameForFence:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *fenceNameTextField;
- (IBAction)savePressed:(id)sender;
@property (nonatomic, retain) NSString *nameInputToTextField;

@end
