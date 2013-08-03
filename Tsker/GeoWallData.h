//
//  GeoWallData.h
//  Tsker
//
//  Created by Donal Hanna on 28/05/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface GeoWallData : NSObject


@property (strong, nonatomic) NSDate *wallDate;
//@property (strong, nonatomic) CLRegion *wallRegion;
@property (strong, nonatomic) NSString *wallAction;
@property (strong, nonatomic) NSString *wallEmail;
// not sure about this data type:
@property (strong, nonatomic) NSString *wallIPAddress;
@property  NSNumber *wallLat;
@property NSNumber *wallLong;
@property int wallRadius;
@property (strong, nonatomic) NSString *wallName;

- (id) initWithWallData: (NSDate *)wallDateData wallLat:(NSNumber *)wallLatData wallLong:(NSNumber *)wallLongData wallRadius:(int)wallRadiusData wallEmail:(NSString *)wallEmailData wallIPAddress:(NSString *)wallIPAddressData wallAction:(NSString *)wallActionData wallName:(NSString *)wallNameData;

//- (id) initFromPlist;


@end
