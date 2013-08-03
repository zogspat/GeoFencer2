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

// ok, going to try to keep these types quite primitive, based on 'proximity' to the
// types supported natively by the plist. Might have the load from plist implemented
// as a separate class, which, say returns an array of loaded objects.
// No, changed my mind. Back to the high level suff:

// and back again. Nothing to be gained as ultimately when this is passed back to the view, it
// will be as primitives like lat and long for saving out.

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
