//
//  ScratchFence.h
//  Tsker
//
//  Created by Donal Hanna on 02/06/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ScratchFence : NSManagedObject

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * radius;

@end
