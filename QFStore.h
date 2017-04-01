//
//  QFStore.h
//  SmartOA
//
//  Created by fuqi on 17/3/28.
//  Copyright © 2017年 fuqi.inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+runtime.h"
#import "NSArray+Safety.h"


#define STORE_SERVICE(manangerName,serviceName) @"qf_store_service_"manangerName"_"serviceName

#define STORE_SERVICE_COMPANYMANAGER(serviceName)  STORE_SERVICE("company_manger",serviceName)

@protocol QFStoreProtocol <NSObject>

/*
 * 注册监听者 enableServiceChain为NO
 * @param subscriber            监听者
 * @param serviceName           服务名称
*/
- (RACSignal *)registerSubscriber:(NSObject *)subscriber forServiceName:(NSString *)serviceName;

/*
 * 注册监听者
 * @param subscriber            监听者
 * @param serviceName           服务名称
 * @param flag                  是否只监听一次，一次成功后会抛弃信号
 * @param disableServiceChain   是否禁用服务链
 */
- (RACSignal *)registerSubscriber:(NSObject *)subscriber forServiceName:(NSString *)serviceName enableServiceChain:(BOOL)enableServiceChainFlag;

/*
 * 注册监听者，enableServiceChain默认为NO
 * @param subscriber        监听者
 * @param serviceArray      服务名称数据，数组内的服务会触发。
 */
- (RACSignal *)registerSubscriber:(NSObject *)subscriber forServiceArray:(NSArray *)serviceArray;

/*
 * 触发服务
 * @param serviceArray  服务数组
 * @param obj   参数
 */
- (void)triggerActionByServiceArray:(NSArray *)serviceArray withObject:(NSObject *)obj;

/*
 * 触发服务
 * @param serviceName  服务
 * @param obj   参数
 */
- (void)triggerActionByServiceName:(NSString *)serviceName withObject:(NSObject *)obj;


/// 设置服务链
- (void)setServiceChainArray:(NSArray<NSArray<NSString *> *> *)serviceChainArray;

/// 设置服务-方法键值对。
- (void)setSubscriberSelectorDict:(NSDictionary *)subscriberSelectorDict;

@end



@interface QFStore : NSObject<QFStoreProtocol>

@end
