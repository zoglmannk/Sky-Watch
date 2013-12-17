//
//  KZPebbleController.m
//  Sky Watch
//
//  Created by Kurt Zoglmann on 12/14/13.
//  Copyright (c) 2013 Kurt Zoglmann. All rights reserved.
//

#import "KZPebbleController.h"


@interface KZPebbleController () <PBPebbleCentralDelegate>
@end


@implementation KZPebbleController {
    BOOL _debug;
    PBWatch *_targetWatch;
    
    BOOL _wasCommunicationSuccessful;
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
    

    if(nil != _targetWatch) {
        KZGPSCoordinate *coordinate = [[KZGPSCoordinate alloc] initWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
        int timeZoneOffset = [[NSTimeZone localTimeZone] secondsFromGMT] / 3600;
        
        //KZSimpleDate *today = [[KZSimpleDate alloc] initWithDate:[NSDate new]];
        NSDate *today = [NSDate new];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        
        dispatch_semaphore_t _sema = dispatch_semaphore_create(0);
        int daysWorthOfData = 14;
        for(int i=0; i<daysWorthOfData; i++) {

            components.day = i;
            NSDate *date = [gregorian dateByAddingComponents:components toDate:today options:0];
            KZSimpleDate *calcDate = [[KZSimpleDate alloc] initWithDate:date];
            
            //send one chunk for the moment
            KZCalculator *calculator = [KZCalculator new];
            KZResult *result = [calculator calculateWithGps:coordinate utcToLocal:timeZoneOffset date:calcDate];
            NSDictionary *update = [[KZPebbleDataChunk new] encodedResult:result slot:0];
            
            NSLog(@"sending targetWatch appMessagesPushUpdate:onSent:");
            dispatch_async(dispatch_get_main_queue(), ^{ //for some reason this has to be on the main_queue
                [_targetWatch appMessagesPushUpdate:update onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
                    if (!error) {
                        _wasCommunicationSuccessful = YES;
                        NSLog(@"Successfully sent message.");
                    }
                    else {
                        _wasCommunicationSuccessful = NO;
                        NSLog(@"Error sending message: %@", error);
                    }
                    
                    dispatch_semaphore_signal(_sema);
                    
                }];
            });

            dispatch_semaphore_wait(_sema, DISPATCH_TIME_FOREVER);
            
            if(!_wasCommunicationSuccessful) {
                break;
            }

        }
        
        if(_wasCommunicationSuccessful) {
            NSLog(@"Calling onSuccess() block");
            onSuccess();
        } else {
            NSLog(@"Calling onFailure() block");
            onFailure(@"Error sending data!");
        }
        
        //required to disconnect after done communicating
        [_targetWatch closeSession:^(void) {
            //nothing to do
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
        
        dispatch_semaphore_t _sema = dispatch_semaphore_create(0);
        //log firmware verison of watch
        dispatch_async(dispatch_get_main_queue(), ^{ //for some reason this has to be on the main_queue
            [connectedWatch getVersionInfo:^(PBWatch *watch, PBVersionInfo *versionInfo ) {
                NSLog(@"Pebble firmware version: %li.%li.%li-%@",
                      (long)versionInfo.runningFirmwareMetadata.version.os,
                      (long)versionInfo.runningFirmwareMetadata.version.major,
                      (long)versionInfo.runningFirmwareMetadata.version.minor,
                      versionInfo.runningFirmwareMetadata.version.suffix
                      );
                dispatch_semaphore_signal(_sema);
            }
                                 onTimeout:^(PBWatch *watch) {
                                     NSLog(@"Timed out trying to get version info from Pebble.");
                                     dispatch_semaphore_signal(_sema);
                                 }
             ];
        });
        
        dispatch_semaphore_wait(_sema, DISPATCH_TIME_FOREVER);
        
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
