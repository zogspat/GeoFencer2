//
//  SettingsViewController.m
//  Tsker
//
//  Created by Donal Hanna on 25/06/2013.
//  Copyright (c) 2013 Donal Hanna. All rights reserved.
//
//
// "This NSPersistentStoreCoordinator has no persistent stores" - delete the sql lite database by hand from the simulator
// A full reset would probably work too.....

// a lot of sport in here. You cannot assign arbitrary values to managed object subclasses.
// anywhere below where I've done something like this:
// tmpSettingVals.toEmail = @"donal.hanna@the-plot.com";
// It's not set. REMEMBER!!!! You can only assign these from an array, it seems, and then read the vals.

// going mad: added ibactions to the text inputs didn't need them.


#import "SettingsViewController.h"
#import <MailCore/MailCore.h>

@interface SettingsViewController ()

@end

@implementation SettingsViewController
@synthesize allCurrentSettingsArray;
@synthesize managedObjectContext;
@synthesize tmpSettingVals;
@synthesize tmpArray;
@synthesize macAddString;
@synthesize sigChangeBool;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{

    NSLog(@"viewWillAppear");
    // Do any additional setup after loading the view.
    managedObjectContext = [[DatabaseHelper sharedInstance] managedObjectContext];
    allCurrentSettingsArray = [[NSArray alloc]init];
    NSFetchRequest *allSettings = [[NSFetchRequest alloc] init];
    [allSettings setEntity:[NSEntityDescription entityForName:@"Settings" inManagedObjectContext:managedObjectContext]];
    
    [allSettings setIncludesPropertyValues:NO];
    NSError *error = nil;
    allCurrentSettingsArray = [managedObjectContext executeFetchRequest:allSettings error:&error];
    NSLog(@"allCurrentSettingsArray data has %i records", [allCurrentSettingsArray count]);
    if ([allCurrentSettingsArray count] == 0)
    {
        NSLog(@"I should never get called as we set this in the app delegate");
        [self setSettingsDefaults];
    }
    else
    {
        NSLog(@"loadCurrentSettingVals: Settings array should only ever hold zero or one object: %i", [allCurrentSettingsArray count]);
        [self loadCurrentSettingVals];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// dismiss keyboard
// also need to connect each textfield to the viewcontroller and register as delegate
// the bit i always forget.
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{ 
    // Bit of a hack to try to update the UI immediately after the Mac address is found:
    if ([self isIp:textField.text])
    {
        NSLog(@"Looks like an IP address to me"); // so an edit on the WoL IP field
        // There is a reasonable chance that the IP address for the WoL target machine isn't in the arp table for the device.
        // Sending dummy [UDP, because we are doing stuff with it here] packets is enough to make sure that it is populated.
        // Tried doing this on a separate thread, but even with that the ip2mac still isn't picking up the MAC address every time.
        // Not sure why the arp cache update isn't picked up - old version of cache retained? - but going in and out of the
        // view controller works. Ugly, but works.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            GCDAsyncUdpSocket *mysocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
            [mysocket enableBroadcast:YES error:nil]; // 71
            NSData *data = [[NSString stringWithFormat:@"boing"] dataUsingEncoding:NSUTF8StringEncoding];
            for (int boingCount = 0; boingCount <= 50; boingCount ++)
            {
                [mysocket sendData:data toHost:_wolIPDefaultLabel.text port:100 withTimeout:-1 tag:0];
                NSLog(@"boing");
            }
            ; // 1
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Back from sending test packet"); // 2
                _labelForMacAdd.text = [self ip2mac:inet_addr([textField.text UTF8String])];
                if(_labelForMacAdd.text.length == 0)
                {
                    _labelForMacAdd.text =@ "No MAC for that IP";
                }
            });
        });
    }
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)segmentBtnPressed:(id)sender
{
    if (segment.selectedSegmentIndex == 0)
    {
        NSLog(@"Off");
        sigChangeBool = FALSE;
    }
    else if (segment.selectedSegmentIndex == 1)
    {
        NSLog(@"On");
        sigChangeBool = TRUE;
    }
}


- (IBAction)saveBtnPressed:(id)sender
{
    NSLog(@"saveBtnPressed");
    // Delete current settings and add new:
    NSFetchRequest *allSettingsFromCore = [[NSFetchRequest alloc] init];
    [allSettingsFromCore setEntity:[NSEntityDescription entityForName:@"Settings" inManagedObjectContext:managedObjectContext]];
    [allSettingsFromCore setIncludesPropertyValues:NO];
    NSError *error = nil;
    NSArray *tmpSettingsRemovalArray = [managedObjectContext executeFetchRequest:allSettingsFromCore error:&error];
    NSLog(@"scratch data has %i records", [tmpSettingsRemovalArray count]);
    for (NSManagedObject *oneSet in tmpSettingsRemovalArray)
    {
        [managedObjectContext deleteObject:oneSet];
    }
    
    Settings *newSettingsToInsert = [NSEntityDescription insertNewObjectForEntityForName:@"Settings" inManagedObjectContext:managedObjectContext];
    [newSettingsToInsert setToEmail:_toEmailDefaultLabel.text];
    NSLog(@"just set setToEmail to %@", _toEmailDefaultLabel.text);
    [newSettingsToInsert setFromEmail:_fromEmailDefaultLabel.text];
    [newSettingsToInsert setSmtpServer:_smtpServerDefaultLabel.text];
    [newSettingsToInsert setSmtpPasswd:_smtpPasswdDefaultLabel.text];
    [newSettingsToInsert setWolIP:_wolIPDefaultLabel.text];
    //[newSettingsToInsert setMACforWolIp:_labelForMacAdd.text];
    [newSettingsToInsert setMACforWolIp:macAddString];
    [newSettingsToInsert setSigChangeFnBool:[NSNumber numberWithBool: sigChangeBool]];
    // I think this persists between runs etc
    [managedObjectContext save:nil];
}

// text animation. Beautiful
// URL: http://stackoverflow.com/questions/1247113/iphone-keyboard-covers-uitextfield
// Limited scroll ability without having a scrolling view, but extremely concise.

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField:textField up: YES];
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField:textField up: NO];
}

- (void) animateTextField:(UITextField *) textField up: (BOOL) up
{
    const int movementDistance = 90;
    const float movementDuration = 0.3f;
    
    int movement = (up ? - movementDistance : movementDistance);
    [UIView beginAnimations:@"anim" context:nil];
    [UIView setAnimationDuration:movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (void) setSettingsDefaults
{
    // actually this should now never get called:
    NSLog(@"----------->>>> first time through: setSettingsDefaults: ");
    // this took a long time to spot:
    // segment controller defaults to 'on' from the storyboard
    Settings *inserterDefaultSettings = [NSEntityDescription insertNewObjectForEntityForName:@"Settings" inManagedObjectContext:managedObjectContext];
    [inserterDefaultSettings setToEmail:@"donal.hanna@the-plot.com"];
    _toEmailDefaultLabel.text = @"donal.hanna@the-plot.com";
    tmpSettingVals.toEmail = @"donal.hanna@the-plot.com";
    // this doesn't work:
    NSLog(@"first time through and setting tmpSettingVals.toEmail to %@", tmpSettingVals.toEmail);
    
    [inserterDefaultSettings setFromEmail:@"donal.hanna@the-plot.com"];
    _fromEmailDefaultLabel.text = @"donal.hanna@the-plot.com";
    tmpSettingVals.fromEmail = @"donal.hanna@the-plot.com";
    
    [inserterDefaultSettings setSmtpServer:@"smtp.the-plot.com"];
    _smtpServerDefaultLabel.text =@ "smtp.the-plot.com";
    tmpSettingVals.smtpServer =@ "smtp.the-plot.com";
    
    [inserterDefaultSettings setSmtpPasswd:@"1234"];
    _smtpPasswdDefaultLabel.text =@"1234";
    tmpSettingVals.smtpPasswd =@"1234";
    
    [inserterDefaultSettings setWolIP:@"192.168.1.254"];
    _wolIPDefaultLabel.text = @"192.168.1.254";
    tmpSettingVals.wolIP = @"192.168.1.254";
    
    [inserterDefaultSettings setGeoFenceMonitoring:[NSNumber numberWithBool:TRUE] ];
    //NSLog(@"%@", error);
    
    macAddString = [self ip2mac:inet_addr("192.168.1.254")];
    tmpSettingVals.mACforWolIp = macAddString;
    _labelForMacAdd.text = macAddString;
    [inserterDefaultSettings setMACforWolIp:macAddString];
    NSError *error = nil;
    [managedObjectContext save:&error];
}

- (void) loadCurrentSettingVals
{
    // It's early. This seems ugly. Not sure of a better way at the moment.
    NSLog(@" ------>>>>>>>>  loading: loadCurrentSettingVals %@ ", allCurrentSettingsArray[0] );
    tmpSettingVals = Nil;
    tmpSettingVals = allCurrentSettingsArray[0];
    NSLog(@"loadCurrentSettingVals: assigned tmpSettingVals to core data load");
    _toEmailDefaultLabel.text = tmpSettingVals.toEmail;
    NSLog(@"just loaded and set _toEmailDefaultLabel.text to %@", _toEmailDefaultLabel.text);
    _fromEmailDefaultLabel.text = tmpSettingVals.fromEmail;
    _smtpServerDefaultLabel.text = tmpSettingVals.smtpServer;
    _smtpPasswdDefaultLabel.text = tmpSettingVals.smtpPasswd;
    _wolIPDefaultLabel.text = tmpSettingVals.wolIP;
    NSLog(@"At least I've loaded %@", tmpSettingVals.wolIP);
//    if (![tmpSettingVals.wolIP isEqualToString:@"dummy"])
//    {
//        macAddString = [self ip2mac:inet_addr([tmpSettingVals.wolIP UTF8String])];
//        NSLog(@"Just loaded settings and macAddString is %@", macAddString);
//    }
    //tmpSettingVals.mACforWolIp = macAddString;
    _labelForMacAdd.text = tmpSettingVals.mACforWolIp;
    macAddString = tmpSettingVals.mACforWolIp;
    // will have to come back to the segment setting;
    sigChangeBool = [tmpSettingVals.sigChangeFnBool boolValue];
    if (sigChangeBool)
    {
        [segment setSelectedSegmentIndex:1];
    }
    else
    {
        [segment setSelectedSegmentIndex:0];
    }
}

- (IBAction)testWolBtn:(id)sender
{
    id networkInfo = [self fetchSSIDInfo];
    NSDictionary *tmpNetworkInfoDict = networkInfo;
    NSString *ssidName = [tmpNetworkInfoDict valueForKey:@"SSID"];
    NSLog(@"I think the ssid is %@ and mac address is %@", ssidName, macAddString);
    if ([ssidName isEqualToString:HOMENETWORKSSID])
    {
        if (!([macAddString length] == 0))
        {
            ArpFunctionality *arpStuff = [[ArpFunctionality alloc] init];
            NSArray *macAddrAsInts = [arpStuff convertMACStringToIntArray:macAddString];
            [arpStuff sendWoLPacket:macAddrAsInts inputIP:_wolIPDefaultLabel.text];
        }
        else
        {
            NSLog(@"No MAC address set / saved!");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh-oh!"
                                                            message:@"No MAC address set / saved"
                                                           delegate: nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
//        //http://shadesfgray.wordpress.com/2010/12/17/wake-on-lan-how-to-tutorial/
//        
//        unsigned char tosend[102];
//        unsigned char mac[6];
//        
//        for(int i = 0; i < 6; i++)
//        {
//            tosend[i] = 0xff;
//        }
//        
//        // need to convert IP to mac. Update: now have a mac address but as a string.
//        // This bad boy takes the mac addreess in as hex. Cheap and cheerful would be to split
//        // the string into an array on the colon.
//        
//        NSArray *tmpMacBitsAsStrings = [macAddString componentsSeparatedByString:@":"];
//        
//
//        NSMutableArray *macPartsAsInts = [self convertToInt:tmpMacBitsAsStrings];
//        
//        mac[0] = [macPartsAsInts[0] integerValue];
//        mac[1] = [macPartsAsInts[1] integerValue];
//        mac[2] = [macPartsAsInts[2] integerValue];
//        mac[3] = [macPartsAsInts[3] integerValue];
//        mac[4] = [macPartsAsInts[4] integerValue];
//        mac[5] = [macPartsAsInts[5] integerValue];
//        
//        NSLog(@"macPartsAsInts: %@", macPartsAsInts);
//        
//        
//        for(int i = 1; i <= 16; i++)
//        {
//            // don't think this is right:
//            memcpy(&tosend[i * 6], &mac, 6 * sizeof(unsigned char));
//            //memcpy(&tosend, &mac, 6 * sizeof(unsigned char));
//        }
//        GCDAsyncUdpSocket *mysocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
//        //NSData  *payload = [result dataUsingEncoding:NSUTF8StringEncoding];
//        NSData *payLoad = [NSData dataWithBytes:tosend length:102];
//        [mysocket sendData:payLoad toHost:_wolIPDefaultLabel.text port:9 withTimeout:-1 tag:0];
    }
    else
    {
        NSLog(@"Not on home network!");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh-oh!"
                                                        message:@"Not on home network"
                                                       delegate: nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

// http://stackoverflow.com/questions/2258172/how-do-i-query-the-arp-table-on-iphone

- (NSString*)ip2mac:(in_addr_t)addr
{
    NSLog(@"in ip2mac");
    NSString *ret = nil;
    
    size_t needed;
    char *buf, *next;
    
    struct rt_msghdr *rtm;
    struct sockaddr_inarp *sin;
    struct sockaddr_dl *sdl;
    
    int mib[6];
    
    mib[0] = CTL_NET;
    mib[1] = PF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_INET;
    mib[4] = NET_RT_FLAGS;
    mib[5] = RTF_LLINFO;
    
    if (sysctl(mib, sizeof(mib) / sizeof(mib[0]), NULL, &needed, NULL, 0) < 0)
    {
        err(1, "route-sysctl-estimate");
        NSLog(@"route-sysctl-estimate");
    }
    
    if ((buf = (char*)malloc(needed)) == NULL)
    {
        err(1, "malloc");
        NSLog(@"malloc");
    }
    
    if (sysctl(mib, sizeof(mib) / sizeof(mib[0]), buf, &needed, NULL, 0) < 0)
    {
        err(1, "retrieval of routing table");
        NSLog(@"retrieval of routing table");
    }
    for (next = buf; next < buf + needed; next += rtm->rtm_msglen) {
        
        rtm = (struct rt_msghdr *)next;
        sin = (struct sockaddr_inarp *)(rtm + 1);
        sdl = (struct sockaddr_dl *)(sin + 1);
        
        if (addr != sin->sin_addr.s_addr || sdl->sdl_alen < 6)
            continue;
        
        u_char *cp = (u_char*)LLADDR(sdl);
        
        ret = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
               cp[0], cp[1], cp[2], cp[3], cp[4], cp[5]];
        
        break;
    }
    
    free(buf);
    NSLog(@"return val is %@", ret);
    _labelForMacAdd.text = ret;
    return ret;
}


- (IBAction)testEmailBtnPressed:(id)sender
{
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0);
    [self.view addSubview: activityIndicator];
    
    [activityIndicator startAnimating];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        CTCoreMessage *testMsg = [[CTCoreMessage alloc] init];
        [testMsg setTo:[NSSet setWithObject:[CTCoreAddress addressWithName:_toEmailDefaultLabel.text email:_toEmailDefaultLabel.text]]];
        [testMsg setFrom:[NSSet setWithObject:[CTCoreAddress addressWithName:_fromEmailDefaultLabel.text email:_fromEmailDefaultLabel.text]]];
        [testMsg setBody:@"Settings test"];
        [testMsg setSubject:@"Settings test"];
        
        NSError *sendError;
        BOOL success = [CTSMTPConnection sendMessage:testMsg server:_smtpServerDefaultLabel.text username:_fromEmailDefaultLabel.text password:_smtpPasswdDefaultLabel.text port:25 connectionType:CTSMTPConnectionTypePlain useAuth:YES error:&sendError];
        if (!success)
        {
            NSLog(@"%@", [sendError userInfo]);
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Back from email"); // 2
            NSString *alertBody = [[NSString alloc] init];
            [activityIndicator stopAnimating];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            if (success)
            {
                alertBody =@"No error from sending email";
            }
            else
            {
                alertBody = [NSString stringWithFormat:@"Error from sending email: %@", [sendError userInfo]];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email Test"
                                                            message:alertBody
                                                           delegate: nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        });
    });
}



- (NSMutableArray *)convertToInt:(NSArray *)inArray
{
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    for( NSString *eachString in inArray )
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


- (BOOL)isIp:(NSString*)string{
    struct in_addr pin;
    int success = inet_aton([string UTF8String],&pin);
    if (success == 1) return TRUE;
    return FALSE;
}

- (id)fetchSSIDInfo
{
    NSArray *ifs = (__bridge id)CNCopySupportedInterfaces();
    NSLog(@"%s: Supported interfaces: %@", __func__, ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%s: %@ => %@", __func__, ifnam, info);
        if (info && [info count]) {
            break;
        }
    }
    return info ;
}


@end