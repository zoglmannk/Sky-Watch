//
//  KZMoonEvent.h
//  Sky Watch
//
//  Created by Kurt Zoglmann on 12/8/13.
//  Copyright (c) 2013 Kurt Zoglmann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KZEvent.h"


@interface KZMoonEvent : KZEvent

@property (nonatomic) double ageInDays;
@property (nonatomic) double illuminationPercent;

- (id) initWithEvent:(KZEvent*) event;

@end
