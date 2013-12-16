//
//  KZSimpleTime.m
//  Sky Watch
//
//  Created by Kurt Zoglmann on 12/8/13.
//  Copyright (c) 2013 Kurt Zoglmann. All rights reserved.
//

#import "KZSimpleTime.h"

@implementation KZSimpleTime

- (id) initWithHour:(double)hour minute:(double)min {
    self = [super init];
    if (self) {
        self->_hour = hour;
        self->_min = min;
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"KZSimpleTime(hour: %d, minute: %d)", self.hour, self.min];
}

@end
