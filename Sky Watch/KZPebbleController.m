//
//  KZPebbleController.m
//  Sky Watch
//
//  Created by Kurt Zoglmann on 12/14/13.
//  Copyright (c) 2013 Kurt Zoglmann. All rights reserved.
//

#import "KZPebbleController.h"
#import "KZPebbleDataChunk.h"
#import "KZCalculator.h"


@interface KZPebbleController () <PBPebbleCentralDelegate>
@end


@implementation KZPebbleController {
    BOOL _debug;
    PBWatch *_targetWatch;
}

- (id) init {
    self = [super init];
    if (self) {
        NSLog(@"init was called");
        _debug = YES;
        
        uuid_t myAppUUIDbytes;
        NSUUID *myAppUUID = [[NSUUID alloc] initWithUUIDString:@"8d5f28cd-e52e-433a-a277-0c6859a8dd00"];
        [myAppUUID getUUIDBytes:myAppUUIDbytes];
        NSLog(@"setup myAppUUID to communicate with App");
        [PBPebbleCentral defaultCentral].AppUUID =[NSData dataWithBytes:myAppUUIDbytes length:16];
        
        _targetWatch = [[PBPebbleCentral defaultCentral] lastConnectedWatch];
        
        // We'd like to get called when Pebbles connect and disconnect, so become the delegate of PBPebbleCentral:
        [[PBPebbleCentral defaultCentral] setDelegate:self];
    }
    
    
    return self;
}


- (void) sendDataUsingLocation:(CLLocation*)location onSuccess:(void(^)(void)) onSuccess  onFailure:(void(^)(NSString *errorMessage)) onFailure {
    
    if(_debug) {;
        [self logApplicationStartupWithWatch: _targetWatch];
    }
    
    if(nil == _targetWatch) {
        NSLog(@"No watch found!");
        onFailure(@"No watch found!");
        return;
    } else if(![_targetWatch isConnected]) {
        NSLog(@"Watch is not connected!");
        onFailure(@"Watch is not connected!");
        return;
    }
    
    //Test sending of some junk
    if(nil != _targetWatch) {
        KZGPSCoordinate *coordinate = [[KZGPSCoordinate alloc] initWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
        int timeZoneOffset = [[NSTimeZone localTimeZone] secondsFromGMT] / 3600;
        
        //send one chunk for the moment
        KZCalculator *calculator = [KZCalculator new];
        KZResult *result = [calculator calculateWithGps:coordinate utcToLocal:timeZoneOffset date:[KZSimpleDate new]];
        NSDictionary *update = [[KZPebbleDataChunk new] encodedResult:result slot:0];
        
        NSLog(@"sending targetWatch appMessagesPushUpdate:onSent:");
        [_targetWatch appMessagesPushUpdate:update onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
            if (!error) {
                onSuccess();
                NSLog(@"Successfully sent message.");
            }
            else {
                onFailure(@"Error sending data!");
                NSLog(@"Error sending message: %@", error);
            }
            
            //required to disconnect after done communicating
            [_targetWatch closeSession:^(void) {
                //nothing to do
            }];
        }];
    }
    
}


- (void) logApplicationStartupWithWatch:(PBWatch*) connectedWatch {
    
    NSLog(@"Last connected watch: %@", connectedWatch);
    if(nil != connectedWatch) {
        
        //log last connected date
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"YYYY-MM-dd hh:mm"];
        
        NSString *formatedLastConnectedDate =
            connectedWatch.lastConnectedDate == nil ?
                @"unknown" :
                [formatter stringFromDate:connectedWatch.lastConnectedDate];
        
        NSLog(@"Last connected on: %@", formatedLastConnectedDate);
        
        
        //log firmware verison of watch
        [connectedWatch getVersionInfo:^(PBWatch *watch, PBVersionInfo *versionInfo ) {
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

/*
 *  PBPebbleCentral delegate methods
 */
- (void)setTargetWatch:(PBWatch*)watch {
    NSLog(@"setTargetWatch called!");
    _targetWatch = watch;
}

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidConnect:(PBWatch*)watch isNew:(BOOL)isNew {
    [self setTargetWatch:watch];
    NSLog(@"Watch connected!");
}

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidDisconnect:(PBWatch*)watch {
    NSLog(@"Watch disconnected!");
    if (_targetWatch == watch || [watch isEqual:_targetWatch]) {
        [self setTargetWatch:nil];
    }
}

@end
