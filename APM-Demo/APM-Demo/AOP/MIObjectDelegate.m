//
//  MIObjectDelegate.m
//  APM-Demo
//
//  Created by ethan on 2019/4/4.
//  Copyright © 2019 ucloud. All rights reserved.
//

#import "MIObjectDelegate.h"

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
    NSLog(@"%s----",__func__);
}


#pragma mark -NSURLConnectionDataDelegate
- (nullable NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(nullable NSURLResponse *)response
{
    NSLog(@"%s----",__func__);
    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"%s----",__func__);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"%s----",__func__);
}

- (void)connection:(NSURLConnection *)connection   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    NSLog(@"%s----",__func__);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
     NSLog(@"%s----",__func__);
}


#pragma mark -NSURLConnectionDownloadDelegate

- (void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes
{
    NSLog(@"%s----",__func__);
}

- (void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes
{
    NSLog(@"%s----",__func__);
}

- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *) destinationURL
{
    NSLog(@"%s----",__func__);
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
        
        NSLog(@"\n tcptiming：%.f \n dnstime:%.f \n clientwasttiming:%.f \n sslTime:%.f \n firsttiming:%.f \n tttiming:%.f", tcptiming,dnstiming ,clientwasttiming,ssltiming, firsttiming,tttiming);
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
