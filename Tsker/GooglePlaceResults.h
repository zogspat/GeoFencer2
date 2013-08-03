//
//  GooglePlaceResults.h
//  Tsker
//
//  Created by Donal Hanna on 28/07/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GooglePlaceResults : NSManagedObject

@property (nonatomic, retain) NSString * locationName;
@property (nonatomic, retain) NSNumber * locationLat;
@property (nonatomic, retain) NSNumber * locationLong;
@property (nonatomic, retain) NSDate * locationDate;
@end
