//
//  KZCalculator.h
//  Sky Watch
//
//  Created by Kurt Zoglmann on 12/7/13.
//  Copyright (c) 2013 Kurt Zoglmann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KZPosition.h"
#import "KZSimpleDate.h"
#import "KZSimpleTime.h"
#import "KZResult.h"
#import "KZEvent.h"
#import "KZSimpleTime.h"
#import "KZGPSCoordinate.h"


@interface KZCalculator : NSObject

- (KZResult*) calculateWithGps:(KZGPSCoordinate*) gps
                    utcToLocal:(int) utcToLocal
                          date:(KZSimpleDate*) date;

@end
