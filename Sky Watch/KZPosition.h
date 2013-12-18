//
//  KZPosition.h
//  Sky Watch
//
//  Created by Kurt Zoglmann on 12/7/13.
//  Copyright (c) 2013 Kurt Zoglmann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KZPosition : NSObject

@property (nonatomic, readonly) float rightAscention;
@property (nonatomic, readonly) float declination;


- (id) initWithRightAscention:(double)rightAscention declination:(double) declination;

- (NSString *)description;

@end
