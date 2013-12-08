//
//  KZMoonEvent.m
//  Sky Watch
//
//  Created by Kurt Zoglmann on 12/8/13.
//  Copyright (c) 2013 Kurt Zoglmann. All rights reserved.
//

#import "KZMoonEvent.h"

@implementation KZMoonEvent

- (id) initWithEvent:(KZEvent*) event {
    self = [super init];
    if (self) {
        self->_rise = event.rise;
        self->_set = event.set;
        self->_riseAzimuth = event.riseAzimuth;
        self->_setAzimuth = event.setAzimuth;
        self->_type = event.type;
        self->_meridianCrossing = event.meridianCrossing;
        self->_antimeridianCrossing = event.antimeridianCrossing;
        self->_risenAmount = event.risenAmount;
        self->_setAmount = event.setAmount;
    }
    
    return self;
}

@end
