//
//  MyAnnotation.m
//  Tsker
//
//  Created by Donal Hanna on 29/05/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//

#import "MyAnnotation.h"

@implementation MyAnnotation
@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
//@synthesize annoType;
//@synthesize pinColor;

//- (NSString *)subtitle{
//    return nil;
//}

//- (NSString *)title{
//    return nil;
//}

// need to figure this stuff out one day. The title and subtitle work just as props.

-(id)initWithCoordinate:(CLLocationCoordinate2D)coord {
    coordinate=coord;
    return self;
}

-(CLLocationCoordinate2D)coord
{
    return coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    coordinate = newCoordinate;
}

@end