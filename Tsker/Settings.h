//
//  Settings.h
//  Tsker
//
//  Created by Donal Hanna on 31/07/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Settings : NSManagedObject

@property (nonatomic, retain) NSString * fromEmail;
@property (nonatomic, retain) NSNumber * geoFenceMonitoring;
@property (nonatomic, retain) NSString * mACforWolIp;
@property (nonatomic, retain) NSString * smtpPasswd;
@property (nonatomic, retain) NSString * smtpServer;
@property (nonatomic, retain) NSString * toEmail;
@property (nonatomic, retain) NSString * wolIP;
@property (nonatomic, retain) NSNumber * sigChangeFnBool;

@end
