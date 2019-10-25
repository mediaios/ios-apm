//
//  MIApmHelper.m
//  MIApm
//
//  Created by mediaios on 2019/4/10.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import "MIApmHelper.h"
#import "MIHTTPModel.h"
#import "MIApmClient.h"

@implementation MIApmHelper

+ (NSInteger)currentTimestamp
{
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    return (NSInteger)currentTime;
}


+ (void)monitorConnectionHttpWithReuest:(NSURLRequest *)request
                     response:(NSHTTPURLResponse *)response
                        error:(NSError *)error
                      reqTime:(NSUInteger)reqTim
                    beginTime:(CFAbsoluteTime)beginTim
                      endTime:(CFAbsoluteTime)endTim
{
    CFAbsoluteTime totalTime = endTim - beginTim;
    NSString *reqDst = request.URL.absoluteString;
    MIHttpModel *httpModel = [MIHttpModel instanceWithUrlStr:reqDst
                          reqMethod:request.HTTPMethod
                             reqTim:reqTim
                           totalTim:totalTime
                         statusCode:response.statusCode
                              error:error];
    NSLog(@"qizhang--debug---%@",httpModel);
    [[MIApmClient apmClient] miMonitorRes:httpModel];
}

+ (void)monitorHttpWithSessionTaskMetrics:(NSURLSessionTaskMetrics *)metrics
                                    error:(NSError *)error API_AVAILABLE(ios(10.0))
{
    NSURLSessionTaskTransactionMetrics *metric = [metrics.transactionMetrics lastObject];
    NSTimeInterval tcpTim = [metric.connectEndDate timeIntervalSinceDate:metric.connectStartDate] * 1000;
    NSTimeInterval dnsTim = [metric.domainLookupEndDate timeIntervalSinceDate:metric.domainLookupStartDate] * 1000;
    NSTimeInterval clientTim = [metric.requestEndDate timeIntervalSinceDate:metric.requestStartDate] * 1000;
    NSTimeInterval sslTim = [metric.secureConnectionEndDate timeIntervalSinceDate:metric.secureConnectionStartDate] * 1000;
    NSTimeInterval totalTim = [metrics.taskInterval duration] * 1000;   // 网络请求总时间
    NSTimeInterval firstPacketTim = [metric.responseStartDate timeIntervalSinceDate:metric.requestEndDate] * 1000;
    NSString *url_str = metric.request.URL.absoluteString;
    NSUInteger req_tim = [MIApmHelper currentTimestamp];
    NSInteger statusCode  = ((NSHTTPURLResponse *)metric.response).statusCode;
    
    MIHttpModel *httpModel = [MIHttpModel instanceWithUrlStr:url_str
                                                reqMethod:metric.request.HTTPMethod
                                                   reqTim:req_tim
                                            clientWastTim:clientTim
                                                 totalTim:totalTim
                                                   dnsTim:dnsTim
                                                   sslTim:sslTim
                                                   tcpTim:tcpTim
                                           firstPacketTim:firstPacketTim
                                               statusCode:statusCode
                                                    error:error];
    [[MIApmClient apmClient] miMonitorRes:httpModel];
}

@end
