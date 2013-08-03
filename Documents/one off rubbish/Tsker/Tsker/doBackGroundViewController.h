//
//  doBackGroundViewController.h
//  Tsker
//
//  Created by Donal Hanna on 23/05/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCLController.h"


@interface doBackGroundViewController : UIViewController
{
    MyCLController *locationController;
    UILocalNotification *localNotification;
    
    // reaaaallly not sure about this:
    // from http://timroadley.com/2012/02/12/core-data-basics-part-2-core-data-views/
    // AppDelegate should usually pass a Managed Object Context to the initial view controller. 
    //NSManagedObjectContext *moc;
    NSManagedObjectContext *managedObjectContext;
}
- (IBAction)doNotify:(id)sender;



@end
