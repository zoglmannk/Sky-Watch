//
//  KZEvent.h
//  Sky Watch
//
//  Created by Kurt Zoglmann on 12/8/13.
//  Copyright (c) 2013 Kurt Zoglmann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KZSimpleTime.h"


typedef NS_ENUM(NSInteger, HorizonToHorizonCrossing) {
    RisenAndSet,  /**< Represents a celestial object that rose and set during the period of interest */
    NoChangePreviouslyRisen, /**< Represents a celestial object that neither rose or set during the period of interest. But previously rose. */
    NoChangePreviouslySet,   /**< Represents a celestial object that neither rose or set during the period of interest. But previously set. */
    OnlySet, /**< Represents a celestial object that only set during the period of interest */
    OnlyRisen /**< Represents a celestial object that only rose during the period of interest */
};


@interface KZEvent : NSObject {
@protected
    KZSimpleTime *_rise;
    KZSimpleTime *_set;
    
    double _riseAzimuth;
    double _setAzimuth;
    
    HorizonToHorizonCrossing _type;
    
    KZSimpleTime *_meridianCrossing;
    KZSimpleTime *_antimeridianCrossing;
    
    KZSimpleTime *_risenAmount;
    KZSimpleTime *_setAmount;
}


@property (nonatomic) KZSimpleTime *rise;
@property (nonatomic) KZSimpleTime *set;

@property (nonatomic) double riseAzimuth;
@property (nonatomic) double setAzimuth;

@property (nonatomic) HorizonToHorizonCrossing type;

@property (nonatomic) KZSimpleTime *meridianCrossing;
@property (nonatomic) KZSimpleTime *antimeridianCrossing;

@property (nonatomic) KZSimpleTime *risenAmount;
@property (nonatomic) KZSimpleTime *setAmount;


@end
