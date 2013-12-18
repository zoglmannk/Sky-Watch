//
//  KZSimpleDate.h
//  Sky Watch
//
//  Created by Kurt Zoglmann on 12/8/13.
//  Copyright (c) 2013 Kurt Zoglmann. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 A simple way to express a Gregorian date (i.e. month/day/year). This is
 a container class and nothing more.
 */
@interface KZSimpleDate : NSObject

@property (nonatomic, readonly) int month;
@property (nonatomic, readonly) int day;
@property (nonatomic, readonly) int year;

- (id) init;
- (id) initWithDate:(NSDate*) date;
- (id) initWithMonth:(double)month day:(double)day year:(int)year;
- (NSDate*) convertToNSDate;

- (NSString *)description;

@end
