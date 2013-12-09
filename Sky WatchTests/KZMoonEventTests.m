//
//  KZMoonEventTests.m
//  Sky Watch
//
//  Created by Kurt Zoglmann on 12/8/13.
//  Copyright (c) 2013 Kurt Zoglmann. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KZMoonEvent.h"

@interface KZMoonEventTests : XCTestCase

@end

@implementation KZMoonEventTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

/**
 This is mainly to test my understand about a subtlety in Objective-C syntax.
 */
- (void)testInitWithEvent
{
    KZEvent *event = [KZEvent new];
    
    KZSimpleTime *rise = [KZSimpleTime new]; event.rise = rise;
    KZSimpleTime *set = [KZSimpleTime new]; event.set = set;
    double riseAzimuth = 1; event.riseAzimuth = riseAzimuth;
    double setAzimuth = 2; event.setAzimuth = setAzimuth;
    HorizonToHorizonCrossing type = RisenAndSet; event.type = type;
    KZSimpleTime *meridianCrossing = [KZSimpleTime new]; event.meridianCrossing = meridianCrossing;
    KZSimpleTime *antimeridianCrossing = [KZSimpleTime new]; event.antimeridianCrossing = antimeridianCrossing;
    KZSimpleTime *risenAmount = [KZSimpleTime new]; event.risenAmount = risenAmount;
    KZSimpleTime *setAmount = [KZSimpleTime new]; event.setAmount = setAmount;
    
    KZMoonEvent *moonEvent = [[KZMoonEvent alloc] initWithEvent:event];
  
    XCTAssertTrue(rise == moonEvent.rise, @"The rise should have been copied by the initializer");
    XCTAssertTrue(set == moonEvent.set, @"The set should have been copied by the initializer");
    XCTAssertTrue(riseAzimuth == moonEvent.riseAzimuth, @"The riseAzimuth should have been copied by the initializer");
    XCTAssertTrue(type == moonEvent.type, @"The type should have been copied by the initializer");
    XCTAssertTrue(meridianCrossing == moonEvent.meridianCrossing, @"The meridianCrossing should have been copied by the initilizer");
    XCTAssertTrue(antimeridianCrossing == moonEvent.antimeridianCrossing, @"The antimerdianCrossing should have been copied by the initilizer");
    XCTAssertTrue(risenAmount == moonEvent.risenAmount, @"The risenAmount should have been copied by the initilizer");
    XCTAssertTrue(setAmount == moonEvent.setAmount, @"The setAmount should have been copied by the initilzer");
}

@end
