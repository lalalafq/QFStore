//
//  NSArray+Safety.h
//  SmartOA
//
//  Created by fuqi on 17/3/28.
//  Copyright © 2017年 fuqi.inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Safety)

- (id)safetyObjectAtIndex:(NSInteger)index;

@end

@interface NSMutableArray (Safety)

- (BOOL)safetyAddObject:(NSObject *)obj;

@end
