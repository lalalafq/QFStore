//
//  QFStore.m
//  SmartOA
//
//  Created by fuqi on 17/3/28.
//  Copyright © 2017年 fuqi.inc. All rights reserved.
//

#import "QFStore.h"

#define QFSTORE_SERVICE_ENABLE_CHAIN_KEY   @"qfstore_service_enable_chain"

@interface QFStore ()

/// 为存储subscriberDict提供的安全锁
@property (nonatomic)dispatch_semaphore_t subscriberLock;
/// 存储{服务名称：监听者}的字典
@property (nonatomic,strong)NSMutableDictionary  * subscriberDict;

/// 存储{服务名称：服务对应的方法指针}的字典
@property (nonatomic,strong)NSDictionary * subscriberSelectorDict;

/// 服务链二维数组。
@property (nonatomic,strong)NSArray<NSArray<NSString *> *> * serviceChainArray;

@end

@implementation QFStore


#pragma mark - 程序可靠性
+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    return YES;
}

#pragma mark - 生命周期
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _subscriberLock = dispatch_semaphore_create(1);
        _subscriberDict = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Setting & Getting
- (void)setServiceChainArray:(NSArray<NSArray<NSString *> *> *)serviceChainArray
{
    _serviceChainArray = serviceChainArray;
}

- (void)setSubscriberSelectorDict:(NSDictionary *)subscriberSelectorDict
{
    _subscriberSelectorDict = subscriberSelectorDict;
}

#pragma mark - 监听者注册
- (RACSignal *)registerSubscriber:(NSObject *)subscriber forServiceName:(NSString *)serviceName
{
    return [self registerSubscriber:subscriber forServiceName:serviceName enableServiceChain:NO];
}
- (RACSignal *)registerSubscriber:(NSObject *)subscriber forServiceName:(NSString *)serviceName enableServiceChain:(BOOL)enableServiceChainFlag
{
    if (!serviceName.length)
    {
        return nil;
    }
    
    RACSubject * subject;
    
    dispatch_semaphore_wait(_subscriberLock, DISPATCH_TIME_FOREVER);
    
    NSHashTable * subscriberTable = [self.subscriberDict objectForKey:serviceName];
    if (!subscriberTable)
    {
        subscriberTable = [NSHashTable weakObjectsHashTable];
        [self.subscriberDict setObject:subscriberTable forKey:serviceName];
    }
    
    
    BOOL isContainSubscriber= [subscriberTable containsObject:subscriber];
    // 不包含 或者 不包含服务 或者 异常类型
    if (!isContainSubscriber || !subscriber.customInfo[serviceName] || ![subscriber.customInfo[serviceName] isKindOfClass:[RACSubject class]])
    {
        subject = [[RACSubject alloc] init];
        NSMutableDictionary * subjectDict = subscriber.customInfo ?: [NSMutableDictionary dictionary];
        subjectDict[serviceName] = subject;
        
        NSMutableDictionary * flagDict = subject.customInfo ?: [NSMutableDictionary dictionary];
        flagDict[QFSTORE_SERVICE_ENABLE_CHAIN_KEY] = @(enableServiceChainFlag);
        subject.customInfo = flagDict;
        
        subscriber.customInfo = subjectDict;
        [subscriberTable addObject:subscriber];
    }
    else
    {
        subject = subscriber.customInfo[serviceName];
    }
    
    dispatch_semaphore_signal(_subscriberLock);
    return subject;
}


- (RACSignal *)registerSubscriber:(NSObject *)subscriber forServiceArray:(NSArray *)serviceArray
{
    RACSignal * signal;
    for (NSString * serviceName in serviceArray)
    {
        NSAssert([serviceName isKindOfClass:[NSString class]], @"serviceName must be a string object");
        
        RACSignal * subSubject = [self registerSubscriber:subscriber forServiceName:serviceName enableServiceChain:NO];
        signal = signal ? [signal merge:subSubject] : subSubject;
    }
    return signal;
}


- (void)triggerActionByServiceArray:(NSArray *)serviceArray withObject:(NSObject *)obj
{
    for (NSString * serviceName in serviceArray)
    {
        NSAssert([serviceName isKindOfClass:[NSString class]], @"serviceName must be a string object");
        [self triggerActionByServiceName:serviceName withObject:obj];
    }
}

- (void)triggerActionByServiceName:(NSString *)serviceName withObject:(NSObject *)obj
{
    NSHashTable * subscriberTable = [self.subscriberDict objectForKey:serviceName];
    NSArray * subscriberArray = [[subscriberTable objectEnumerator] allObjects];
    for (NSObject * subscriber in subscriberArray)
    {
        if (!subscriber.customInfo || ![subscriber.customInfo isKindOfClass:[NSDictionary class]])
        {
            return;
        }
        NSMutableDictionary * serviceDict  = subscriber.customInfo;
        if (!serviceDict[serviceName])
        {
            return;
        }
        
        
        
        RACSubject * subject = serviceDict[serviceName];
        [subject sendNext:obj];
        
        NSMutableDictionary * flagDict = subject.customInfo;
        BOOL enableServiceChainFlag = [flagDict[QFSTORE_SERVICE_ENABLE_CHAIN_KEY] boolValue];
        if (enableServiceChainFlag)
        {
            //启动服务链
            [self triggerSubsequentSelectorName:serviceName];
        }
        
    }
}


#pragma mark - Utilitly
// 触发服务链的下一个服务对应的事件
- (void)triggerSubsequentSelectorName:(NSString * )currentServiceName
{
    if (!currentServiceName.length)
    {
        return;
    }

    for (NSArray <NSString *> * serviceChain in self.serviceChainArray)
    {
        if ([serviceChain containsObject:currentServiceName])
        {
            NSInteger index = [serviceChain indexOfObject:currentServiceName];
            NSString * subsequentServiceName  = [serviceChain safetyObjectAtIndex:index + 1];
            NSString * subsequentSelectorName = self.subscriberSelectorDict[subsequentServiceName];
            if (subsequentSelectorName.length)
            {
                [self triggerSubsequentAction:subsequentSelectorName];
            }
            continue;
        }
    }
}

// 触发事件
- (void)triggerSubsequentAction:(NSString *)selectorName
{
    if (!selectorName.length)
    {
        return;
    }
    
    SEL sel = NSSelectorFromString(selectorName);
    IMP imp = [self methodForSelector:sel];
    if ([self respondsToSelector:sel])
    {
        void (*func)(id, SEL) = (void *)imp;
        func(self, sel);
    }
}

@end
