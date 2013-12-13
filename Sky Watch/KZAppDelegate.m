//
//  KZAppDelegate.m
//  Sky Watch
//
//  Created by Kurt Zoglmann on 12/7/13.
//  Copyright (c) 2013 Kurt Zoglmann. All rights reserved.
//

#import "KZAppDelegate.h"

static const uint32_t SOME_NUM_KEY = 0xb00bf00b;
static const uint32_t SOME_STRING_KEY = 0xabbababe;

@implementation KZAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.connectedWatch = [[PBPebbleCentral defaultCentral] lastConnectedWatch];
    [self logApplicationStartup];
    
    //setup shared UUID for communication with watchface
    if(nil != self.connectedWatch) {
        uuid_t myAppUUIDbytes;
        NSUUID *myAppUUID = [[NSUUID alloc] initWithUUIDString:@"8d5f28cd-e52e-433a-a277-0c6859a8dd00"];
        [myAppUUID getUUIDBytes:myAppUUIDbytes];
        
        [PBPebbleCentral defaultCentral].AppUUID =[NSData dataWithBytes:myAppUUIDbytes length:16];
    }
    
    
    //Test sending of some junk
    if(nil != self.connectedWatch) {
        NSDictionary *update = @{ @(SOME_NUM_KEY):[NSNumber numberWithUint8:42],
                                  @(SOME_STRING_KEY):@"a string" };
        [self.connectedWatch appMessagesPushUpdate:update onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
            if (!error) {
                NSLog(@"Successfully sent message.");
            }
            else {
                NSLog(@"Error sending message: %@", error);
            }
        }];
    }
    
    return YES;
}

- (void)logApplicationStartup {

    NSLog(@"Last connected watch: %@", self.connectedWatch);
    if(nil != self.connectedWatch) {
        
        //log last connected date
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"YYYY-MM-dd hh:mm"];
        
        NSString *formatedLastConnectedDate =
        self.connectedWatch.lastConnectedDate == nil ?
        @"unknown" : [formatter stringFromDate:self.connectedWatch.lastConnectedDate];
        
        NSLog(@"Last connected on: %@", formatedLastConnectedDate);
        
        //log firmware verison of watch
        [self.connectedWatch getVersionInfo:^(PBWatch *watch, PBVersionInfo *versionInfo ) {
            NSLog(@"Pebble firmware version: %li.%li.%li-%@",
                  (long)versionInfo.runningFirmwareMetadata.version.os,
                  (long)versionInfo.runningFirmwareMetadata.version.major,
                  (long)versionInfo.runningFirmwareMetadata.version.minor,
                  versionInfo.runningFirmwareMetadata.version.suffix
                  );
        }
                                  onTimeout:^(PBWatch *watch) {
                                      NSLog(@"Timed out trying to get version info from Pebble.");
                                  }
         ];
        
        
    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
