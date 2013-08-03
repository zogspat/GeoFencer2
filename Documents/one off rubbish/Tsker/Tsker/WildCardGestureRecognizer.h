//
//  WildCardGestureRecognizer.h
//  Tsker
//
//  Created by Donal Hanna on 29/05/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TouchesEventBlock)(NSSet *touches, UIEvent *event);

@interface WildCardGestureRecognizer : UIGestureRecognizer
{
    //TouchesEventBlock touchesBeganCallback;
    BOOL weGotAHit;
}

//@property(copy) TouchesEventBlock touchesBeganCallback;

-(BOOL) baZinga;

@end
