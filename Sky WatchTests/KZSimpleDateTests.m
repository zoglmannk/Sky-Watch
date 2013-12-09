//
//  KZSimpleDateTests.m
//  Sky Watch
//
//  Created by Kurt Zoglmann on 12/8/13.
//  Copyright (c) 2013 Kurt Zoglmann. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KZSimpleDate.h"

@interface KZSimpleDateTests : XCTestCase

@end

@implementation KZSimpleDateTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testInitWithMonthDayYear {
    int month = 10;
    int day = 3;
    int year = 2013;
    
    KZSimpleDate *date = [[KZSimpleDate alloc] initWithMonth:month day:day year:year];
    
    XCTAssertEqual(month, date.month, @"The initializer should set the month property with the incoming month parameter");
    XCTAssertEqual(day, date.day, @"The initializer should set the day property with the incoming day parameter");
    XCTAssertEqual(year, date.year, @"The initializer should set the year property with the incoming year parameter");
    
}

@end
