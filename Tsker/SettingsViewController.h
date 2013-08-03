//
//  SettingsViewController.h
//  Tsker
//
//  Created by Donal Hanna on 25/06/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatabaseHelper.h"
#import "Settings.h"
#import "GCDAsyncUdpSocket.h"
#import "constants.h"

// for arp: http://stackoverflow.com/questions/2258172/how-do-i-query-the-arp-table-on-iphone

// #import "ArpFunctionality.h" ******* do the tidy up for this!!!!


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

// for identifying wifi network:
#import <SystemConfiguration/CaptiveNetwork.h>
#import "ArpFunctionality.h"

@interface SettingsViewController : UIViewController <UITextFieldDelegate>
{
    // segment secret: create this by hand:
    IBOutlet UISegmentedControl *segment;
    // then the action from the storyboard.
}

- (IBAction)segmentBtnPressed:(id)sender;


// attempt at setting a default label value:
@property (strong, nonatomic) IBOutlet UITextField *toEmailDefaultLabel;
@property (strong, nonatomic) IBOutlet UITextField *fromEmailDefaultLabel;
@property (strong, nonatomic) IBOutlet UITextField *smtpServerDefaultLabel;
@property (strong, nonatomic) IBOutlet UITextField *smtpPasswdDefaultLabel;
@property (strong, nonatomic) IBOutlet UITextField *wolIPDefaultLabel;

- (IBAction)testWolBtn:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *labelForMacAdd;

- (IBAction)testEmailBtnPressed:(id)sender;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
// for results hauled back from core data:
@property (nonatomic, retain) NSArray *allCurrentSettingsArray;
// for messing in this interface:
@property (nonatomic, retain) Settings *tmpSettingVals;
// problems with init'ing tmpsettingvals so a temp array:
@property (nonatomic, retain) NSMutableArray *tmpArray;

@property (nonatomic, retain) NSString *macAddString;

@property Boolean sigChangeBool;


@end
