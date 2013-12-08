//
//  KZSimpleDate.m
//  Sky Watch
//
//  Created by Kurt Zoglmann on 12/8/13.
//  Copyright (c) 2013 Kurt Zoglmann. All rights reserved.
//

#import "KZSimpleDate.h"

@implementation KZSimpleDate


- (id) initWithMonth:(double)month day:(double)day year:(int)year {
    self = [super init];
    if (self) {
        self->_day = day;
        self->_month = month;
        self->_year = year;
    }
    
    return self;
}

@end
