//
//  KZPebbleDataChunkTests.m
//  Sky Watch
//
//  Created by Kurt Zoglmann on 12/15/13.
//  Copyright (c) 2013 Kurt Zoglmann. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KZPebbleDataChunk.h"


@interface KZPebbleDataChunkTests : XCTestCase
@end


@implementation KZPebbleDataChunkTests {
    KZPebbleDataChunk *_dataChunk;
}


- (void)setUp {
    [super setUp];
    _dataChunk = [KZPebbleDataChunk new];
}


- (void)tearDown {
    [super tearDown];
    _dataChunk = nil;
}


- (void)testEncodedResultContainsDaySlotSet {
    
    NSDictionary *encodedResult = [_dataChunk encodedResult:nil slot:1];
    
    XCTAssertEqual(@(1), [encodedResult objectForKey:@(DAY_SLOT_KEY)], @"The result should have a slot value of one for the DAY_SLOT_KEY");
}

- (void)testEncodedResultContainsDayOfYear {
    KZResult *result = [KZResult new];
    result.date = [[KZSimpleDate alloc] initWithMonth:12 day:2 year:2013];
    int expectedDayOfYear = 336;
    
    NSDictionary *encodedResult = [_dataChunk encodedResult:result slot:1];
    NSNumber *encodedDayOfYear = (NSNumber*) [encodedResult objectForKey:@(DAY_OF_YEAR_KEY)];
    
    XCTAssertEqual(expectedDayOfYear, [encodedDayOfYear intValue], @"Day of year should match for 12/2/2013");
}

- (void)testEncodedResultContainsCorrectYear {
    KZResult *result = [KZResult new];
    result.date = [[KZSimpleDate alloc] initWithMonth:12 day:14 year:2013];
    
    NSDictionary *encodedResult = [_dataChunk encodedResult:result slot:1];
    NSNumber *encodedYear = (NSNumber*) [encodedResult objectForKey:@(YEAR_KEY)];
    
    XCTAssertEqual(2013, [encodedYear intValue], @"The year should be equal to 2013");
}

- (void)testEncodedResultContainsCorrectSunRiseTime {
    KZResult *result = [KZResult new];
    result.sun = [KZEvent new];
    result.sun.rise = [[KZSimpleTime alloc] initWithHour:13 minute:15];
    
    NSDictionary *encodedResult = [_dataChunk encodedResult:result slot:1];
    NSNumber *encodedTime = (NSNumber*) [encodedResult objectForKey:@(SUN_RISE_KEY)];
    
    int expectedValue = 13*60+15;
    XCTAssertEqual(expectedValue, [encodedTime intValue], @"The min of day should have been encoded correctly");
}

- (void)testEncodedResultContainsCorrectSunRiseAzimuth {
    KZResult *result = [KZResult new];
    result.sun = [KZEvent new];
    result.sun.riseAzimuth = 302.5;
    
    NSDictionary *encodedResult = [_dataChunk encodedResult:result slot:1];
    NSNumber *encodedSunRiseAzimuth = (NSNumber*) [encodedResult objectForKey:@(SUN_RISE_AZIMUTH_KEY)];
    
    int expectedValue = 303;
    XCTAssertEqual(expectedValue, [encodedSunRiseAzimuth intValue], @"The run rise azimuth should be encoded correctly");
}

- (void)testEncodedResultContainsCorrrectSunSetTime {
    KZResult *result = [KZResult new];
    result.sun = [KZEvent new];
    result.sun.set = [[KZSimpleTime alloc] initWithHour:5 minute:55];
    
    NSDictionary *encodedResult = [_dataChunk encodedResult:result slot:1];
    NSNumber *encodedTime = (NSNumber*) [encodedResult objectForKey:@(SUN_SET_KEY)];
    
    int expected = 5*60 + 55;
    XCTAssertEqual(expected, [encodedTime intValue], @"The sun set time should be encoded correctly");
}

- (void)testEncodedResultContainsSunSetAzimuth {
    KZResult *result = [KZResult new];
    result.sun = [KZEvent new];
    result.sun.setAzimuth = 56.2;
    
    NSDictionary *encodedResult = [_dataChunk encodedResult:result slot:1];
    NSNumber *encodedSunSetAzimuth = (NSNumber*) [encodedResult objectForKey:@(SUN_SET_AZIMUTH_KEY)];
    
    XCTAssertEqual(56, [encodedSunSetAzimuth intValue], @"The run set azimuth should be encoded correctly");
}

@end
