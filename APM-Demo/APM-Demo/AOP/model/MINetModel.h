//
//  MINetModel.h
//  APM-Demo
//
//  Created by ethan on 2019/4/10.
//  Copyright © 2019 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MINetModel : NSObject

/**
 记录产生的时间
 */
@property (nonatomic,readonly) NSUInteger reqTim;

/**
 请求地址
 */
@property (nonatomic,readonly) NSString *reqDst;

/**
 客户端耗时
 */
@property (nonatomic,readonly) NSUInteger clientWastTim;

/**
 网络请求总时间
 */
@property (nonatomic,readonly) NSUInteger totalTim;

/**
 DNS解析时间
 */
@property (nonatomic,readonly) NSUInteger dnsTim;

/**
 ssl时间
 */
@property (nonatomic,readonly) NSUInteger sslTim;

/**
 tcp时间
 */
@property (nonatomic,readonly) NSUInteger tcpTim;

/**
 首包时间
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
                      reqTim:(NSUInteger)reqTim
                    totalTim:(NSUInteger)totalTim
                  statusCode:(NSInteger)statusCode;

/**
 实例化网络请求分析结果，针对于`NSURLSession`(内部使用)
 */
+ (instancetype)instanceWith:(NSString *)reqDst
                      reqTim:(NSUInteger)reqTim
               clientWastTim:(NSUInteger)clientWastTim
                    totalTim:(NSUInteger)totalTim
                      dnsTim:(NSUInteger)dnsTim
                      sslTim:(NSUInteger)sslTim
                      tcpTim:(NSUInteger)tcpTim
              firstPacketTim:(NSUInteger)firstPacketTim
                  statusCode:(NSInteger)statusCode;

@end

NS_ASSUME_NONNULL_END
