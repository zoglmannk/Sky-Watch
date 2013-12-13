//
//  KZAppDelegate.h
//  Sky Watch
//
//  Created by Kurt Zoglmann on 12/7/13.
//  Copyright (c) 2013 Kurt Zoglmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PebbleKit/PebbleKit.h>

@interface KZAppDelegate : UIResponder <UIApplicationDelegate>


@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) PBWatch *connectedWatch;

@end
