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

- (void)testEncodedResultContainsCorrectSolarNoon {
    KZResult *result = [KZResult new];
    result.sun = [KZEvent new];
    result.sun.meridianCrossing = [[KZSimpleTime alloc] initWithHour:14 minute:9];
    
    NSDictionary *encodedResult = [_dataChunk encodedResult:result slot:1];
    NSNumber *encodedSolarNoon = (NSNumber*) [encodedResult objectForKey:@(SOLAR_NOON)];
    
    int expected = 14*60 + 9;
    XCTAssertEqual(expected, [encodedSolarNoon intValue], @"Solar noon should be encoded correctly");
}

- (void)testEncodedResultContainsCorrectSolarMidnight {
    KZResult *result = [KZResult new];
    result.sun = [KZEvent new];
    result.sun.antimeridianCrossing = [[KZSimpleTime alloc] initWithHour:2 minute:30];
    
    NSDictionary *encodedResult = [_dataChunk encodedResult:result slot:1];
    NSNumber *encodedSolarMidnight = (NSNumber*) [encodedResult objectForKey:@(SOLAR_MIDNIGHT)];
    
    int expected = 2*60 + 30;
    XCTAssertEqual(expected, [encodedSolarMidnight intValue], @"Solar midnight should be encoded correctly");
}

- (void)testEncodedResultContainsCorrectGoldenHourBegin {
    KZResult *result = [KZResult new];
    result.goldenHour = [KZEvent new];
    result.goldenHour.rise = [[KZSimpleTime alloc] initWithHour:10 minute:22];
    
    NSDictionary *encodedResult = [_dataChunk encodedResult:result slot:1];
    NSNumber *encodedGoldenHourBegin = (NSNumber*) [encodedResult objectForKey:@(GOLDEN_HOUR_BEGIN_KEY)];
    
    int expected = 10*60 + 22;
    XCTAssertEqual(expected, [encodedGoldenHourBegin intValue], @"The golden hour begin should be encoded correctly");
}

- (void)testEncodedResultContainsCorrectGoldenHourEnd {
    KZResult *result = [KZResult new];
    result.goldenHour = [KZEvent new];
    result.goldenHour.set = [[KZSimpleTime alloc] initWithHour:17 minute:02];
    
    NSDictionary *encodedResult = [_dataChunk encodedResult:result slot:1];
    NSNumber *encodedGoldenHourEnd = (NSNumber*) [encodedResult objectForKey:@(GOLDEN_HOUR_END_KEY)];
    
    int expected = 17*60 + 2;
    XCTAssertEqual(expected, [encodedGoldenHourEnd intValue], @"The golden hour end should be encoded correctly");
}

- (void)testEncodedResultContainsCorrectCivilTwilightBegin {
    KZResult *result = [KZResult new];
    result.civilTwilight = [KZEvent new];
    result.civilTwilight.rise = [[KZSimpleTime alloc] initWithHour:6 minute:10];
    
    NSDictionary *encodedResult = [_dataChunk encodedResult:result slot:1];
    NSNumber *encodedCivilTwilightBegin = [encodedResult objectForKey:@(CIVIL_TWILIGHT_BEGIN_KEY)];
    
    int expected = 6*60 + 10;
    XCTAssertEqual(expected, [encodedCivilTwilightBegin intValue], @"The civil twilight begin should be encoded correctly");
}

- (void)testEncodedResultContainsCorrectCivilTwilightEnd {
    KZResult *result = [KZResult new];
    result.civilTwilight = [KZEvent new];
    result.civilTwilight.set = [[KZSimpleTime alloc] initWithHour:18 minute:2];
    
    NSDictionary *encodedResult = [_dataChunk encodedResult:result slot:1];
    NSNumber *encodedCivilTwilightEnd = [encodedResult objectForKey:@(CIVIL_TWILIGHT_END_KEY)];
    
    int expected = 18*60 + 2;
    XCTAssertEqual(expected, [encodedCivilTwilightEnd intValue], @"The civil twilight end should be encoded correctly");
}

- (void)testEncodedResultContainsCorrectNauticalTwilightBegin {
    KZResult *result = [KZResult new];
    result.nauticalTwilight = [KZEvent new];
    result.nauticalTwilight.rise = [[KZSimpleTime alloc] initWithHour:5 minute:55];
    
    NSDictionary *encodedResult = [_dataChunk encodedResult:result slot:1];
    NSNumber *encodedNauticalTwilightBegin = [encodedResult objectForKey:@(NAUTICAL_TWILIGHT_BEGIN_KEY)];
    
    int expected = 5*60 + 55;
    XCTAssertEqual(expected, [encodedNauticalTwilightBegin intValue], @"The nautical twilight begin should be encoded correctly");
}

- (void)testEncodedResultContainsCorrectNauticalTwilightEnd {
    KZResult *result = [KZResult new];
    result.nauticalTwilight = [KZEvent new];
    result.nauticalTwilight.set = [[KZSimpleTime alloc] initWithHour:19 minute:13];
    
    NSDictionary *encodedResult = [_dataChunk encodedResult:result slot:1];
    NSNumber *encodedNauticalTwilightEnd = [encodedResult objectForKey:@(NAUTICAL_TWILIGHT_END_KEY)];
    
    int expected = 19*60 + 13;
    XCTAssertEqual(expected, [encodedNauticalTwilightEnd intValue], @"The nautical twilight end should be encoded correctly");
}

- (void)testEncodedResultContainsCorrectAstronomicalTwilightBegin {
    KZResult *result = [KZResult new];
    result.astronomicalTwilight = [KZEvent new];
    result.astronomicalTwilight.rise = [[KZSimpleTime alloc] initWithHour:4 minute:30];
    
    NSDictionary *encodedResult = [_dataChunk encodedResult:result slot:1];
    NSNumber *encodedAstronomicalTwilightBegin = [encodedResult objectForKey:@(ASTRONOMICAL_TWILIGHT_BEGIN_KEY)];
    
    int expected = 4*60 + 30;
    XCTAssertEqual(expected, [encodedAstronomicalTwilightBegin intValue], @"The astronomical twilight begin should be encoded correctly");
}

- (void)testEncodedResultContainsCorrectAstronomicalTwilightEnd {
    KZResult *result = [KZResult new];
    result.astronomicalTwilight = [KZEvent new];
    result.astronomicalTwilight.set = [[KZSimpleTime alloc] initWithHour:20 minute:15];
    
    NSDictionary *encodedResult = [_dataChunk encodedResult:result slot:1];
    NSNumber *encodedAstronomicalTwilightEnd = [encodedResult objectForKey:@(ASTRONOMICAL_TWILIGHT_END_KEY)];
    
    int expected = 20*60 + 15;
    XCTAssertEqual(expected, [encodedAstronomicalTwilightEnd intValue], @"The astronomical twilight end should be encoded correctly");
}

- (void)testEncodedResultContainsCorrectMoonRise {
    KZResult *result = [KZResult new];
    result.moonToday = [KZMoonEvent new];
    result.moonToday.rise = [[KZSimpleTime alloc] initWithHour:0 minute:5];
    
    NSDictionary *encodedResult = [_dataChunk encodedResult:result slot:1];
    NSNumber *encodedMoonRise = [encodedResult objectForKey:@(MOON_RISE_KEY)];
    
    int expected = 0*60 + 5;
    XCTAssertEqual(expected, [encodedMoonRise intValue], @"The moon rise should be encoded correctly");
}

- (void)testEncodedResultContainsCorrectMoonRiseAzimuth {
    KZResult *result = [KZResult new];
    result.moonToday = [KZMoonEvent new];
    result.moonToday.riseAzimuth = 123.823;
    
    NSDictionary *encodedResult = [_dataChunk encodedResult:result slot:1];
    NSNumber *encodedMoonRiseAzimuth = [encodedResult objectForKey:@(MOON_RISE_AZIMUTH_KEY)];
    
    XCTAssertEqual(124, [encodedMoonRiseAzimuth intValue], @"The moon rise azimuth should be encoded correctly");
}

- (void)testEncodedResultContainsCorrectMoonSet {
    KZResult *result = [KZResult new];
    result.moonToday = [KZMoonEvent new];
    result.moonToday.set = [[KZSimpleTime alloc] initWithHour:20 minute:50];
    
    NSDictionary *encodedResult = [_dataChunk encodedResult:result slot:1];
    NSNumber *encodedMoonSet = [encodedResult objectForKey:@(MOON_SET_KEY)];
    
    int expected = 20*60 + 50;
    XCTAssertEqual(expected, [encodedMoonSet intValue], @"The moon set should be encoded correctly");
}

- (void)testEncodedResultContainsCorrectMoomSetAzimuth {
    KZResult *result = [KZResult new];
    result.moonToday = [KZMoonEvent new];
    result.moonToday.setAzimuth = 82.1;
    
    NSDictionary *encodedResult = [_dataChunk encodedResult:result slot:1];
    NSNumber *encodedMoonSetAzimuth = [encodedResult objectForKey:@(MOON_SET_AZIMUTH_KEY)];
    
    XCTAssertEqual(82, [encodedMoonSetAzimuth intValue], @"The moon set azimuth should be encoded correctly");
}

- (void)testEncodedResultContainsMoonAge {
    KZResult *result = [KZResult new];
    result.moonToday = [KZMoonEvent new];
    result.moonToday.ageInDays = 13;
    
    NSDictionary *encodedResult = [_dataChunk encodedResult:result slot:1];
    NSNumber *encodedMoonAgeInDays = [encodedResult objectForKey:@(MOON_AGE_KEY)];
    
    XCTAssertEqual(13, [encodedMoonAgeInDays intValue], @"The moon age should be encoded correctly");
}

- (void)testEncodedResultContaisnPercentIllumination {
    KZResult *result = [KZResult new];
    result.moonToday = [KZMoonEvent new];
    result.moonToday.illuminationPercent = 55.332;
    
    NSDictionary *encodedResult = [_dataChunk encodedResult:result slot:1];
    NSNumber *encodedIllumination = [encodedResult objectForKey:@(MOON_PERCENT_ILLUMINATION)];
    
    int expected = 55;
    XCTAssertEqual(expected, [encodedIllumination intValue], @"The moon's percent illumination should be encoded correctly");
}


@end
