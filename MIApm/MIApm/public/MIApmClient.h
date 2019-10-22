//
//  MIApmClient.h
//  MIApm
//
//  Created by mediaios on 2019/4/11.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MIHttpModel.h"
#import "MIWebModel.h"

@class MIApmClient;
@protocol MIApmClientDelegate <NSObject>

@optional

/**
  @brief 对网络请求监控结果的反馈

 @param apm `MIApmClient`实例
 @param netModel 网络请求监控结果
 */
- (void)apm:(MIApmClient *)apm monitorNetworkRequest:(MIHttpModel *)netModel;


/**
 @brief 对`UIWebView`监控的结果反馈

 @param apm `MIApmClient`实例
 @param webViewMonitorRes `UIWebView`监控结果
 */
- (void)apm:(MIApmClient *)apm monitorUIWebView:(MIWebModel *)webViewMonitorRes;

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
- (void)miMonitorRes:(id)monitorModel;

@end

NS_ASSUME_NONNULL_END
