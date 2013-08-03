//
//  GeoWallData.m
//  Tsker
//
//  Created by Donal Hanna on 28/05/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//

#import "GeoWallData.h"

@interface GeoWallData ()

@end

@implementation GeoWallData

@synthesize wallDate;
@synthesize wallLat;
@synthesize wallLong;
@synthesize wallEmail;
@synthesize wallIPAddress;
@synthesize wallAction;
@synthesize wallName;
@synthesize wallRadius;

- (id) initWithWallData:(NSDate *)wallDateData wallLat:(NSNumber *)wallLatData wallLong:(NSNumber *)wallLongData wallRadius:(int)wallRadiusData wallEmail:(NSString *)wallEmailData wallIPAddress:(NSString *)wallIPAddressData wallAction:(NSString *)wallActionData wallName:(NSString *)wallNameData
{
    
    if (self = [super init])
    {
        self.wallDate = wallDateData;
        self.wallLat = wallLatData;
        self.wallLong = wallLongData;
        self.wallRadius = wallRadiusData;
        self.wallEmail = wallEmailData;
        self.wallIPAddress = wallIPAddressData;
        self.wallAction = wallActionData;
        self.wallName = wallNameData;
    }
    
    return self;
}


@end
