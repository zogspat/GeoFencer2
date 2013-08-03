//
//  ArpFunctionality.h
//  Tsker
//
//  Created by Donal Hanna on 20/07/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//

#import <Foundation/Foundation.h>
// for arp: http://stackoverflow.com/questions/2258172/how-do-i-query-the-arp-table-on-iphone

// Tidied this up for use in the appdelegate.

#include <sys/param.h>
#include <sys/file.h>
#include <sys/socket.h>
#include <sys/sysctl.h>

#include <net/if.h>
#include <net/if_dl.h>
#include "if_types.h"
#include "route.h"
#include "if_ether.h"
#include <netinet/in.h>

#include <arpa/inet.h>

#include <err.h>
#include <errno.h>
#include <netdb.h>

#include <paths.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
// end of arp

#import "GCDAsyncUdpSocket.h"

@interface ArpFunctionality : NSObject

- (NSArray *)convertMACStringToIntArray:(NSString *)inMACString;
- (void) sendWoLPacket:(NSArray *)macPartsAsInts inputIP:(NSString *)targetIP;

@end
