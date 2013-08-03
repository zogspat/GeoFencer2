//
//  ArpFunctionality.m
//  Tsker
//
//  Created by Donal Hanna on 20/07/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//

#import "ArpFunctionality.h"

@implementation ArpFunctionality

-(id) init
{
    self = [super init];
    if (self)
    {
        
    }
    return  self;
}

- (NSArray *)convertMACStringToIntArray:(NSString *)inMACString
{
    NSArray *tmpMacBitsAsStrings = [inMACString componentsSeparatedByString:@":"];
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    for( NSString *eachString in tmpMacBitsAsStrings )
    {
        unsigned tmpInt = 0;
        NSScanner *scanner = [NSScanner scannerWithString:eachString];
        [scanner scanHexInt:&tmpInt];
        NSLog(@"result is %i", tmpInt);
        NSNumber *newNumber = [[NSNumber alloc] initWithInt:tmpInt];
        [newArray addObject:newNumber];
        
    }
    return newArray;
}

- (void) sendWoLPacket:(NSArray *)macPartsAsInts inputIP:(NSString *)targetIP
{
    //http://shadesfgray.wordpress.com/2010/12/17/wake-on-lan-how-to-tutorial/
    
    unsigned char tosend[102];
    unsigned char mac[6];
    
    for(int i = 0; i < 6; i++)
    {
        tosend[i] = 0xff;
    }
    mac[0] = [macPartsAsInts[0] integerValue];
    mac[1] = [macPartsAsInts[1] integerValue];
    mac[2] = [macPartsAsInts[2] integerValue];
    mac[3] = [macPartsAsInts[3] integerValue];
    mac[4] = [macPartsAsInts[4] integerValue];
    mac[5] = [macPartsAsInts[5] integerValue];
    
    
    
    NSLog(@"macPartsAsInts: %@", macPartsAsInts);
    
    
    for(int i = 1; i <= 16; i++)
    {
        // don't think this is right:
        memcpy(&tosend[i * 6], &mac, 6 * sizeof(unsigned char));
        //memcpy(&tosend, &mac, 6 * sizeof(unsigned char));
    }
    GCDAsyncUdpSocket *mysocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    //NSData  *payload = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSData *payLoad = [NSData dataWithBytes:tosend length:102];
    [mysocket sendData:payLoad toHost:targetIP port:9 withTimeout:-1 tag:0];
}


@end
