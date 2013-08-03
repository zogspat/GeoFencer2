//
//  doBackGroundViewController.m
//  Tsker
//
//  Created by Donal Hanna on 23/05/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//

#import "doBackGroundViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MessageUI.h>
#import "MyCLController.h"
@interface doBackGroundViewController ()

@end

@implementation doBackGroundViewController

//@synthesize moc;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    localNotification = [[UILocalNotification alloc] init];
    [UIApplication sharedApplication].applicationIconBadgeNumber=0;
    //localNotification.applicationIconBadgeNumber = -1;
    NSLog(@"lookie her ma");
    locationController = [[MyCLController alloc] init];
    [locationController.locationManager startUpdatingLocation];
    
    
    
	// Do any additional setup after loading the view.
//    NSDate *d = [NSDate dateWithTimeIntervalSinceNow: 10.0];
//    NSTimer *t = [[NSTimer alloc] initWithFireDate: d
//                                          interval: 1
//                                            target: self
//                                          selector:@selector(onTick:)
//                                          userInfo:nil repeats:YES];
//    
//    NSRunLoop *runner = [NSRunLoop currentRunLoop];
//    [runner addTimer:t forMode: NSDefaultRunLoopMode];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)onTick:(NSTimer *)timer {
    //do smth
    NSLog(@"heartbeat, whoy do yawoo skip?");
}


- (IBAction)doNotify:(id)sender
{
    UIApplication* app = [UIApplication sharedApplication];
    NSLog(@"I'm down here");
    NSDate *alertTime = [[NSDate date] dateByAddingTimeInterval:2];
    localNotification = [[UILocalNotification alloc] init];
    //NSString *tmp = locationManager.location.description;
    //CLLocation *location = [[CLLocation alloc]init];
    //NSString *tmp = location.description;
    //NSString *locnString = [NSString stringWithFormat:@"%@", [locationManager location]];
    localNotification.alertBody = @"bob";
    localNotification.alertAction = @"View";
    localNotification.fireDate = alertTime;
    localNotification.applicationIconBadgeNumber++;
    [app scheduleLocalNotification:localNotification];

}
@end
