//
//  MIHttpInfo.h
//  MIApm
//
//  Created by mediaios on 2019/10/22.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class MIHttpMetrics;
@interface MIHttpInfo : NSObject

@property (nonatomic,readonly) NSUInteger reqDate;
@property (nonatomic,readonly) CFAbsoluteTime beginTim;
@property (nonatomic,readonly) CFAbsoluteTime endTim;
@property (nonatomic,readonly) NSURLRequest *request;
@property (nonatomic,readonly) NSHTTPURLResponse *response;
@property (nonatomic,readonly) NSError *error;
@property (nonatomic,readonly) NSUInteger sendSize;
@property (nonatomic,readonly) NSUInteger receiveSize;
@property (nonatomic,readonly) MIHttpMetrics *httpMertics;

+ (instancetype)instanceWithDate:(NSUInteger *)reqDate
                        beginTim:(CFAbsoluteTime)beginTim
                     endTim:(CFAbsoluteTime)endTim
                     request:(NSURLRequest *)req
                    response:(NSHTTPURLResponse *)response
                       error:(NSError *)error
                    sendSize:(NSUInteger)sendSize
                 receiveSize:(NSUInteger)receiveSize
                 httpMetrics:(MIHttpMetrics *)httpMetrics;


@end


@interface MIHttpMetrics : NSObject
@property (nonatomic,readonly) NSTimeInterval tcpTim;
@property (nonatomic,readonly) NSTimeInterval dnsTim;
@property (nonatomic,readonly) NSTimeInterval clientTim;
@property (nonatomic,readonly) NSTimeInterval sslTim;
@property (nonatomic,readonly) NSTimeInterval totalTim;
@property (nonatomic,readonly) NSTimeInterval firstPacketTim;

+ (instancetype)instanceHttpMetricWithNSURLSessionTaskMetrics:(NSURLSessionTaskMetrics *)sessionMetrics;

@end

NS_ASSUME_NONNULL_END
