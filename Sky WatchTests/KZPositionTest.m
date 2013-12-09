//
//  KZPositionTest.m
//  Sky Watch
//
//  Created by Kurt Zoglmann on 12/8/13.
//  Copyright (c) 2013 Kurt Zoglmann. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KZPosition.h"

@interface KZPositionTest : XCTestCase

@end

@implementation KZPositionTest


- (void)setUp {
    [super setUp];
}


- (void)tearDown {
    [super tearDown];
}


- (void)testInitWithRightAscentionDeclination {
    float rightAscention = 10.0;
    float declination = 20.0;
    
    KZPosition* pos = [[KZPosition alloc] initWithRightAscention:rightAscention declination:declination];

    XCTAssertEqual(rightAscention, pos.rightAscention, @"The initializer should set the rightAscention property to the incoming rightAscention parameter");
    XCTAssertEqual(declination, pos.declination, @"The initializer should set the declination property to the incoming declination parameter");
    
}

@end
