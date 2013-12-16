//
//  KZPebbleDataChunk.h
//  Sky Watch
//
//  Created by Kurt Zoglmann on 12/15/13.
//  Copyright (c) 2013 Kurt Zoglmann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PebbleKit/PebbleKit.h>
#import "KZResult.h"


/**
 The time related events, such as the value for SUN_RISE_KEY, are encoded as
 the minute of the day 0 to 1,4440. e.g. 0 = 12:00am and 14439 = 11:59pm
 
 The watch and iPhone share the same timezone at the time of synchronization.
 */
static const uint32_t DAY_SLOT_KEY                    = 1000; // 8bit int
static const uint32_t DAY_OF_YEAR_KEY                 = 1001; //16bit int
static const uint32_t YEAR_KEY                        = 1002; //16bit int
static const uint32_t SUN_RISE_KEY                    = 1003; //16bit int
static const uint32_t SUN_RISE_AZIMUTH_KEY            = 1004; //16bit int
static const uint32_t SUN_SET_KEY                     = 1005; //16bit int
static const uint32_t SUN_SET_AZIMUTH_KEY             = 1006; //16bit int
static const uint32_t SOLAR_NOON                      = 1007; //16bit int
static const uint32_t SOLAR_MIDNIGHT                  = 1008; //16bit int
static const uint32_t GOLDEN_HOUR_BEGIN_KEY           = 1009; //16bit int
static const uint32_t GOLDEN_HOUR_END_KEY             = 1010; //16bit int
static const uint32_t CIVIL_TWILIGHT_BEGIN_KEY        = 1011; //16bit int
static const uint32_t CIVIL_TWILIGHT_END_KEY          = 1012; //16bit int
static const uint32_t NAUTICAL_TWILIGHT_BEGIN_KEY     = 1013; //16bit int
static const uint32_t NAUTICAL_TWILIGHT_END_KEY       = 1014; //16bit int
static const uint32_t ASTRONOMICAL_TWILIGHT_BEGIN_KEY = 1015; //16bit int
static const uint32_t ASTRONOMICAL_TWILIGHT_END_KEY   = 1016; //16bit int
static const uint32_t MOON_RISE_KEY                   = 1017; //16bit int
static const uint32_t MOON_RISE_AZIMUTH_KEY           = 1018; //16bit int
static const uint32_t MOON_SET_KEY                    = 1019; //16bit int
static const uint32_t MOON_SET_AZIMUTH_KEY            = 1020; //16bit int
static const uint32_t MOON_AGE_KEY                    = 1021; // 8bit int
static const uint32_t MOON_PERCENT_ILLUMINATION       = 1022; // 8bit int



@interface KZPebbleDataChunk : NSObject

- (NSDictionary*) encodedResult:(KZResult*)result slot:(NSInteger)slot;

@end
