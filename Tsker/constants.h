//
//  constants.h
//  Tsker
//
//  Created by Donal Hanna on 10/06/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//

// this will eventually go somewhere like a plist or config file.

#import <Foundation/Foundation.h>

@interface constants : NSObject

// Email settings. Note currently the value for SSL is hardwired into the code.
// Email functionality used in AppDelegate and SettingsViewController:
#define EMAILFROM @"yourFromEmail@domain.com"
#define EMAILTO @"yourToEmail@domain.com"
#define EMAILBODY @"...and all is well!"

#define SMTPSERVER @"your.smtp.server.com"
#define SMTPPASSWD @"yourPassword"

// On the to-do list: currently, only a single registered MAC/IP is applied to all of the
// CLRegions that are registered for Wake On LAN. Ideally, it would be good to have the option to
// to choose from a list of IP/MACs. This has UI implications.
#define FENCETARGETIP @"blank"
// passing a well formatted but non existing address into ip2mac will cause a runtime error
#define WOLIP @"dummy"

#define DEFAULTMAC @"00:00:00:00:00:00"

// Disables local notifications, logging to core data [viewed as on map annotations], google functionality etc
// in didUpdateToLocation and didExitRegion. Also determines whether didEnterRegion is logged to core data.
// Suggest this is left to TRUE for debugging:
#define DEFAULTFORSIGCHANGEFN @"TRUE"

//////////////////////////////////////////////////////////////////////////////////
// Everything below here not currently editable in the SettingsViewController:  //
//////////////////////////////////////////////////////////////////////////////////

// As per earlier comment: not currently implemented. Hardwired non-use of SSL for email. This should be used
// in both the AppDelegate, and in the SettingsViewController
#define SMTPSSL @"ON"

// radii for Region creation. These set the sizes in the mapview segment and
// subsequently in the CLRegion:
#define SMALL_RADIUS 25
#define MEDIUM_RADIUS 100
#define LARGE_RADIUS 500

// if DEFAULTFORSIGCHANGEFN is TRUE, this needs to have a real value:
#define GOOGLEAPIKEY @"youGooglePlacesAPIKey"

// As per earlier comments, we only support a single for Wake On LAN functionality:
#define HOMENETWORKSSID @"CaseSensitiveNetworkSSID"


@end
