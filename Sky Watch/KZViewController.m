//
//  KZViewController.m
//  Sky Watch
//
//  Created by Kurt Zoglmann on 12/7/13.
//  Copyright (c) 2013 Kurt Zoglmann. All rights reserved.
//

#import "KZViewController.h"

@interface KZViewController ()

@end

@implementation KZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.connectionButton.backgroundColor = [UIColor darkGrayColor];
    self.connectionButton.layer.cornerRadius = 10;
    self.connectionButton.clipsToBounds = YES;

}

- (IBAction)connectionButtonClick:(id)sender {
    NSLog(@"The User clicked the connect button!");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
