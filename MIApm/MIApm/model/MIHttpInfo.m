//
//  MIHttpInfo.m
//  MIApm
//
//  Created by mediaios on 2019/10/22.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import "MIHttpInfo.h"

@implementation MIHttpInfo

- (instancetype)initWithDate:(NSUInteger)reqDate
                    beginTim:(CFAbsoluteTime) beginTim
                      endTim:(CFAbsoluteTime)endTim
                     request:(NSURLRequest *)req
                             response:(NSHTTPURLResponse *)response
                                error:(NSError *)error
                             sendSize:(NSUInteger)sendSize
                          receiveSize:(NSUInteger)receiveSize
                          httpMetrics:(MIHttpMetrics *)httpMetrics
{
    if (self = [super init]) {
        _reqDate = reqDate;
        _beginTim = beginTim;
        _endTim = endTim;
        _request = req;
        _response = response;
        _error = error;
        _sendSize = sendSize;
        _receiveSize = receiveSize;
        _httpMertics = httpMetrics;
    }
    return self;
}

+ (instancetype)instanceWithDate:(NSUInteger)reqDate
                        beginTim:(CFAbsoluteTime)beginTim
                          endTim:(CFAbsoluteTime)endTim
                         request:(NSURLRequest *)req
                        response:(NSHTTPURLResponse *)response
                           error:(NSError *)error
                        sendSize:(NSUInteger)sendSize
                     receiveSize:(NSUInteger)receiveSize
                     httpMetrics:(MIHttpMetrics *)httpMetrics
{
    return [[self alloc] initWithDate:reqDate
                             beginTim:beginTim
                               endTim:endTim
                              request:req
                             response:response
                                error:error
                             sendSize:sendSize
                          receiveSize:receiveSize
                          httpMetrics:httpMetrics];
}


@end

@implementation MIHttpMetrics

- (instancetype)initWithNSURLSessionTaskMetrics:(NSURLSessionTaskMetrics *)sessionMetrics
{
    if (self = [super init]) {
        if (sessionMetrics) {
            NSURLSessionTaskTransactionMetrics *metric = [sessionMetrics.transactionMetrics lastObject];
            _tcpTim = [metric.connectEndDate timeIntervalSinceDate:metric.connectStartDate] * 1000;
            _dnsTim = [metric.domainLookupEndDate timeIntervalSinceDate:metric.domainLookupStartDate] * 1000;
            _clientTim = [metric.requestEndDate timeIntervalSinceDate:metric.requestStartDate] * 1000;
            _sslTim = [metric.secureConnectionEndDate timeIntervalSinceDate:metric.secureConnectionStartDate] * 1000;
            _totalTim = [sessionMetrics.taskInterval duration] * 1000;   // 网络请求总时间
            _firstPacketTim = [metric.responseStartDate timeIntervalSinceDate:metric.requestEndDate] * 1000;
        }
       
    }
    return self;
}

+ (instancetype)instanceHttpMetricWithNSURLSessionTaskMetrics:(NSURLSessionTaskMetrics *)sessionMetrics
{
    return [[self alloc] initWithNSURLSessionTaskMetrics:sessionMetrics];
}

@end
