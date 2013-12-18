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

- (void)testInitWithNSDate {
    NSString* datetime = @"12/15/2013 16:25:34"; // Today's date
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
    NSDate *testDate = [dateFormatter dateFromString:datetime];
    
    KZSimpleDate *date = [[KZSimpleDate alloc] initWithDate:testDate];
    
    XCTAssertNotNil(date, "The date should not be nil!");
    XCTAssertEqual(12, date.month, "The month property should be set to 12 after initialization.");
    XCTAssertEqual(15, date.day, "The day property should be set to 15 after initialization.");
    XCTAssertEqual(2013, date.year, "The year property should be set to 2013 after initialization.");
}


- (void)testInit {
    KZSimpleDate *date = [KZSimpleDate new];
    
    XCTAssertNotNil(date, "The date should not be nil!");
    XCTAssertTrue(date.month >= 1 && date.month <= 12, @"The month should be between 1 and 12");
    XCTAssertTrue(date.day >= 1 && date.day <= 31, @"The month should be between 1 and 31");
    XCTAssertTrue(date.year >= 2013, @"The month should be >= 2013");
}

- (void)testConverToNSDate {
    KZSimpleDate *date = [[KZSimpleDate alloc] initWithMonth:12 day:15 year:2013];

    NSDate *converted = [date convertToNSDate];
    
    NSCalendar *gregorian =
    [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *comps = [gregorian components:flags fromDate:converted];
    XCTAssertEqual(12, comps.month, "The month should be equal to what we initially initialized the KZSimpleDate with");
    XCTAssertEqual(15, comps.day,   "The day should be equal to what we initially initialized the KZSimpleDate with");
    XCTAssertEqual(2013, comps.year, "The year should be equal to what we initially initialized the KZSimpleDate with");
}

- (void)testDescription {
    KZSimpleDate *date = [[KZSimpleDate alloc] initWithMonth:12 day:15 year:2013];
    
    NSString *str = [date description];
    
    XCTAssertEqualObjects(@"KZSimpleDate(month: 12, day: 15, year: 2013)", str, @"The initialized string should provide a description that matches.");
}

@end
