//
//  ManageAllGeoFences.h
//  Tsker
//
//  Created by Donal Hanna on 10/06/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatabaseHelper.h"
#import "GeoFence.h"
#import "GeoWallData.h"

@interface ManageAllGeoFences : UITableViewController

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSArray *allFenceDataArray;
@property GeoFence *geoFenceInstance;

@end
