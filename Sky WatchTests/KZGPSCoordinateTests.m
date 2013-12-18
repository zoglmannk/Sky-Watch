//
//  KZGPSCoordinateTests.m
//  Sky Watch
//
//  Created by Kurt Zoglmann on 12/8/13.
//  Copyright (c) 2013 Kurt Zoglmann. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KZGPSCoordinate.h"

@interface KZGPSCoordinateTests : XCTestCase

@end

@implementation KZGPSCoordinateTests

- (void)setUp {
    [super setUp];
}


- (void)tearDown {
    [super tearDown];
}


- (void)testInitWithLatitudeLongitude {
    double latitude = 39.19877585027292;
    double longitude = -96.61550760278163;
    
    KZGPSCoordinate *coordinate = [[KZGPSCoordinate alloc] initWithLatitude:latitude longitude:longitude];
    
    XCTAssertEqual(latitude, coordinate.latitude, @"The initializer should set the latitude property to the incoming latitude parameter");
    XCTAssertEqual(longitude, coordinate.longitude, @"The initializer should set the longitude property to the incoming longitude parameter");
}

- (void)testDescription {
    double latitude = 39.19877585027292;
    double longitude = -96.61550760278163;
    KZGPSCoordinate *coordinate = [[KZGPSCoordinate alloc] initWithLatitude:latitude longitude:longitude];
    
    NSString *description = [coordinate description];
    
    XCTAssertEqualObjects(@"KZGPSCoordinate(latitude: 39.199, longitude: -96.616)", description, @"The description of the KZGGPSCoordinate should given the initializer");
}

@end
