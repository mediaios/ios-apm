//
//  MIHttpModel.h
//  MIApm
//
//  Created by mediaios on 2019/4/10.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MIHttpInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface MIHttpModel : NSObject

/**
 记录产生的时间(单位是秒)
 */
@property (nonatomic,readonly) NSUInteger reqTim;

/**
 请求地址
 */
@property (nonatomic,readonly) NSString *reqDst;


/**
 请求方式
 */
@property (nonatomic,readonly) NSString *reqMethod;

/**
 客户端耗时(单位是毫秒)
 */
@property (nonatomic,readonly) NSUInteger clientWastTim;

/**
 网络请求总时间(单位是毫秒)
 */
@property (nonatomic,readonly) NSUInteger totalTim;

/**
 DNS解析时间(单位是毫秒)
 */
@property (nonatomic,readonly) NSUInteger dnsTim;

/**
 ssl时间(单位是毫秒)
 */
@property (nonatomic,readonly) NSUInteger sslTim;

/**
 tcp时间(单位是毫秒)
 */
@property (nonatomic,readonly) NSUInteger tcpTim;

/**
 首包时间(单位是毫秒)
 */
@property (nonatomic,readonly) NSUInteger firstPacketTim;

/**
 http响应状态码
 */
@property (nonatomic,readonly) NSInteger statusCode;


/**
 实例化网络请求分析结果，针对于`NSURLConnection`(内部使用)
 */
+ (instancetype)instanceWith:(NSString *)reqDst
                   reqMethod:(NSString *)reqMethod
                      reqTim:(NSUInteger)reqTim
                    totalTim:(NSUInteger)totalTim
                  statusCode:(NSInteger)statusCode;

/**
 实例化网络请求分析结果，针对于`NSURLSession`(内部使用)
 */
+ (instancetype)instanceWith:(NSString *)reqDst
                   reqMethod:(NSString *)reqMethod
                      reqTim:(NSUInteger)reqTim
               clientWastTim:(NSUInteger)clientWastTim
                    totalTim:(NSUInteger)totalTim
                      dnsTim:(NSUInteger)dnsTim
                      sslTim:(NSUInteger)sslTim
                      tcpTim:(NSUInteger)tcpTim
              firstPacketTim:(NSUInteger)firstPacketTim
                  statusCode:(NSInteger)statusCode;

+ (instancetype)instanceWithHttpModel:(MIHttpInfo *)httpInfo;

@end

NS_ASSUME_NONNULL_END
