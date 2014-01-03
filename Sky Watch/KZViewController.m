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

@property (nonatomic) KZPebbleController *pebbleConroller;
@property (atomic) CLLocation *currentLocation;

@property (atomic) BOOL dataTransferInProgress;
@property (atomic) NSDate *dataTransferResult;

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
    
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];

}

- (BOOL)prefersStatusBarHidden {
    return YES;
}



- (IBAction)connectionButtonClick:(id)sender {
    NSLog(@"The User clicked the connect button!");
    
    [self.connectionButton setEnabled:NO];
    [self.connectionLabel setText:@"Sending Data..."];
    
    if(nil == self.pebbleConroller) {
        self.pebbleConroller = [KZPebbleController new];
    }
    
    
    void(^onFailure)(NSString *errorMessage) = ^void(NSString *errorMessage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.connectionLabel setText:errorMessage];
            [self.connectionButton setEnabled:YES];
            
            self.dataTransferResult = [NSDate new];
            self.dataTransferInProgress = false;
        });
    };
    
    void(^onSuccess)(void) = ^void(void) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.connectionLabel setText:@"Data Sent..."];
            [self.connectionButton setEnabled:YES];
            
            self.dataTransferResult = [NSDate new];
            self.dataTransferInProgress = false;
        });
    };
    
    self.dataTransferInProgress = true;
    dispatch_queue_t myQueue = dispatch_queue_create("Send Data",NULL);
    dispatch_async(myQueue, ^{
        // Perform long running process
        [self.pebbleConroller sendDataUsingLocation:self.currentLocation onSuccess:onSuccess onFailure:onFailure];
    });
}

- (void) locationManager:(CLLocationManager *)manager
     didUpdateToLocation:(CLLocation *)newLocation
            fromLocation:(CLLocation *)oldLocation {
    
    NSLog(@"Core location has a position.");
    
    if(!self.dataTransferInProgress) {
        [self.connectionLabel setText:@"Waiting..."];
        [self.connectionButton setEnabled:YES];
    }
    
    self.currentLocation = newLocation;
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Core location can't get a fix.");
    
    if(!self.dataTransferInProgress) {
        [self.connectionLabel setText:@"No Location available"];
        [self.connectionButton setEnabled:NO];
    }
    
    self.currentLocation = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    self.pebbleConroller = nil;
}

@end
