//
//  KZCalculatorTests.m
//  Sky Watch
//
//  Created by Kurt Zoglmann on 12/8/13.
//  Copyright (c) 2013 Kurt Zoglmann. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KZCalculator.h"
#import "KZSimpleDate.h"
#import "KZGPSCoordinate.h"
#import "KZResult.h"


@interface KZCalculatorTests : XCTestCase
@end


@implementation KZCalculatorTests {
    KZCalculator *calculator;
}

- (void)setUp {
    [super setUp];
    calculator = [KZCalculator new];
}


- (void)tearDown {
    calculator = nil;
    [super tearDown];
}


/** 
  not exactly a "unit" test, but it'll have to do for the moment. Mainly confirming that this Objective-C implementation
  is equal to the Java reference implementation for a given date, timezone, longitude, and latitude.
 **/
- (void)testExample {
    KZSimpleDate *date = [[KZSimpleDate alloc] initWithMonth:11 day:26 year:2013];
    KZGPSCoordinate *gps = [[KZGPSCoordinate alloc] initWithLatitude:39.185768 longitude:-96.575556];

    
    KZResult *result = [calculator calculateWithGps:gps utcToLocal:-6 date:date];
    
    
    XCTAssertEqual(7, result.sun.rise.hour, @"The sun rise should be at 7:21am, so the hour component should be 7");
    XCTAssertEqual(21, result.sun.rise.min, @"The sun rise should be at 7:21am, so the min component should be 21");
    XCTAssertEqualWithAccuracy(116.8, result.sun.riseAzimuth, .1, @"sun rise azimuth should match within .1 degree");
    
    XCTAssertEqual(17, result.sun.set.hour, @"The sunset should be at 17:05, so the hour component should be 17");
    XCTAssertEqual(5,  result.sun.set.min,  @"The sunset should be at 17:05, so the min component should be 5");
    XCTAssertEqualWithAccuracy(243.1, result.sun.setAzimuth, .1, @"sun set azimuth should match within .1 degree");
    
    XCTAssertEqual(12, result.sun.meridianCrossing.hour, @"Solar noon should be 12:13, so the hour component should be equal to 12");
    XCTAssertEqual(13, result.sun.meridianCrossing.min, @"Solar noon should be 12:13, so the min component should be equal to 13");
    XCTAssertEqual(9, result.sun.risenAmount.hour, @"The sun should be up 9hr 44min, so the hour component should be equal to 9");
    XCTAssertEqual(44, result.sun.risenAmount.min, @"The sun should be up 9hr 44min, so the min component should be equal to 44");
    
    XCTAssertEqual(0, result.sun.antimeridianCrossing.hour, @"Solar midnight should be 0:13, so the hour component should be equal to 0");
    XCTAssertEqual(13, result.sun.antimeridianCrossing.min, @"Solar midnight should be 0:13, so the min component should be equal to 0");
    XCTAssertEqual(14, result.sun.setAmount.hour, @"The sun should be down 14hr 16min, so the hour component should be equal to 14");
    XCTAssertEqual(16, result.sun.setAmount.min,  @"The sun should be down 14hr 16min, so the min component should be equal to 16");
    
    XCTAssertEqual(8, result.goldenHour.rise.hour, @"The golden hour should begin at 8:28am, so the hour component should be equal to 8");
    XCTAssertEqual(28, result.goldenHour.rise.min, @"The golden hour should begin at 8:28am, so the min component should be equal to 28");
    XCTAssertEqual(15, result.goldenHour.set.hour, @"The golden hour should end at 15:58, so the hour component should be equal to 15");
    XCTAssertEqual(58, result.goldenHour.set.min,  @"The golden hour should end at 15:58, so the min component should be equal to 58");

    XCTAssertEqual(6, result.civilTwilight.rise.hour, @"The civil twilight should begin at 6:52am, so the hour component should be equal to 6");
    XCTAssertEqual(52, result.civilTwilight.rise.min, @"The civil twilight should begin at 6:52am, so the min component should be equal to 52");
    XCTAssertEqual(17, result.civilTwilight.set.hour, @"The civil twilight should end at 17:34, so the hour component should be equal to 17");
    XCTAssertEqual(34, result.civilTwilight.set.min,  @"The civil twilight should end at 17:34, so the min component should be equal to 34");
    XCTAssertEqual(13, result.civilTwilight.setAmount.hour, @"Civil night should be 13hr 18min long, so the hour component should be equal to 13");
    XCTAssertEqual(18, result.civilTwilight.setAmount.min,  @"Civil night should be 13hr 18min long, so the min component should be equal to 18");
    
    XCTAssertEqual(6, result.nauticalTwilight.rise.hour, @"The nautical twilight should begin at 6:19am, so the hour component should be equal to 6");
    XCTAssertEqual(19, result.nauticalTwilight.rise.min, @"The nautical twilight should begin at 6:19am, so the min component should be equal to 19");
    XCTAssertEqual(18, result.nauticalTwilight.set.hour, @"The nautical twilight should end at 18:08, so the hour component should be equal to 18");
    XCTAssertEqual(8, result.nauticalTwilight.set.min,  @"The nautical twilight should end at 18:08, so the min component should be equal to 8");
    XCTAssertEqual(12, result.nauticalTwilight.setAmount.hour, @"nautical night should be 12hr 11min long, so the hour component should be equal to 12");
    XCTAssertEqual(11, result.nauticalTwilight.setAmount.min,  @"nautical night should be 12hr 11min long, so the min component should be equal to 11");
    
    XCTAssertEqual(5, result.astronomicalTwilight.rise.hour, @"The astronomical twilight should begin at 5:46am, so the hour component should be equal to 5");
    XCTAssertEqual(46, result.astronomicalTwilight.rise.min, @"The astronomical twilight should begin at 5:46am, so the min component should be equal to 46");
    XCTAssertEqual(18, result.astronomicalTwilight.set.hour, @"The astronomical twilight should end at 18:40, so the hour component should be equal to 18");
    XCTAssertEqual(40, result.astronomicalTwilight.set.min,  @"The astronomical twilight should end at 18:40, so the min component should be equal to 40");
    XCTAssertEqual(11, result.astronomicalTwilight.setAmount.hour, @"astronomical night should be 11hr 6min long, so the hour component should be equal to 11");
    XCTAssertEqual(06, result.astronomicalTwilight.setAmount.min,  @"astronomical night should be 11hr 6min long, so the min component should be equal to 6");
    
    XCTAssertEqual(0, result.moonToday.rise.hour, @"Today's moon rise should be 0:28, so the hour component should be 0");
    XCTAssertEqual(28, result.moonToday.rise.min, @"Today's moon rise should be 0:28, so the min component should be 28");
    XCTAssertEqualWithAccuracy(84.9, result.moonToday.riseAzimuth, .1, @"Today's moon rise should be at azimuth 84.9 and be within .1 degree");
    XCTAssertEqual(13, result.moonToday.set.hour, @"Today's moon set should be 13:10, so the hour component should be 13");
    XCTAssertEqual(10, result.moonToday.set.min, @"Today's moon set should be 13:10, so the min component should be 10");
    XCTAssertEqualWithAccuracy(272.2, result.moonToday.setAzimuth, .1, @"Today's moon set should be at azimuth 272.2 and be within .1 degree");
    XCTAssertEqualWithAccuracy(23.2, result.moonToday.ageInDays, .1, @"Today's moon age should be 23.2 and be within 1/10 of a day");
    XCTAssertEqualWithAccuracy(41.0, result.moonToday.illuminationPercent, .1, @"Today's moon should be illuminated 41.0%% and be within .1 degree of reference");
    
    XCTAssertEqual(1, result.moonTomorrow.rise.hour, @"Tomorrow's moon rise should be 1:27, so the hour component should be 1");
    XCTAssertEqual(27, result.moonTomorrow.rise.min, @"Tomorrow's moon rise should be 1:27, so the min component should be 27");
    XCTAssertEqualWithAccuracy(90.5, result.moonTomorrow.riseAzimuth, .1, @"Tomorrow's moon rise should be at azimuth 90.5 and be within .1 degree");
    XCTAssertEqual(13, result.moonTomorrow.set.hour, @"Tomorrow's moon set should be 13:41, so the hour component should be 13");
    XCTAssertEqual(41, result.moonTomorrow.set.min, @"Tomorrow's moon set should be 13:41, so the min component should be 41");
    XCTAssertEqualWithAccuracy(266.8, result.moonTomorrow.setAzimuth, .1, @"Tomorrow's moon set should be at azimuth 266.8 and be within .1 degree");
    XCTAssertEqualWithAccuracy(24.2, result.moonTomorrow.ageInDays, .1, @"Tomorrow's moon age should be 24.2 and be within 1/10 of a day");
    XCTAssertEqualWithAccuracy(30.8, result.moonTomorrow.illuminationPercent, .1, @"Tomorrow's moon should be illuminated 31.8%% and be within .1 degree of reference");

}

@end
