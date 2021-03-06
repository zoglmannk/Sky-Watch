//
//  KZGPSCoordinate.m
//  Sky Watch
//
//  Created by Kurt Zoglmann on 12/8/13.
//  Copyright (c) 2013 Kurt Zoglmann. All rights reserved.
//

#import "KZGPSCoordinate.h"


@implementation KZGPSCoordinate

- (id) initWithLatitude:(double)latitude longitude:(double)longitude {
    self = [super init];
    if (self) {
        self->_latitude  = latitude;
        self->_longitude = longitude;
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"KZGPSCoordinate(latitude: %3.3f, longitude: %3.3f)", self.latitude, self.longitude];
}

@end
