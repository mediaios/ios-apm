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

static  NSError *miSessionError = nil;
static  NSURLSessionTaskMetrics *_gMatrics = nil;

#pragma mark-NSURLSessionDelegate methods
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics  API_AVAILABLE(ios(10.0)){
    _gMatrics = metrics;
    NSLog(@"%s",__func__);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    [MIApmHelper monitorHttpWithSessionTaskMetrics:_gMatrics error:error];
    _gMatrics = nil;
    NSLog(@"%s----",__func__);
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

typedef void (^SessionCompletionHandler)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);
#pragma mark - hook NSURLSession methods
- (NSURLSessionDataTask *)mi_dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler
{
    NSLog(@"%s----",__func__);
    SessionCompletionHandler hook_handler = ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
         [MIApmHelper monitorHttpWithSessionTaskMetrics:_gMatrics error:error];
        _gMatrics = nil;
        if (completionHandler) {
            completionHandler(data,response,error);
        }
    };
    return [self mi_dataTaskWithRequest:request completionHandler:hook_handler];
}

// 下载
- (NSURLSessionDownloadTask *)mi_downloadTaskWithRequest:(NSURLRequest *)request {
    NSLog(@"%s----",__func__);
    return [self mi_downloadTaskWithRequest:request];
}

- (NSURLSessionDownloadTask *)mi_downloadTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler
{
    NSLog(@"%s----",__func__);
    return [self mi_downloadTaskWithRequest:request completionHandler:completionHandler];
}


// 上传
- (NSURLSessionUploadTask *)mi_uploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL {
   NSLog(@"%s----",__func__);
    return [self mi_uploadTaskWithRequest:request fromFile:fileURL];
}

- (NSURLSessionUploadTask *)mi_uploadTaskWithRequest:(NSURLRequest *)request fromData:(NSData *)bodyData {
   NSLog(@"%s----",__func__);
    return [self mi_uploadTaskWithRequest:request fromData:bodyData];
}

- (NSURLSessionUploadTask *)mi_uploadTaskWithStreamedRequest:(NSURLRequest *)request {
   NSLog(@"%s----",__func__);
    return [self mi_uploadTaskWithStreamedRequest:request];
}

- (NSURLSessionUploadTask *)mi_uploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler {
   NSLog(@"%s----",__func__);
    return [self mi_uploadTaskWithRequest:request fromFile:fileURL completionHandler:completionHandler];
}

- (NSURLSessionUploadTask *)mi_uploadTaskWithRequest:(NSURLRequest *)request fromData:(nullable NSData *)bodyData completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler {
    NSLog(@"%s----",__func__);
    return [self mi_uploadTaskWithRequest:request fromData:bodyData completionHandler:completionHandler];
}


@end
