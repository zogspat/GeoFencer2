//
//  MyAnnotation.h
//  Tsker
//
//  Created by Donal Hanna on 29/05/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MyAnnotation : NSObject <MKAnnotation>
{
    
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
    //NSString *annoType;
    //MKPinAnnotationColor *pinColor;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
//@property (nonatomic, copy) NSString *annoType;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord;
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;
@end