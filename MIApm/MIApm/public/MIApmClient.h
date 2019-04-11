//
//  MIApmClient.h
//  MIApm
//
//  Created by mediaios on 2019/4/11.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MIRequestMonitorRes.h"

@class MIApmClient;
@protocol MIApmClientDelegate <NSObject>

@optional

/**
 @brief 对网络请求监控结果的反馈
 */
- (void)apm:(MIApmClient *)apm monitorNetworkRequest:(MIRequestMonitorRes *)netModel;

@end


NS_ASSUME_NONNULL_BEGIN

@interface MIApmClient : NSObject
@property (nonatomic,strong) id<MIApmClientDelegate> delegate;


/**
 @brief 实例化 `MIApmClient`
 
 @discussion 只需要在main方法中调用该方法，即启用apm系统

 @return `MIApmClient`实例
 */
+ (instancetype)apmClient;


/**
 内部使用
 */
- (void)netRequestMonitor:(MIRequestMonitorRes *)netModel;

@end

NS_ASSUME_NONNULL_END
