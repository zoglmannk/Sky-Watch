//
//  KZSimpleTimeTests.m
//  Sky Watch
//
//  Created by Kurt Zoglmann on 12/8/13.
//  Copyright (c) 2013 Kurt Zoglmann. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KZSimpleTime.h"

@interface KZSimpleTimeTests : XCTestCase

@end

@implementation KZSimpleTimeTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testInitWithHourMinute {
    int hour = 10;
    int min = 5;
    
    KZSimpleTime *time = [[KZSimpleTime alloc] initWithHour:hour minute:min];
    
    XCTAssertEqual(hour, time.hour, @"The initializer should set the hour property with the incoming hour parameter");
    XCTAssertEqual(min, time.min, @"The initializer should set the min property with the incoming min parameter");
}

- (void)testDescription {
    KZSimpleTime *time = [[KZSimpleTime alloc] initWithHour:14 minute:35];
    
    NSString *description = [time description];
    
    XCTAssertEqualObjects(@"KZSimpleTime(hour: 14, minute: 35)", description, @"The description should match.");
}

@end
