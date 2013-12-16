//
//  KZPebbleDataChunk.m
//  Sky Watch
//
//  Created by Kurt Zoglmann on 12/15/13.
//  Copyright (c) 2013 Kurt Zoglmann. All rights reserved.
//

#import "KZPebbleDataChunk.h"


@implementation KZPebbleDataChunk


- (NSDictionary*) encodedResult:(KZResult*)result slot:(NSInteger)slot {
    
    NSCalendar *gregorian =
    [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDate* resultDate = [result.date convertToNSDate];
    
    NSDateComponents *comps = [gregorian components:NSYearCalendarUnit fromDate:resultDate];
    NSInteger year = comps.year;
    
    NSUInteger dayOfYear =
    [gregorian ordinalityOfUnit:NSDayCalendarUnit
                         inUnit:NSYearCalendarUnit forDate:resultDate];

    
    NSDictionary *ret = @{
                          @(DAY_SLOT_KEY)         : [NSNumber numberWithUint8: slot],
                          @(DAY_OF_YEAR_KEY)      : [NSNumber numberWithUint16: dayOfYear],
                          @(YEAR_KEY)             : [NSNumber numberWithUint16: year],
                          @(SUN_RISE_KEY)         : [NSNumber numberWithUint16: [[self convertToMinuteOfDay:result.sun.rise] int16Value]],
                          @(SUN_RISE_AZIMUTH_KEY) : [NSNumber numberWithUint16: lround(result.sun.riseAzimuth)],
                          @(SUN_SET_KEY)          : [NSNumber numberWithUint16: [[self convertToMinuteOfDay:result.sun.set] int16Value]],
                          @(SUN_SET_AZIMUTH_KEY)  : [NSNumber numberWithUint16: lround(result.sun.setAzimuth)],
                          @(SOLAR_NOON)           : [NSNumber numberWithUint16: [[self convertToMinuteOfDay:result.sun.meridianCrossing] int16Value]],
                          @(SOLAR_MIDNIGHT)       : [NSNumber numberWithUint16: [[self convertToMinuteOfDay:result.sun.antimeridianCrossing] int16Value]],
                          @(GOLDEN_HOUR_BEGIN_KEY): [NSNumber numberWithUint16: [[self convertToMinuteOfDay:result.goldenHour.rise] int16Value]],
                          @(GOLDEN_HOUR_END_KEY)  : [NSNumber numberWithUint16: [[self convertToMinuteOfDay:result.goldenHour.set] int16Value]],
                          @(CIVIL_TWILIGHT_BEGIN_KEY)        : [NSNumber numberWithUint16: [[self convertToMinuteOfDay:result.civilTwilight.rise] int16Value]],
                          @(CIVIL_TWILIGHT_END_KEY)          : [NSNumber numberWithUint16: [[self convertToMinuteOfDay:result.civilTwilight.set] int16Value]],
                          @(NAUTICAL_TWILIGHT_BEGIN_KEY)     : [NSNumber numberWithUint16: [[self convertToMinuteOfDay:result.nauticalTwilight.rise] int16Value]],
                          @(NAUTICAL_TWILIGHT_END_KEY)       : [NSNumber numberWithUint16: [[self convertToMinuteOfDay:result.nauticalTwilight.set] int16Value]],
                          @(ASTRONOMICAL_TWILIGHT_BEGIN_KEY) : [NSNumber numberWithUint16: [[self convertToMinuteOfDay:result.astronomicalTwilight.rise] int16Value]],
                          @(ASTRONOMICAL_TWILIGHT_END_KEY)   : [NSNumber numberWithUint16: [[self convertToMinuteOfDay:result.astronomicalTwilight.set] int16Value]],
                          @(MOON_RISE_KEY)                   : [NSNumber numberWithUint16: [[self convertToMinuteOfDay:result.moonToday.rise] int16Value]],
                          @(MOON_RISE_AZIMUTH_KEY)           : [NSNumber numberWithUint16: lround(result.moonToday.riseAzimuth)],
                          @(MOON_SET_KEY)                    : [NSNumber numberWithUint16: [[self convertToMinuteOfDay:result.moonToday.set] int16Value]],
                          @(MOON_SET_AZIMUTH_KEY)            : [NSNumber numberWithUint16: lround(result.moonToday.setAzimuth)],
                          @(MOON_AGE_KEY)                    : [NSNumber numberWithUint8: result.moonToday.ageInDays],
                          @(MOON_PERCENT_ILLUMINATION)       : [NSNumber numberWithUint8: lround(result.moonToday.illuminationPercent)]
                          };

    
    
    return ret;
}

- (NSNumber*) convertToMinuteOfDay:(KZSimpleTime*) time {
    return @(time.hour*60 + time.min);
}

@end
