//
//  KZViewController.m
//  Sky Watch
//
//  Created by Kurt Zoglmann on 12/7/13.
//  Copyright (c) 2013 Kurt Zoglmann. All rights reserved.
//

#import "KZViewController.h"
#import "KZPebbleController.h"



@interface KZViewController ()

@property KZPebbleController *pebbleConroller;
@property CLLocation *currentLocation;

@end


@implementation KZViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        self.locationManager.delegate = self;
    }
    [self.locationManager startUpdatingLocation];

}

- (IBAction)connectionButtonClick:(id)sender {
    NSLog(@"The User clicked the connect button!");
    
    [self.connectionButton setEnabled:NO];
    [self.connectionLabel setText:@"Sending Data..."];
    
    if(nil == self.pebbleConroller) {
        self.pebbleConroller = [KZPebbleController new];
    }
    
    
    void(^onFailure)(NSString *errorMessage) = ^void(NSString *errorMessage) {
        [self.connectionLabel setText:errorMessage];
        [self.connectionButton setEnabled:YES];
    };
    
    void(^onSuccess)(void) = ^void(void) {
        [self.connectionLabel setText:@"Data Sent..."];
        [self.connectionButton setEnabled:YES];
    };
    
    
    dispatch_queue_t myQueue = dispatch_queue_create("Send Data",NULL);
    dispatch_async(myQueue, ^{
        // Perform long running process
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.pebbleConroller sendDataUsingLocation:self.currentLocation onSuccess:onSuccess onFailure:onFailure];
        });
    });
}

- (void) locationManager:(CLLocationManager *)manager
     didUpdateToLocation:(CLLocation *)newLocation
            fromLocation:(CLLocation *)oldLocation {
    
    NSLog(@"Core location has a position.");
    
    [self.connectionLabel setText:@"Waiting..."];
    [self.connectionButton setEnabled:YES];
    
    self.currentLocation = newLocation;
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Core location can't get a fix.");
    
    //optimistic that data is NOT being sent.. deal with later
    [self.connectionLabel setText:@"No Location available"];
    [self.connectionButton setEnabled:NO];
    
    self.currentLocation = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    self.pebbleConroller = nil;
}

@end
