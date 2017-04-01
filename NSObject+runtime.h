//
//  NSObject+runtime.h
//  SmartOA
//
//  Created by fuqi on 17/3/28.
//  Copyright © 2017年 fuqi.inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface CKWeakHolder : NSObject
+ (instancetype)holderWithObject:(id)object;
- (id)initWithObject:(id)object;
- (id)holdedObject;
@end

@interface NSObject (runtime)

@property (nonatomic, strong) id customObject;
@property (nonatomic, strong) NSMutableDictionary *customInfo;
@property (nonatomic, strong) NSMutableArray *customArray;
@property (nonatomic, copy) void (^customActionBlock)(void);
@property (nonatomic, weak) id customWeakObject;
@property (nonatomic, assign) NSInteger customTag;
@property (nonatomic, assign) BOOL customFlag;
@property (nonatomic, strong) NSString *customIdenfitier;

@end
