//
//  KZPebbleController.h
//  Sky Watch
//
//  Created by Kurt Zoglmann on 12/14/13.
//  Copyright (c) 2013 Kurt Zoglmann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PebbleKit/PebbleKit.h>
#import <CoreLocation/CoreLocation.h>


@interface KZPebbleController : NSObject

/**!
 @param onSuccess called when data is successfully sent
 @param onFailure called when data cannnot be sent
 */
- (void) sendDataUsingLocation:(CLLocation*)location onSuccess:(void(^)(void))onSuccess onFailure:(void(^)(NSString *errorMessage))onFailure;

@end
