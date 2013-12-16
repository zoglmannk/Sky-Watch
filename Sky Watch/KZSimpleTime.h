//
//  KZSimpleTime.h
//  Sky Watch
//
//  Created by Kurt Zoglmann on 12/8/13.
//  Copyright (c) 2013 Kurt Zoglmann. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A simple way to express time in hours and minutes. This is simply a container class.
 */
@interface KZSimpleTime : NSObject

@property int hour;
@property int min;

- (id) initWithHour:(double)hour minute:(double)min;

- (NSString *)description;

@end
