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

static inline void mi_swizzleSelector(Class theClass, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(theClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(theClass, swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

static inline BOOL mi_addMethod(Class theClass, SEL selector, Method method) {
    return class_addMethod(theClass, selector,  method_getImplementation(method),  method_getTypeEncoding(method));
}

+ (void)miSwizzleResumeAndSuspendMethodForClass:(Class)theClass {
    Method afResumeMethod = class_getInstanceMethod(self, @selector(mi_resume));
    Method afSuspendMethod = class_getInstanceMethod(self, @selector(mi_suspend));
 
    if (mi_addMethod(theClass, @selector(mi_resume), afResumeMethod)) {
        mi_swizzleSelector(theClass, @selector(resume), @selector(mi_resume));
    }
 
    if (mi_addMethod(theClass, @selector(mi_suspend), afSuspendMethod)) {
        mi_swizzleSelector(theClass, @selector(suspend), @selector(mi_suspend));
    }
}

+ (void)load
{
    if (NSClassFromString(@"NSURLSessionTask")) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    #pragma GCC diagnostic push
    #pragma GCC diagnostic ignored "-Wnonnull"
        NSURLSessionDataTask *localDataTask = [session dataTaskWithURL:nil];
    #pragma clang diagnostic pop
        IMP originalAFResumeIMP = method_getImplementation(class_getInstanceMethod([self class], @selector(mi_resume)));
        Class currentClass = [localDataTask class];
        
        while (class_getInstanceMethod(currentClass, @selector(resume))) {
            Class superClass = [currentClass superclass];
            IMP classResumeIMP = method_getImplementation(class_getInstanceMethod(currentClass, @selector(resume)));
            IMP superclassResumeIMP = method_getImplementation(class_getInstanceMethod(superClass, @selector(resume)));
            if (classResumeIMP != superclassResumeIMP &&
                originalAFResumeIMP != classResumeIMP) {
                [self miSwizzleResumeAndSuspendMethodForClass:currentClass];
            }
            currentClass = [currentClass superclass];
        }
        
        [localDataTask cancel];
        [session finishTasksAndInvalidate];
    }

}

static  NSError *miSessionError = nil;
static  CFAbsoluteTime mi_startTime = 0;
static  NSUInteger mi_req_time = 0;

API_AVAILABLE(ios(10.0))
static  NSURLSessionTaskMetrics *_gMatrics = nil;

#pragma mark-NSURLSessionDelegate methods
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics  API_AVAILABLE(ios(10.0)){
    _gMatrics = metrics;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    if (@available(iOS 10.0,*)) {
        NSHTTPURLResponse *httpResponse =  (NSHTTPURLResponse *)task.response;
        NSURLRequest *request = task.currentRequest;
        CFAbsoluteTime endtime = (CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970)*1000;
        [MIApmHelper monitorSessionHttpWithRequest:request
                                        response:httpResponse
                                           error:error
                                         reqTime:mi_req_time
                                       beginTime:mi_startTime
                                         endTime:endtime];
        mi_req_time = 0;
        mi_startTime = 0;
    }else{
        [MIApmHelper monitorHttpWithSessionTaskMetrics:_gMatrics error:error];
        _gMatrics = nil;
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
//    NSLog(@"%s----",__func__);
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
}

#pragma mark - hook NSURLSessionTask methods
- (void)mi_resume
{
    mi_req_time = (NSUInteger)([[NSDate date] timeIntervalSince1970]);
    mi_startTime = (CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970)*1000;
    [self mi_resume];
}

- (void)mi_suspend
{
//    NSLog(@"%s,req_time:%lu,startTime:%f",__func__,(unsigned long)mi_req_time,mi_startTime);
    [self mi_suspend];
}


typedef void (^SessionCompletionHandler)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);
#pragma mark - hook NSURLSession methods
- (NSURLSessionDataTask *)mi_dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler
{
    SessionCompletionHandler hook_handler = ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        if (@available(iOS 10.0,*)) {
            [MIApmHelper monitorHttpWithSessionTaskMetrics:_gMatrics error:error];
            _gMatrics = nil;
          
        }else{
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response ;
                      CFAbsoluteTime endtime = (CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970)*1000;
                       [MIApmHelper monitorSessionHttpWithRequest:request
                                                         response:httpResponse
                                                            error:error
                                                          reqTime:mi_req_time
                                                        beginTime:mi_startTime
                                                          endTime:endtime];
           mi_req_time = 0;
           mi_startTime = 0;
        }
        if (completionHandler) {
            completionHandler(data,response,error);
        }
    };
    return [self mi_dataTaskWithRequest:request completionHandler:hook_handler];
}

// 下载
- (NSURLSessionDownloadTask *)mi_downloadTaskWithRequest:(NSURLRequest *)request {
//    NSLog(@"%s----",__func__);
    return [self mi_downloadTaskWithRequest:request];
}

- (NSURLSessionDownloadTask *)mi_downloadTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler
{
//    NSLog(@"%s----",__func__);
    return [self mi_downloadTaskWithRequest:request completionHandler:completionHandler];
}


// 上传
- (NSURLSessionUploadTask *)mi_uploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL {
//   NSLog(@"%s----",__func__);
    return [self mi_uploadTaskWithRequest:request fromFile:fileURL];
}

- (NSURLSessionUploadTask *)mi_uploadTaskWithRequest:(NSURLRequest *)request fromData:(NSData *)bodyData {
//   NSLog(@"%s----",__func__);
    return [self mi_uploadTaskWithRequest:request fromData:bodyData];
}

- (NSURLSessionUploadTask *)mi_uploadTaskWithStreamedRequest:(NSURLRequest *)request {
//   NSLog(@"%s----",__func__);
    return [self mi_uploadTaskWithStreamedRequest:request];
}

- (NSURLSessionUploadTask *)mi_uploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler {
//   NSLog(@"%s----",__func__);
    return [self mi_uploadTaskWithRequest:request fromFile:fileURL completionHandler:completionHandler];
}

- (NSURLSessionUploadTask *)mi_uploadTaskWithRequest:(NSURLRequest *)request fromData:(nullable NSData *)bodyData completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler {
//    NSLog(@"%s----",__func__);
    return [self mi_uploadTaskWithRequest:request fromData:bodyData completionHandler:completionHandler];
}


@end
