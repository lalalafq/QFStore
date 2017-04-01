//
//  NSArray+Safety.m
//  SmartOA
//
//  Created by fuqi on 17/3/28.
//  Copyright © 2017年 fuqi.inc. All rights reserved.
//

#import "NSArray+Safety.h"

@implementation NSArray (Safety)

- (id)safetyObjectAtIndex:(NSInteger)index
{
    if (index < 0 || index >= self.count)
    {
        return nil;
    }
    return [self objectAtIndex:index];
}

@end

@implementation NSMutableArray (Safety)

- (BOOL)safetyAddObject:(NSObject *)obj
{
    if (obj)
    {
        [self addObject:obj];
        return YES;
    }
    return NO;
}

@end
