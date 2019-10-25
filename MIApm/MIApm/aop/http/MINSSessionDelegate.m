//
//  MIHttpDelegate.m
//  MIApm
//
//  Created by mediaios on 2019/4/4.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import "MINSSessionDelegate.h"
#import "MIApmHelper.h"
#import "MIHttpModel.h"
#import "MIApmClient.h"
#import "MIHook.h"
#import <objc/runtime.h>
#import "MIProxy.h"
@interface MINSSessionDelegate()
@property (nonatomic,strong) NSMutableArray *selList;
@property (nonatomic,strong) NSURLSessionTaskMetrics *gMatrics;
@end

@implementation MINSSessionDelegate

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
    _gMatrics = nil;
}

static BOOL _isMISendData = NO;

#pragma mark-NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics  API_AVAILABLE(ios(10.0)){
    if (metrics){
        _isMISendData = NO;
        _gMatrics = metrics;
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    NSLog(@"%s",__func__);
    if (@available(iOS 10.0, *)) {
        [MIApmHelper monitorHttpWithSessionTaskMetrics:_gMatrics error:error];
        _isMISendData = YES;
    } else {
        // Fallback on earlier versions
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
}

@end
