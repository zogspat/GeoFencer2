//
//  ManageData.h
//  Tsker
//
//  Created by Donal Hanna on 31/07/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatabaseHelper.h"
#import "SignificantChange.h"
#import "GooglePlaceResults.h"

@interface ManageData : UIViewController
- (IBAction)zapGoogleData:(id)sender;
- (IBAction)zapSigChangeData:(id)sender;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
