//
//  MIHttpDelegate.m
//  MIApm
//
//  Created by mediaios on 2019/4/4.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import "MIHttpDelegate.h"
#import "MIApmHelper.h"
#import "MIHttpModel.h"
#import "MIApmClient.h"

@interface MIHttpDelegate()
@property (nonatomic,strong) NSMutableArray *selList;

@property (nonatomic,assign) NSUInteger reqDate;
@property (nonatomic,assign) CFAbsoluteTime beginTim;
@property (nonatomic,assign) CFAbsoluteTime endTim;
@property (nonatomic,strong) NSURLRequest *request;
@property (nonatomic,strong) NSHTTPURLResponse *response;
@property (nonatomic,strong) NSError *error;
@property (nonatomic,assign) NSUInteger sendSize;
@property (nonatomic,assign) NSUInteger receiveSize;
@property (nonatomic,strong) MIHttpMetrics *httpMertics;

@end


@implementation MIHttpDelegate

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

- (void)resetPropertys
{
    _reqDate = 0;
    _beginTim = 0;
    _endTim = 0;
    _request = nil;
    _response = nil;
    _error = nil;
    _sendSize = 0;
    _receiveSize = 0;
    _httpMertics = nil;
}

#pragma mark -NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    _endTim = (CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970)*1000;
    _error = error;
    MIHttpInfo *httpInfo = [MIHttpInfo instanceWithDate:_reqDate
                                               beginTim:_beginTim
                                                 endTim:_endTim
                                                request:_request
                                               response:_response
                                                  error:_error
                                               sendSize:_sendSize
                                            receiveSize:_receiveSize
                                            httpMetrics:_httpMertics];
    MIHttpModel *httpModel = [MIHttpModel instanceWithHttpModel:httpInfo];
    [[MIApmClient apmClient] miMonitorRes:httpModel];
    [self resetPropertys];
}

#pragma mark -NSURLConnectionDataDelegate
static NSInteger req_tim = 0;
static CFAbsoluteTime begin_tim = 0;
static NSInteger statusCode = 0;
static NSString *url_str = nil;
static NSString *req_method = nil;
- (nullable NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(nullable NSURLResponse *)response
{
    _reqDate = [MIApmHelper currentTimestamp];
    _beginTim = (CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970)*1000;
    _request = request;
    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _response = (NSHTTPURLResponse *)response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    _receiveSize = data.length;
}

- (void)connection:(NSURLConnection *)connection   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    _sendSize = totalBytesWritten;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    _endTim = (CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970)*1000;

    MIHttpInfo *httpInfo = [MIHttpInfo instanceWithDate:_reqDate
                                               beginTim:_beginTim
                                                 endTim:_endTim
                                                 request:_request
                                               response:_response
                                                  error:_error
                                               sendSize:_sendSize
                                            receiveSize:_receiveSize
                                            httpMetrics:_httpMertics];
    MIHttpModel *httpModel = [MIHttpModel instanceWithHttpModel:httpInfo];
    NSLog(@"qizhang--debug---%@",httpModel);
    [[MIApmClient apmClient] miMonitorRes:httpModel];
    [self resetPropertys];
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
        _httpMertics = [MIHttpMetrics instanceHttpMetricWithNSURLSessionTaskMetrics:metrics];
        _request = metric.request;
        NSUInteger req_tim = [MIApmHelper currentTimestamp];
        MIHttpInfo *httpInfo = [MIHttpInfo instanceWithDate:req_tim
                                                   beginTim:0
                                                     endTim:0
                                                    request:_request
                                                   response:_response
                                                      error:_error
                                                   sendSize:_sendSize
                                                receiveSize:_receiveSize
                                                httpMetrics:_httpMertics];
        MIHttpModel *httpModel = [MIHttpModel instanceWithHttpModel:httpInfo];
        [[MIApmClient apmClient] miMonitorRes:httpModel];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {

    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
    _response = httpResponse;
    _error = error;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
//    NSLog(@"%s----",__func__);
    _receiveSize = data.length;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
//    NSLog(@"%s----",__func__);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
//   NSLog(@"%s----",__func__);
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
//    NSLog(@"%s----",__func__);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
//    NSLog(@"%s----",__func__);
    _sendSize = totalBytesSent;
}

@end
