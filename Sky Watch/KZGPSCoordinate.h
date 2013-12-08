//
//  KZGPSCoordinate.h
//  Sky Watch
//
//  Created by Kurt Zoglmann on 12/8/13.
//  Copyright (c) 2013 Kurt Zoglmann. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KZGPSCoordinate : NSObject

@property (nonatomic, readonly) double latitude;
@property (nonatomic, readonly) double longitude;

- (id) initWithLatitude:(double)latitude longitude:(double)longitude;

@end
