//
//  KZPosition.m
//  Sky Watch
//
//  Created by Kurt Zoglmann on 12/7/13.
//  Copyright (c) 2013 Kurt Zoglmann. All rights reserved.
//

#import "KZPosition.h"

@implementation KZPosition


- (id) initWithRightAscention:(double)rightAscention declination:(double) declination {
    self = [super init];
    if (self) {
        self->_rightAscention = rightAscention;
        self->_declination = declination;
    }
    
    return self;
}

@end
