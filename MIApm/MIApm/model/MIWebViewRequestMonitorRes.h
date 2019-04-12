//
//  MIWebViewRequestMonitorRes.h
//  MIApm
//
//  Created by mediaios on 2019/4/12.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import <Foundation/Foundation.h>

// 定义一个枚举，表示网络请求状态
typedef NS_ENUM(NSUInteger,MIWebViewStatus)
{
    MIWebViewStatus_NORMAL,    // 正常返回
    MIWebViewStatus_FAILLOAD,     // UIWebView加载出错
    MIWebViewStatus_STOP       // 调用了停止方法
};


NS_ASSUME_NONNULL_BEGIN


@interface MIWebViewRequestMonitorRes : NSObject

/**
 记录产生的时间(单位是秒)
 */
@property (nonatomic,readonly) NSUInteger reqTim;

/**
 请求地址
 */
@property (nonatomic,readonly) NSString *reqDst;

/**
 单次网络请求总时间(单位是毫秒)
 */
@property (nonatomic,readonly) NSUInteger totalTim;


@property (nonatomic,readonly) MIWebViewStatus webViewStatus;

/**
 实例化`UIWebView`中网络请求分析结果(内部使用)
 */
+ (instancetype)instanceWithReqDst:(NSString *)reqDst
                            reqTim:(NSUInteger)reqTim
                          totalTim:(NSUInteger)totalTim
                     webViewStatus:(MIWebViewStatus)webViewStatus;

@end

NS_ASSUME_NONNULL_END
