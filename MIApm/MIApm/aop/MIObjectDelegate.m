//
//  MIObjectDelegate.m
//  MIApm
//
//  Created by mediaios on 2019/4/4.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import "MIObjectDelegate.h"
#import "MIApmHelper.h"
#import "MIRequestMonitorRes.h"
#import "MIApmClient.h"

@interface MIObjectDelegate()
@property (nonatomic,strong) NSMutableArray *selList;
@end


@implementation MIObjectDelegate

- (NSMutableArray *)selList
{
    if (!_selList) {
        _selList = [NSMutableArray arrayWithCapacity:0];
    }
    return _selList;
}

- (void)invoke:(NSInvocation *)invocation
{
    if ([self.selList containsObject:NSStringFromSelector(invocation.selector)]) {
        if ([self respondsToSelector:invocation.selector]) {
            invocation.target = self;
            [invocation invoke];
        }
    }
}

- (void)registerSel:(NSString *)sel
{
    if (![self.selList containsObject:sel]) {
        [self.selList addObject:sel];
    }
}

- (void)unregisterSel:(NSString *)sel
{
    if ([self.selList containsObject:sel]) {
        [self.selList removeObject:sel];
    }
}

#pragma mark -NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    CFAbsoluteTime end_tim = (CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970)*1000;
    NSUInteger totalTim = end_tim - begin_tim;
    MIRequestMonitorRes *netModel = [MIRequestMonitorRes instanceWith:url_str
                                                            reqMethod:req_method
                                                               reqTim:req_tim
                                                             totalTim:totalTim statusCode:statusCode];
    //    NSLog(@"%@",netModel);
    [[MIApmClient apmClient] netRequestMonitor:netModel];
    
    req_tim = 0;
    begin_tim = 0;
    statusCode = 0;
    url_str = nil;
    req_method = nil;
}


#pragma mark -NSURLConnectionDataDelegate
static NSInteger req_tim = 0;
static CFAbsoluteTime begin_tim = 0;
static NSInteger statusCode = 0;
static NSString *url_str = nil;
static NSString *req_method = nil;
- (nullable NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(nullable NSURLResponse *)response
{

    req_tim = [MIApmHelper currentTimestamp];
    begin_tim = (CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970)*1000;
    url_str = request.URL.absoluteString;
    req_method = request.HTTPMethod;
    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    statusCode = ((NSHTTPURLResponse *)response).statusCode;

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{

}

- (void)connection:(NSURLConnection *)connection   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    CFAbsoluteTime end_tim = (CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970)*1000;
    NSUInteger totalTim = end_tim - begin_tim;
    MIRequestMonitorRes *netModel = [MIRequestMonitorRes instanceWith:url_str
                                                            reqMethod:req_method
                                                               reqTim:req_tim
                                                             totalTim:totalTim statusCode:statusCode];
//    NSLog(@"%@",netModel);
    [[MIApmClient apmClient] netRequestMonitor:netModel];
    
    req_tim = 0;
    begin_tim = 0;
    statusCode = 0;
    url_str = nil;
    req_method = nil;
}


#pragma mark -NSURLConnectionDownloadDelegate

- (void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes
{
//    NSLog(@"%s----",__func__);
}

- (void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes
{
//    NSLog(@"%s----",__func__);
}

- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *) destinationURL
{
//    NSLog(@"%s----",__func__);
}


#pragma mark-NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics {
    NSURLSessionTaskTransactionMetrics *metric = [metrics.transactionMetrics lastObject];

    if (metric) {
        NSTimeInterval tcptiming = [metric.connectEndDate timeIntervalSinceDate:metric.connectStartDate] * 1000;
        NSTimeInterval dnstiming = [metric.domainLookupEndDate timeIntervalSinceDate:metric.domainLookupStartDate] * 1000;
        NSTimeInterval clientwasttiming = [metric.requestEndDate timeIntervalSinceDate:metric.requestStartDate] * 1000;
        NSTimeInterval ssltiming = [metric.secureConnectionEndDate timeIntervalSinceDate:metric.secureConnectionStartDate] * 1000;
        NSTimeInterval tttiming = [metrics.taskInterval duration] * 1000;   // 网络请求总时间
        NSTimeInterval firsttiming = [metric.responseStartDate timeIntervalSinceDate:metric.requestEndDate] * 1000;
        
        NSString *url_str = metric.request.URL.absoluteString;
        req_method = metric.request.HTTPMethod;
        NSUInteger req_tim = [MIApmHelper currentTimestamp];
        NSInteger statusCode  = ((NSHTTPURLResponse *)metric.response).statusCode;
        MIRequestMonitorRes *netModel = [MIRequestMonitorRes instanceWith:url_str
                                                                reqMethod:req_method
                                                                   reqTim:req_tim
                                                            clientWastTim:clientwasttiming
                                                                 totalTim:tttiming
                                                                   dnsTim:dnstiming
                                                                   sslTim:ssltiming
                                                                   tcpTim:tcptiming
                                                           firstPacketTim:firsttiming
                                                               statusCode:statusCode];
        
        [[MIApmClient apmClient] netRequestMonitor:netModel];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {

    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
    
    NSInteger statusCode = httpResponse.statusCode;
    if (error) {
       
    } else {
        switch (statusCode) {
            case 200:
            case 304:
                NSLog(@"请求成功");
                break;
            default:
                break;
        }
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    NSLog(@"%s----",__func__);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"%s----",__func__);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
   NSLog(@"%s----",__func__);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    NSLog(@"%s----",__func__);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    NSLog(@"%s----",__func__);
}
@end
