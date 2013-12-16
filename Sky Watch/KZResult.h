//
//  KZResult.h
//  Sky Watch
//
//  Created by Kurt Zoglmann on 12/8/13.
//  Copyright (c) 2013 Kurt Zoglmann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KZEvent.h"
#import "KZSimpleDate.h"
#import "KZMoonEvent.h"


@interface KZResult : NSObject

@property (nonatomic) KZSimpleDate *date;

/**
 Represents the sun crossing the horizon
 */
@property (nonatomic) KZEvent *sun;


@property (nonatomic) KZEvent *astronomicalTwilight;
@property (nonatomic) KZEvent *nauticalTwilight;
@property (nonatomic) KZEvent *civilTwilight;
@property (nonatomic) KZEvent *goldenHour;

@property (nonatomic) KZMoonEvent *moonToday;
@property (nonatomic) KZMoonEvent *moonTomorrow;

@end
