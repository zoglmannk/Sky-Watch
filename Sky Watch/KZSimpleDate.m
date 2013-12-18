//
//  KZSimpleDate.m
//  Sky Watch
//
//  Created by Kurt Zoglmann on 12/8/13.
//  Copyright (c) 2013 Kurt Zoglmann. All rights reserved.
//

#import "KZSimpleDate.h"

@implementation KZSimpleDate

- (id) init {
    NSDate *now = [NSDate new];
    return [self initWithDate:now];
}

- (id) initWithDate:(NSDate*) date {
    self = [super init];
    if (self) {
        NSCalendar *gregorian =
        [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        
        NSUInteger flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
        NSDateComponents *comps = [gregorian components:flags fromDate:date];
        
        self->_day = comps.day;
        self->_month = comps.month;
        self->_year = comps.year;
    }
    
    return self;
}

- (id) initWithMonth:(double)month day:(double)day year:(int)year {
    self = [super init];
    if (self) {
        self->_day = day;
        self->_month = month;
        self->_year = year;
    }
    
    return self;
}

- (NSDate*) convertToNSDate {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    
    NSString *dateAsStr = [NSString stringWithFormat:@"%d/%d/%d", self.month, self.day, self.year];
    return [formatter dateFromString:dateAsStr];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"KZSimpleDate(month: %d, day: %d, year: %d)", self.month, self.day, self.year];
}

@end
