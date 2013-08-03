//
//  WildCardGestureRecognizer.m
//  Tsker
//
//  Created by Donal Hanna on 29/05/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//

#import "WildCardGestureRecognizer.h"

@implementation WildCardGestureRecognizer

//@synthesize touchesBeganCallback;

-(id) init
{
    if (self = [super init])
    {
        weGotAHit = FALSE;
        self.cancelsTouchesInView = NO;
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    if (touchesBeganCallback)
//        touchesBeganCallback(touches, event);
    //NSLog(@"touchesBegan");
    weGotAHit = TRUE;
}

-(void)touchesCancelled:(NSSet * ) touches withEvent:(UIEvent *)event
{
    //NSLog(@"touchesCancelled");
}

-(void) touchesEnded:(NSSet *) touches withEvent:(UIEvent *)event
{
    //NSLog(@"touchesEnded");
}

-(void) touchesMoved:(NSSet *) touches withEvent:(UIEvent *)event
{
    //NSLog(@"touchesMoved");
    weGotAHit = TRUE;
}

-(void) reset
{
    
}

-(void) ignoreTouch:(UITouch *) touch forEvent:(UIEvent *)event
{
    NSLog(@"ignoreTouch");
}

- (BOOL) canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
    //NSLog(@"canBePreventedByGestureRecognizer");
    return NO;
}

-(BOOL) canPreventGestureRecognizer:(UIGestureRecognizer *)preventGestureRecognizer
{
    //NSLog(@"canPreventGestureRecognizer");
    return  NO;
}

- (BOOL) baZinga
{
    return weGotAHit;
}


@end
