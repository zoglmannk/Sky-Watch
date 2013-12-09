//
//  KZCalculator.m
//  Sky Watch
//
//  Created by Kurt Zoglmann on 12/7/13.
//  Copyright (c) 2013 Kurt Zoglmann. All rights reserved.
//

#import "KZCalculator.h"


static const double DAYS_IN_LUNAR_MONTH = 29.530588853;
static const int NEW_STANDARD_EPOC = 2451545; // January 1, 2000 at noon
static const int NUM_DAYS_IN_CENTURY = 36525; // 365 days * 100 years + 25 extra days for leap years
static const int HOURS_IN_DAY = 24;

static const double DR = M_PI/180.0; //degrees to radians constant
static const double K1 = 15.0 * DR * 1.0027379;


/**
 A TestResult is internal to the core calculating algorithm and should not be exposed
 to the outside world. It holds intermediate results.
 */
@interface KZTestResult : NSObject
@property (nonatomic) KZSimpleTime* rise;
@property (nonatomic) KZSimpleTime* set;
@property (nonatomic) double riseAzimuth;
@property (nonatomic) double setAzimuth;
@property (nonatomic) double v;
@end

@implementation KZTestResult
@end

/**
 A small immutable class to represent an amount relative to the horizon for the
 core calculation
 */
@interface KZOffset : NSObject
@property (nonatomic, readonly) double fromHorizon;
@property (nonatomic, readonly) BOOL accountForAtmosphericRefraction;
- (id) initWithFromHorizon:(double)fromHorizon accountForAtmosphericRefraction:(BOOL) accountForAtmosphericRefraction;
@end

@implementation KZOffset
- (id) initWithFromHorizon:(double)fromHorizon accountForAtmosphericRefraction:(BOOL) accountForAtmosphericRefraction {
    self = [super init];
    if (self) {
        self->_fromHorizon = fromHorizon;
        self->_accountForAtmosphericRefraction = accountForAtmosphericRefraction;
    }
    return self;
}
@end


@implementation KZCalculator {
    KZOffset* _SUNRISE_SUNSET_OFFSET;
    KZOffset* _CIVIL_TWILIGHT_OFFSET;
    KZOffset* _NAUTICAL_TWILIGHT_OFFSET;
    KZOffset* _ASTRONOMICAL_TWILIGHT_OFFSET;
    KZOffset* _GOLDEN_HOUR_OFFSET;
    KZOffset* _MOONRISE_MOONSET_OFFSET;
}


- (id) init {
    
    // Note that the definition of civil, nautical, and astronomical twilight is defined
	// respectively as 6, 12, and 18 degrees below the horizon. I'm choosing a slightly
	// different astronomical offset to better match published times over a wide range
	// of dates. Negative values mean below the horizon. Positive are above the horizon.
    
    self = [super init];
    if (self) {
        self->_SUNRISE_SUNSET_OFFSET        = [[KZOffset alloc] initWithFromHorizon: 0     accountForAtmosphericRefraction: YES];
        self->_CIVIL_TWILIGHT_OFFSET        = [[KZOffset alloc] initWithFromHorizon:-6     accountForAtmosphericRefraction: NO];
        self->_NAUTICAL_TWILIGHT_OFFSET     = [[KZOffset alloc] initWithFromHorizon:-12    accountForAtmosphericRefraction: NO];
        self->_ASTRONOMICAL_TWILIGHT_OFFSET = [[KZOffset alloc] initWithFromHorizon:-17.8  accountForAtmosphericRefraction: NO];
        self->_GOLDEN_HOUR_OFFSET           = [[KZOffset alloc] initWithFromHorizon: 10.0  accountForAtmosphericRefraction: NO];
        self->_MOONRISE_MOONSET_OFFSET      = [[KZOffset alloc] initWithFromHorizon: 0     accountForAtmosphericRefraction: NO];
    }
    return self;
}



/**
 * @param gps         location of user
 * @param utcToLocal  offset from UTC (West is negative)
 * @param date        date of interest for calculation
 */
- (KZResult*) calculateWithGps:(KZGPSCoordinate*) gps
                    utcToLocal:(int) utcToLocal
                          date:(KZSimpleDate*) date {
    
    double timeZoneShift = -1  * ((double)utcToLocal)/HOURS_IN_DAY;
    
    int julianDate = [self calculateJulianDateWith:date]; //note that the julianDate is truncated
    double daysFromEpoc = (julianDate - NEW_STANDARD_EPOC) + 0.5;
    
    
    double lst     = [self calculateLstWithDaysFromEpoc:daysFromEpoc   timeZoneShift:timeZoneShift longitude:gps.longitude];
    double nextLst = [self calculateLstWithDaysFromEpoc:daysFromEpoc+1 timeZoneShift:timeZoneShift longitude:gps.longitude];
    
    daysFromEpoc = daysFromEpoc + timeZoneShift;
    KZResult* ret = [KZResult new];
    
    
    //calculate Sun related times
    KZPosition* sunToday    = [self calculateSunPosition:daysFromEpoc];
    KZPosition* sunTomorrow = [self calculateSunPosition:daysFromEpoc+1];
    sunTomorrow = [self ensureSecondAscentionGreaterFromFirst:sunToday second:sunTomorrow];
    
    ret.sun                  = [self calculateWithOffset:_SUNRISE_SUNSET_OFFSET gps:gps lst:lst today:sunToday tomorrow: sunTomorrow];
    ret.goldenHour           = [self calculateWithOffset:_GOLDEN_HOUR_OFFSET gps:gps lst:lst today:sunToday tomorrow:sunTomorrow];
    ret.civilTwilight        = [self calculateWithOffset:_CIVIL_TWILIGHT_OFFSET gps:gps lst:lst today:sunToday tomorrow:sunTomorrow];
    ret.nauticalTwilight     = [self calculateWithOffset:_NAUTICAL_TWILIGHT_OFFSET gps:gps lst:lst today:sunToday tomorrow:sunTomorrow];
    ret.astronomicalTwilight = [self calculateWithOffset:_ASTRONOMICAL_TWILIGHT_OFFSET gps:gps lst:lst today:sunToday tomorrow:sunTomorrow];
    
    
    //calculate today moon
    KZPosition* moonToday    = [self calculateMoonPosition:daysFromEpoc];
    KZPosition* moonTomorrow = [self calculateMoonPosition:daysFromEpoc+1];
    moonTomorrow = [self ensureSecondAscentionGreaterFromFirst:moonToday second:moonTomorrow];
    ret.moonToday = [[KZMoonEvent alloc] initWithEvent:
                        [self calculateWithOffset:_MOONRISE_MOONSET_OFFSET gps:gps lst:lst today:moonToday tomorrow:moonTomorrow]];
    ret.moonToday.ageInDays = [self calculateMoonsAgeWithJulianDate:julianDate+1];
    ret.moonToday.illuminationPercent = [self calculateMoonIlluminationPercentFromAge:ret.moonToday.ageInDays];
    
    
    //calculate tomorrow moon
    moonTomorrow = [self calculateMoonPosition:daysFromEpoc+1];
    KZPosition* moonDayAfter = [self calculateMoonPosition:daysFromEpoc+2];
    moonDayAfter = [self ensureSecondAscentionGreaterFromFirst:moonTomorrow second:moonDayAfter];
    ret.moonTomorrow = [[KZMoonEvent alloc] initWithEvent:
                        [self calculateWithOffset:_MOONRISE_MOONSET_OFFSET gps:gps lst:nextLst today:moonTomorrow tomorrow:moonDayAfter]];
    ret.moonTomorrow.ageInDays = [self calculateMoonsAgeWithJulianDate:(julianDate+2)];
    ret.moonTomorrow.illuminationPercent = [self calculateMoonIlluminationPercentFromAge:ret.moonTomorrow.ageInDays];
    
    return ret; 
}


- (double) calculateMoonsAgeWithJulianDate:(double) julianDate {
    double temp=(julianDate-2451550.1)/DAYS_IN_LUNAR_MONTH;
    double ret = temp - ((int) temp);
    
    if(ret < 0) {
        ret++;
    }
    ret = ret*DAYS_IN_LUNAR_MONTH;
    
    return ret;
}


/**
 * Until I find a more accurate formula, this will have to do. Seems to be accurate to within +/- 5%.
 */
- (double) calculateMoonIlluminationPercentFromAge:(double) ageInDaysSinceNewMoon {
    return .5 * (1 + cos( (round(ageInDaysSinceNewMoon)+DAYS_IN_LUNAR_MONTH/2)/DAYS_IN_LUNAR_MONTH*2*M_PI)) * 100;
}


- (KZPosition*) ensureSecondAscentionGreaterFromFirst:(KZPosition*) first second:(KZPosition*) second {
    if (second.rightAscention < first.rightAscention) {
        double ascention = second.rightAscention+2*M_PI;
        second = [[KZPosition alloc] initWithRightAscention:ascention declination:second.declination];
    }
    
    return second;
}


- (KZEvent*) calculateWithOffset:(KZOffset*) offset
                             gps:(KZGPSCoordinate*) gps
                             lst:(double) lst
                           today:(KZPosition*) today
                        tomorrow:(KZPosition*) tomorrow {
    
    double previousAscention   = today.rightAscention;
    double previousDeclination = today.declination;
    
    double changeInAscention   = tomorrow.rightAscention - today.rightAscention;
    double changeInDeclination = tomorrow.declination    - today.declination;
    
    double previousV = 0; //arbitrary initial value
    
    KZTestResult* testResult = [KZTestResult new];
    
    for(int hourOfDay=0; hourOfDay<HOURS_IN_DAY; hourOfDay++) {
        
        double fractionOfDay = (hourOfDay+1) / ((double)HOURS_IN_DAY);
        double asention    = today.rightAscention + fractionOfDay*changeInAscention;
        double declination = today.declination    + fractionOfDay*changeInDeclination;
        
        KZTestResult* intermediateTestResult =
        [self testHourForEventWithHourOfDay: hourOfDay
                                     offset: offset
                          previousAscention: previousAscention
                                  ascention: asention
                        previousDeclination: previousDeclination
                                declination: declination
                                  previousV: previousV
                                        gps: gps
                                        lst: lst];
        
        if(intermediateTestResult.rise != nil) {
            testResult.rise       = intermediateTestResult.rise;
            testResult.riseAzimuth = intermediateTestResult.riseAzimuth;
        }
        
        if(intermediateTestResult.set != nil) {
            testResult.set       = intermediateTestResult.set;
            testResult.setAzimuth = intermediateTestResult.setAzimuth;
        }
        
        previousAscention   = asention;
        previousDeclination = declination;
        previousV           = intermediateTestResult.v;
        
    }
    
    
    return [self createEventWithTestResult:testResult];
}


- (KZEvent*) createEventWithTestResult:(KZTestResult*) testResult {
    KZEvent* ret = [KZEvent new];
    
    ret.rise = testResult.rise;
    ret.set  = testResult.set;
    ret.riseAzimuth = testResult.riseAzimuth;
    ret.setAzimuth  = testResult.setAzimuth;
    ret.type =  [self findTypeOfDayWithResult:testResult lastV:testResult.v];
    
    [self setRisenAndSetAmountsForEvent:ret];
    [self setMeridianCrossingWithEvent:ret];
    [self setAntimeridianCrossingWithEvent:ret];
    
    return ret;
}


/**
 * Test an hour for an event
 */
- (KZTestResult*) testHourForEventWithHourOfDay:(int) hourOfDay
                                         offset:(KZOffset*) offset
                              previousAscention:(double) previousAscention
                                      ascention:(double) ascention
                            previousDeclination:(double) previousDeclination
                                    declination:(double) declination
                                      previousV:(double) previousV
                                            gps:(KZGPSCoordinate*) gps
                                            lst:(double) LST {
    
    
    KZTestResult* ret = [KZTestResult new];
    
    //90.833 is for atmospheric refraction when sun is at the horizon.
    //ie the sun slips below the horizon at sunset before you actually see it go below the horizon
    double zenithDistance = DR * (offset.accountForAtmosphericRefraction ? 90.833 : 90.0);
    
    double s = sin(gps.latitude*DR);
    double c = cos(gps.latitude*DR);
    double z = cos(zenithDistance) + offset.fromHorizon*DR;
    
    double L0 = LST + hourOfDay*K1;
    double L2 = L0 + K1;
    
    double H0 = L0 - previousAscention;
    double H2 = L2 - ascention;
    
    double H1 = (H2+H0) / 2.0; //  Hour angle,
    double D1 = (declination+previousDeclination) / 2.0; //  declination at half hour
    
    if (hourOfDay == 0) {
        previousV = s * sin(previousDeclination) + c*cos(previousDeclination)*cos(H0)-z;
    }
    
    double v = s*sin(declination) + c*cos(declination)*cos(H2) - z;
    
    if([self objectCrossedHorizonWithPreviousV:previousV V:v]) {
        double v1 = s*sin(D1) + c*cos(D1)*cos(H1) - z;
        
        double a = 2*v - 4*v1 + 2*previousV;
        double b = 4*v1 - 3*previousV - v;
        double d = b*b - 4*a*previousV;
        
        if (d >= 0) {
            d = sqrt(d);
            
            double e = (-b+d) / (2*a);
            if (e>1 || e<0) {
                e = (-b-d) / (2*a);
            }
            
            double H7 = H0 + e*(H2-H0);
            double N7 = -1 * cos(D1)*sin(H7);
            double D7 = c*sin(D1) - s*cos(D1)*cos(H7);
            double azimuth = atan(N7/D7)/DR;
            
            if(D7 < 0) {
                azimuth = azimuth+180;
            }
            
            if(azimuth < 0) {
                azimuth = azimuth+360;
            }
            
            if(azimuth > 360) {
                azimuth = azimuth-360;
            }
            
            
            double T3=hourOfDay + e + 1/120; //Round off
            int hour = (int) T3;
            int min = (int) ((T3-hour)*60);
            
            
            if (previousV<0 && v>0) {
                ret.rise = [[KZSimpleTime alloc] initWithHour:hour minute:min];
                ret.riseAzimuth = azimuth;
            }
            
            if (previousV>0 && v<0) {
                ret.set = [[KZSimpleTime alloc] initWithHour:hour minute:min];
                ret.setAzimuth = azimuth;
            }
        }
        
    }
    
    ret.V = v;
    return ret;
    
}


- (BOOL) objectCrossedHorizonWithPreviousV:(double)previousV V:(double)v {
    return [self signWithVal:previousV] != [self signWithVal:v];
}

/**
 @returns 0 when value <= 0 otherwise 1
 */
- (int) signWithVal:(float) val {
    return val == 0 ? 0 : (val > 0 ? 1 : 0);
}


/**
 * drops any full revolutions and then converts revolutions to radians
 */
- (double) revolutionsToTruncatedRadians:(double) revolutions {
    return 2*M_PI*(revolutions - ((int) revolutions));
}


- (KZPosition*) calculateSunPosition:(double) daysFromEpoc {
    double numCenturiesSince1900 = daysFromEpoc/NUM_DAYS_IN_CENTURY + 1;
    
    //   Fundamental arguments
    //   (Van Flandern & Pulkkinen, 1979)
    double meanLongitudeOfSun = [self revolutionsToTruncatedRadians: (.779072 + .00273790931*daysFromEpoc)];
    double meanAnomalyOfSun   = [self revolutionsToTruncatedRadians: (.993126 + .00273777850*daysFromEpoc)];
    
    double meanLongitudeOfMoon           = [self revolutionsToTruncatedRadians: (.606434 + .03660110129*daysFromEpoc)];
    double longitudeOfLunarAscendingNode = [self revolutionsToTruncatedRadians: (.347343 - .00014709391*daysFromEpoc)];
    double meanAnomalyOfVenus            = [self revolutionsToTruncatedRadians: (.140023 + .00445036173*daysFromEpoc)];
    double meanAnomalyOfMars             = [self revolutionsToTruncatedRadians: (.053856 + .00145561327*daysFromEpoc)];
    double meanAnomalyOfJupiter          = [self revolutionsToTruncatedRadians: (.056531 + .00023080893*daysFromEpoc)];
    
    
    double v;
    v =     .39785 * sin(meanLongitudeOfSun);
    v = v - .01000 * sin(meanLongitudeOfSun-meanAnomalyOfSun);
    v = v + .00333 * sin(meanLongitudeOfSun+meanAnomalyOfSun);
    v = v - .00021 * numCenturiesSince1900 * sin(meanLongitudeOfSun);
    v = v + .00004 * sin(meanLongitudeOfSun+2*meanAnomalyOfSun);
    v = v - .00004 * cos(meanLongitudeOfSun);
    v = v - .00004 * sin(longitudeOfLunarAscendingNode-meanLongitudeOfSun);
    v = v + .00003 * numCenturiesSince1900 * sin(meanLongitudeOfSun-meanAnomalyOfSun);
    
    double u;
    u = 1 - .03349 * cos(meanAnomalyOfSun);
    u = u - .00014 * cos(2*meanLongitudeOfSun);
    u = u + .00008 * cos(meanLongitudeOfSun);
    u = u - .00003 * sin(meanAnomalyOfSun-meanAnomalyOfJupiter);
    
    double w;
    w =    -.04129 * sin(2*meanLongitudeOfSun);
    w = w + .03211 * sin(meanAnomalyOfSun);
    w = w + .00104 * sin(2*meanLongitudeOfSun-meanAnomalyOfSun);
    w = w - .00035 * sin(2*meanLongitudeOfSun+meanAnomalyOfSun);
    w = w - .00010;
    w = w - .00008 * numCenturiesSince1900 * sin(meanAnomalyOfSun);
    w = w - .00008 * sin(longitudeOfLunarAscendingNode);
    w = w + .00007 * sin(2*meanAnomalyOfSun);
    w = w + .00005 * numCenturiesSince1900 * sin(2*meanLongitudeOfSun);
    w = w + .00003 * sin(meanLongitudeOfMoon-meanLongitudeOfSun);
    w = w - .00002 * cos(meanAnomalyOfSun-meanAnomalyOfJupiter);
    w = w + .00002 * sin(4*meanAnomalyOfSun-8*meanAnomalyOfMars+3*meanAnomalyOfJupiter);
    w = w - .00002 * sin(meanAnomalyOfSun-meanAnomalyOfVenus);
    w = w - .00002 * cos(2*meanAnomalyOfSun-2*meanAnomalyOfVenus);
    
    return [self calculatePositionWithMeanLongitude:meanLongitudeOfSun U:u V:v W:w];
}


- (KZPosition*) calculateMoonPosition:(double) daysFromEpoc {
    double numCenturiesSince1900 = daysFromEpoc/NUM_DAYS_IN_CENTURY + 1;
    
    //   Fundamental arguments
    //   (Van Flandern & Pulkkinen, 1979)
    double meanLongitudeOfMoon     = [self revolutionsToTruncatedRadians: (.606434 + .03660110129*daysFromEpoc)]; // 1
    
    double meanAnomalyOfMoon       = [self revolutionsToTruncatedRadians: (.374897 + .03629164709*daysFromEpoc)]; // 2
    double argumentOfLatitudeOfMoon= [self revolutionsToTruncatedRadians: (.259091 + .03674819520*daysFromEpoc)]; // 3
    double meanElongationOfMoon    = [self revolutionsToTruncatedRadians: (.827362 + .03386319198*daysFromEpoc)]; // 4
    double longitudeOfLunarAscendingNode= [self revolutionsToTruncatedRadians: (.347343 - .00014709391*daysFromEpoc)]; // 5
    double meanLongitudeOfSun      = [self revolutionsToTruncatedRadians: (.779072 + .00273790931*daysFromEpoc)]; // 7
    double meanAnomalyOfSun        = [self revolutionsToTruncatedRadians: (.993126 + .00273777850*daysFromEpoc)]; // 8
    double meanLongitudeOfVenus    = [self revolutionsToTruncatedRadians: (0.505498 + .00445046867*daysFromEpoc)]; // 12
    
    
    double a = meanAnomalyOfMoon ;            // 2
    double b = argumentOfLatitudeOfMoon ;     // 3
    double c = meanElongationOfMoon;          // 4
    double d = longitudeOfLunarAscendingNode; // 5
    double e = meanLongitudeOfSun;            // 7
    double f = meanAnomalyOfSun;              // 8
    double g = meanLongitudeOfVenus;          // 12
    
    
    double v;
    v =     .39558 * sin(b+d);
    v = v + .08200 * sin(b);
    v = v + .03257 * sin(a-b-d);
    v = v + .01092 * sin(a+b+d);
    v = v + .00666 * sin(a-b);
    v = v - .00644 * sin(a+b-2*c+d);
    v = v - .00331 * sin(b-2*c+d);
    v = v - .00304 * sin(b-2*c);
    v = v - .00240 * sin(a-b-2*c-d);
    v = v + .00226 * sin(a+b);
    v = v - .00108 * sin(a+b-2*c);
    v = v - .00079 * sin(b-d);
    v = v + .00078 * sin(b+2*c+d);
    v = v + .00066 * sin(b+d-f);
    v = v - .00062 * sin(b+d+f);
    v = v - .00050 * sin(a-b-2*c);
    v = v + .00045 * sin(2*a+b+d);
    v = v - .00031 * sin(2*a+b-2*c+d);
    v = v - .00027 * sin(a+b-2*c+d+f);
    v = v - .00024 * sin(b-2*c+d+f);
    v = v - .00021 * numCenturiesSince1900 * sin(b+d);
    v = v + .00018 * sin(b-c+d);
    v = v + .00016 * sin(b+2*c);
    v = v + .00016 * sin(a-b-d-f);
    v = v - .00016 * sin(2*a-b-d);
    v = v - .00015 * sin(b-2*c+f);
    v = v - .00012 * sin(a-b-2*c-d+f);
    v = v - .00011 * sin(a-b-d+f);
    v = v + .00009 * sin(a+b+d-f);
    v = v + .00009 * sin(2*a+b);
    v = v + .00008 * sin(2*a-b);
    v = v + .00008 * sin(a+b+2*c+d);
    v = v - .00008 * sin(3*b-2*c+d);
    v = v + .00007 * sin(a-b+2*c);
    v = v - .00007 * sin(2*a-b-2*c-d);
    v = v - .00007 * sin(a+b+d+f);
    v = v - .00006 * sin(b+c+d);
    v = v + .00006 * sin(b-2*c-f);
    v = v + .00006 * sin(a-b+d);
    v = v + .00006 * sin(b+2*c+d-f);
    v = v - .00005 * sin(a+b-2*c+f);
    v = v - .00004 * sin(2*a+b-2*c);
    v = v + .00004 * sin(a-3*b-d);
    v = v + .00004 * sin(a-b-f);
    v = v - .00003 * sin(a-b+f);
    v = v + .00003 * sin(b-c);
    v = v + .00003 * sin(b-2*c+d-f);
    v = v - .00003 * sin(b-2*c-d);
    v = v + .00003 * sin(a+b-2*c+d-f);
    v = v + .00003 * sin(b-f);
    v = v - .00003 * sin(b-c+d-f);
    v = v - .00002 * sin(a-b-2*c+f);
    v = v - .00002 * sin(b+f);
    v = v + .00002 * sin(a+b-c+d);
    v = v - .00002 * sin(a+b-d);
    v = v + .00002 * sin(3*a+b+d);
    v = v - .00002 * sin(2*a-b-4*c-d);
    v = v + .00002 * sin(a-b-2*c-d-f);
    v = v - .00002 * numCenturiesSince1900 * sin(a-b-d);
    v = v - .00002 * sin(a-b-4*c-d);
    v = v - .00002 * sin(a+b-4*c);
    v = v - .00002 * sin(2*a-b-2*c);
    v = v + .00002 * sin(a+b+2*c);
    v = v + .00002 * sin(a+b-f);
    
    
    double u;
    u = 1 - .10828 * cos(a);
    u = u - .01880 * cos(a-2*c);
    u = u - .01479 * cos(2*c);
    u = u + .00181 * cos(2*a-2*c);
    u = u - .00147 * cos(2*a);
    u = u - .00105 * cos(2*c-f);
    u = u - .00075 * cos(a-2*c+f);
    u = u - .00067 * cos(a-f);
    u = u + .00057 * cos(c);
    u = u + .00055 * cos(a+f);
    u = u - .00046 * cos(a+2*c);
    u = u + .00041 * cos(a-2*b);
    u = u + .00024 * cos(f);
    u = u + .00017 * cos(2*c+f);
    u = u - .00013 * cos(a-2*c-f);
    u = u - .00010 * cos(a-4*c);
    u = u - .00009 * cos(c+f);
    u = u + .00007 * cos(2*a-2*c+f);
    u = u + .00006 * cos(3*a-2*c);
    u = u + .00006 * cos(2*b-2*c);
    u = u - .00005 * cos(2*c-2*f);
    u = u - .00005 * cos(2*a-4*c);
    u = u + .00005 * cos(a+2*b-2*c);
    u = u - .00005 * cos(a-c);
    u = u - .00004 * cos(a+2*c-f);
    u = u - .00004 * cos(3*a);
    u = u - .00003 * cos(a-4*c+f);
    u = u - .00003 * cos(2*a-2*b);
    u = u - .00003 * cos(2*b);
    
    
    double w;
    w =     .10478 * sin(a);
    w = w - .04105 * sin(2*b+2*d);
    w = w - .02130 * sin(a-2*c);
    w = w - .01779 * sin(2*b+d);
    w = w + .01774 * sin(d);
    w = w + .00987 * sin(2*c);
    w = w - .00338 * sin(a-2*b-2*d);
    w = w - .00309 * sin(f);
    w = w - .00190 * sin(2*b);
    w = w - .00144 * sin(a+d);
    w = w - .00144 * sin(a-2*b-d);
    w = w - .00113 * sin(a+2*b+2*d);
    w = w - .00094 * sin(a-2*c+f);
    w = w - .00092 * sin(2*a-2*c);
    w = w + .00071 * sin(2*c-f);
    w = w + .00070 * sin(2*a);
    w = w + .00067 * sin(a+2*b-2*c+2*d);
    w = w + .00066 * sin(2*b-2*c+d);
    w = w - .00066 * sin(2*c+d);
    w = w + .00061 * sin(a-f);
    w = w - .00058 * sin(c);
    w = w - .00049 * sin(a+2*b+d);
    w = w - .00049 * sin(a-d);
    w = w - .00042 * sin(a+f);
    w = w + .00034 * sin(2*b-2*c+2*d);
    w = w - .00026 * sin(2*b-2*c);
    w = w + .00025 * sin(a-2*b-2*c-2*d);
    w = w + .00024 * sin(a-2*b);
    w = w + .00023 * sin(a+2*b-2*c+d);
    w = w + .00023 * sin(a-2*c-d);
    w = w + .00019 * sin(a+2*c);
    w = w + .00012 * sin(a-2*c-f);
    w = w + .00011 * sin(a-2*c+d);
    w = w + .00011 * sin(a-2*b-2*c-d);
    w = w - .00010 * sin(2*c+f);
    w = w + .00009 * sin(a-c);
    w = w + .00008 * sin(c+f);
    w = w - .00008 * sin(2*b+2*c+2*d);
    w = w - .00008 * sin(2*d);
    w = w - .00007 * sin(2*b+2*d-f);
    w = w + .00006 * sin(2*b+2*d+f);
    w = w - .00005 * sin(a+2*b);
    w = w + .00005 * sin(3*a);
    w = w - .00005 * sin(a+16*e-18*g);
    w = w - .00005 * sin(2*a+2*b+2*d);
    w = w + .00004 * numCenturiesSince1900 * sin(2*b+2*d);
    w = w + .00004 * cos(a+16*e-18*g);
    w = w - .00004 * sin(a-2*b+2*c);
    w = w - .00004 * sin(a-4*c);
    w = w - .00004 * sin(3*a-2*c);
    w = w - .00004 * sin(2*b+2*c+d);
    w = w - .00004 * sin(2*c-d);
    w = w - .00003 * sin(2*f);
    w = w - .00003 * sin(a-2*c+2*f);
    w = w + .00003 * sin(2*b-2*c+d+f);
    w = w - .00003 * sin(2*c+d-f);
    w = w + .00003 * sin(2*a+2*b-2*c+2*d);
    w = w + .00003 * sin(2*c-2*f);
    w = w - .00003 * sin(2*a-2*c+f);
    w = w + .00003 * sin(a+2*b-2*c+2*d+f);
    w = w - .00003 * sin(2*a-4*c);
    w = w + .00002 * sin(2*b-2*c+2*d+f);
    w = w - .00002 * sin(2*a+2*b+d);
    w = w - .00002 * sin(2*a-d);
    w = w + .00002 * numCenturiesSince1900 * cos(a+16*e-18*g);
    w = w + .00002 * sin(4*c);
    w = w - .00002 * sin(2*b-c+2*d);
    w = w - .00002 * sin(a+2*b-2*c);
    w = w - .00002 * sin(2*a+d);
    w = w - .00002 * sin(2*a-2*b-d);
    w = w + .00002 * sin(a+2*c-f);
    w = w + .00002 * sin(2*a-f);
    w = w - .00002 * sin(a-4*c+f);
    w = w + .00002 * numCenturiesSince1900 * sin(a+16*e-18*g);
    w = w - .00002 * sin(a-2*b-2*d-f);
    w = w + .00002 * sin(2*a-2*b-2*d);
    w = w - .00002 * sin(a+2*c+d);
    w = w - .00002 * sin(a-2*b+2*c-d);
    
    return [self calculatePositionWithMeanLongitude:meanLongitudeOfMoon U:u V:v W:w];
}



/**
 * Calculates RA (Right Ascension) and Dec (Declination) from
 * intermediate calculations
 */
- (KZPosition*) calculatePositionWithMeanLongitude:(double)meanLongitude U:(double)u V:(double)v W:(double)w {
    double s = w / sqrt(u - v*v);
    double rightAscention = meanLongitude + asin(s);
    
    double declination = asin(v / sqrt(u));
    
    NSLog(@"calculatePosition: (%4.10f, %4.10f)", rightAscention, declination);
    
    return [[KZPosition alloc] initWithRightAscention:rightAscention declination:declination];
}


/**
 * calculate LST at 0h zone time
 */
- (double) calculateLstWithDaysFromEpoc:(double)daysFromEpoc timeZoneShift:(double)timeZoneShift longitude:(double)longitude {
    double t = longitude/360;
    double ret = daysFromEpoc/36525.0;
    
    double s;
    s = 24110.5 + 8640184.813*ret;
    s = s + 86636.6*timeZoneShift + 86400*t;

    s = s/86400.0;
    s = s - ((int) s);

    
    ret = s * 360.0 * DR;
    
    return ret;
}


/**
 * Compute truncated Julian Date.
 *
 * @returns Truncated Julian Date. add +0.5 for non-truncated Julian Date
 */
- (int) calculateJulianDateWith:(KZSimpleDate*) date {

    int julianDate = -1 * (int) ( 7 * (((date.month+9)/12)+date.year) / 4);
    
    
    int offset = 0;
    BOOL after1583 = date.year >= 1583;
    if(after1583) {
        int s = [self signWithVal: (date.month - 9)];
        int a = abs(date.month-9);
        
        offset = date.year + s * (a/7);
        offset = -1 * ( (offset/100) +1) * 3/4;
    }
    
    
    julianDate = julianDate + (275*date.month/9) + date.day + offset;
    julianDate = julianDate + 1721027 + (after1583 ? 2 : 0) + 367*date.year;
    
    julianDate--; //truncate
    
    
    NSLog(@"Julian date: %d", julianDate);
    return julianDate;
}


- (void) setRisenAndSetAmountsForEvent:(KZEvent*) event {
    KZSimpleTime* midnight = [[KZSimpleTime alloc] initWithHour:24 minute:00];
    
    switch(event.type) {
		case NoChangePreviouslyRisen:
			event.risenAmount = [[KZSimpleTime alloc] initWithHour:24 minute:00];
			event.setAmount   = [[KZSimpleTime alloc] initWithHour:0  minute:00];
			break;
		case NoChangePreviouslySet:
            event.risenAmount = [[KZSimpleTime alloc] initWithHour:0  minute:00];
            event.setAmount   = [[KZSimpleTime alloc] initWithHour:24 minute:00];
			break;
		case OnlySet:
			event.risenAmount = event.set;
            event.setAmount   = [self differenceInTimeBetweenFirst:midnight Second:event.set];
			break;
		case OnlyRisen:
            event.risenAmount = [self differenceInTimeBetweenFirst:midnight Second:event.rise];
			event.setAmount   = event.rise;
			break;
		default:
            event.risenAmount = [self differenceInTimeBetweenFirst:event.set Second:event.rise];
            event.setAmount   = [self differenceInTimeBetweenFirst:event.rise Second:event.set];
            break;
    }
    
}


- (KZSimpleTime*) differenceInTimeBetweenFirst:(KZSimpleTime*) t1 Second:(KZSimpleTime*) t2 {
    int hour = t1.hour - t2.hour;
    int min = t1.min - t2.min;
    
    if(min < 0) {
        hour--;
        min+=60;
    }
    
    if(hour < 0) {
        hour += 24;
    }
    
    return [[KZSimpleTime alloc] initWithHour:hour minute:min];
}


- (void) setMeridianCrossingWithEvent:(KZEvent*) event {
    
    switch(event.type) {
		case RisenAndSet:
        {
            KZSimpleTime* lengthOfDay = event.risenAmount;
			int totalMins = (lengthOfDay.hour*60 + lengthOfDay.min)/2;
			
			int hour = event.rise.hour + (totalMins/60);
			int min  = event.rise.min  + (totalMins%60);
			
			if(min >= 60) {
				hour++;
				min = min - 60;
			}
            
            event.meridianCrossing = [[KZSimpleTime alloc] initWithHour:hour minute:min];
			break;
        }
		default:
			event.meridianCrossing = nil;
    }
}


- (void) setAntimeridianCrossingWithEvent:(KZEvent*) event {
    
    switch(event.type) {
		case RisenAndSet:
        {
			KZSimpleTime* lengthOfNight = event.setAmount;
			int totalMins = (lengthOfNight.hour*60 + lengthOfNight.min)/2;
			
			int hour = event.set.hour + (totalMins/60);
			int min  = event.set.min  + (totalMins%60);
			
			if(min >= 60) {
				hour++;
				min = min - 60;
			}
			
			if(hour >= 24) {
				hour -= 24;
			}
			event.antimeridianCrossing = [[KZSimpleTime alloc] initWithHour:hour minute: min];
			break;
        }
		default:
			event.antimeridianCrossing = nil;
    }
}


- (HorizonToHorizonCrossing) findTypeOfDayWithResult:(KZTestResult*)result lastV:(double)lastV {
    
    if(result.rise==nil && result.set==nil) {
        if (lastV < 0) {
            return NoChangePreviouslySet;
        } else {
            return NoChangePreviouslyRisen;
        }
        
    } else if(result.rise==nil) {
        return OnlySet;
        
    } else if(result.set==nil) {
        return OnlyRisen;
        
    } else {
        return RisenAndSet;
    }
    
}


@end
