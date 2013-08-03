//
//  doBackGroundViewController.h
//  Tsker
//
//  Created by Donal Hanna on 23/05/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCLController.h"
#import "DatabaseHelper.h"
#import "SignificantChange.h"
#import "GCDAsyncUdpSocket.h"
#import "GooglePlaceResults.h"

@interface doBackGroundViewController : UIViewController
{
    MyCLController *locationController;
    UILocalNotification *localNotification;
    //GCDAsyncUdpSocket *socket;
    
    // reaaaallly not sure about this:
    // from http://timroadley.com/2012/02/12/core-data-basics-part-2-core-data-views/
    // AppDelegate should usually pass a Managed Object Context to the initial view controller. 
    //NSManagedObjectContext *moc;
    //NSManagedObjectContext *managedObjectContext;
}

//@property(retain) IBOutlet UIButton *googHitsCountOutlet;
@property (strong, nonatomic) IBOutlet UILabel *geoFenceTotalLabel;

@property (strong, nonatomic) IBOutlet UILabel *googleEventsTotalLabel;
@property (strong, nonatomic) IBOutlet UILabel *sigChangeEventsLabel;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSArray *allSigChangeDataArray;

@property int sigChangeCount;
@property int googHitsCount;
@property int geoFenceTotalCount;


@end
