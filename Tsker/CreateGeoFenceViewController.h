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
#import "SignificantChange.h"
#import "ActionPickerViewController.h"

// protocols and delegates: don't forget the bobseguer!!

@interface CreateGeoFenceViewController : UIViewController <UITextFieldDelegate, CLLocationManagerDelegate, actionPickerDelegate>


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

@property (nonatomic, retain) NSString *inputFromActionPicker;
@property BOOL segueBeenUsed;

// "Dynamic" label for the set Action button:
// don't think we synthesize this:
@property(retain) IBOutlet UIButton *setActionButtonLabel;

@end
