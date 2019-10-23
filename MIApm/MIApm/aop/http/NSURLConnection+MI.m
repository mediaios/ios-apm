//
//  NSURLConnection+MI.m
//  MIApm
//
//  Created by mediaios on 2019/4/3.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import "NSURLConnection+MI.h"
#import "MIApmHelper.h"
#import "MIHook.h"
#import "MIHttpDelegate.h"
#import "MIProxy.h"
#import <objc/runtime.h>
#import "MIHttpModel.h"
#import "MIHttpInfo.h"
#import "MIApmClient.h"

typedef void (^CompletionHandler)(NSURLResponse* _Nullable response, NSData* _Nullable data, NSError* _Nullable connectionError);
@implementation NSURLConnection (MI)

+ (void)hook
{
    // hook NSURLConnection 中的方法
    [MIHook hookClass:@"NSURLConnection" sel:@"sendSynchronousRequest:returningResponse:error:" withClass:@"NSURLConnection" sel:@"mi_sendSynchronousRequest:returningResponse:error:"];
    [MIHook hookClass:@"NSURLConnection" sel:@"sendAsynchronousRequest:queue:completionHandler:" withClass:@"NSURLConnection" sel:@"mi_sendAsynchronousRequest:queue:completionHandler:"];
    
    [MIHook hookInstance:@"NSURLConnection" sel:@"initWithRequest:delegate:startImmediately:" withClass:@"NSURLConnection" sel:@"mi_initWithRequest:delegate:startImmediately:"];
    [MIHook hookInstance:@"NSURLConnection" sel:@"initWithRequest:delegate:" withClass:@"NSURLConnection" sel:@"mi_initWithRequest:delegate:"];
    
    [MIHook hookInstance:@"NSURLConnection" sel:@"start" withClass:@"NSURLConnection" sel:@"mi_start"];
    [MIHook hookInstance:@"NSURLConnection" sel:@"cancel" withClass:@"NSURLConnection" sel:@"mi_cancel"];
}


#pragma mark -swizzed method
+ (nullable NSData *)mi_sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse * _Nullable * _Nullable)response error:(NSError **)error
{
    NSMutableURLRequest *mutaReq  = (NSMutableURLRequest *)request;
    NSString *url_str = mutaReq.URL.absoluteString;
    NSString *req_method = mutaReq.HTTPMethod;
    NSUInteger req_tim = [MIApmHelper currentTimestamp];
    CFAbsoluteTime begintime = (CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970)*1000;
    // 发送请求
    NSData *data  = [[self class] mi_sendSynchronousRequest:request returningResponse:response error:error];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)*response ;
    CFAbsoluteTime endtime = (CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970)*1000;
    MIHttpInfo *httpInfo = [MIHttpInfo instanceWithDate:req_tim beginTim:begintime endTim:endtime request:request response:httpResponse error:*error sendSize:0 receiveSize:0 httpMetrics:nil];
    [[self class] monitorHttpInfo:httpInfo];
    return data;
}

+ (void)mi_sendAsynchronousRequest:(NSURLRequest*)request queue:(NSOperationQueue*)queue completionHandler:(void (^)(NSURLResponse* _Nullable response, NSData* _Nullable data, NSError* _Nullable connectionError)) handler
{
    NSMutableURLRequest *mutaReq = (NSMutableURLRequest *)request;
    NSString *url_str = mutaReq.URL.absoluteString;
    NSString *req_method = mutaReq.HTTPMethod;
    NSUInteger req_tim = [MIApmHelper currentTimestamp];
    CFAbsoluteTime begintime = (CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970)*1000;
    CompletionHandler hook_handler = ^(NSURLResponse * _Nullable response, NSData* _Nullable data, NSError* _Nullable connectionError){
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        CFAbsoluteTime endtime = (CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970)*1000;
        MIHttpInfo *httpInfo = [MIHttpInfo instanceWithDate:req_tim beginTim:begintime endTim:endtime request:request response:httpResponse error:connectionError sendSize:0 receiveSize:0 httpMetrics:nil];
        [[self class] monitorHttpInfo:httpInfo];
        if (handler) {
            handler(httpResponse,data,connectionError);
        }
    };
    
    [[self class] mi_sendAsynchronousRequest:request queue:queue completionHandler:hook_handler];
}

- (nullable instancetype)mi_initWithRequest:(NSURLRequest *)request delegate:(nullable id)delegate startImmediately:(BOOL)startImmediately
{
    return [self mi_initWithRequest:request delegate:[self processDelegate:delegate] startImmediately:startImmediately];
}

- (nullable instancetype)mi_initWithRequest:(NSURLRequest *)request delegate:(nullable id)delegate
{
    return [self mi_initWithRequest:request delegate:[self processDelegate:delegate]];
}

- (void)mi_start
{
    NSLog(@"qizhang--debug-----%s",__func__);
    [self mi_start];
}

- (void)mi_cancel
{
    [self mi_cancel];
}

- (id)processDelegate:(id)delegate
{
    MIHttpDelegate *objectDelegate = [[MIHttpDelegate alloc] init];
    if (delegate) {
        [self registerDelegateMethod:@"connection:didFailWithError:" oriDelegate:delegate assistDelegate:objectDelegate flag:"v@:@@"];
        [self registerDelegateMethod:@"connection:didReceiveResponse:" oriDelegate:delegate assistDelegate:objectDelegate flag:"v@:@@"];
        [self registerDelegateMethod:@"connection:didReceiveData:" oriDelegate:delegate assistDelegate:objectDelegate flag:"v@:@@"];
        [self registerDelegateMethod:@"connection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:" oriDelegate:delegate assistDelegate:objectDelegate flag:"v@:@@@@"];
        [self registerDelegateMethod:@"connectionDidFinishLoading:" oriDelegate:delegate assistDelegate:objectDelegate flag:"v@:@"];
        [self registerDelegateMethod:@"connection:willSendRequest:redirectResponse:" oriDelegate:delegate assistDelegate:objectDelegate flag:"@@:@@"];
        
        
        [self registerDownloadDelegateMethod:@"connection:didWriteData:totalBytesWritten:expectedTotalBytes:" oriDelegate:delegate assistDelegate:objectDelegate];
        [self registerDownloadDelegateMethod:@"connectionDidResumeDownloading:totalBytesWritten:expectedTotalBytes:" oriDelegate:delegate assistDelegate:objectDelegate];
        [self registerDownloadDelegateMethod:@"connectionDidFinishDownloading:destinationURL:" oriDelegate:delegate assistDelegate:objectDelegate];
        
        delegate = [MIProxy proxyForObject:delegate delegate:objectDelegate];
        
    }else{
        delegate = objectDelegate;
    }
    return delegate;
}

- (void)registerDelegateMethod:(NSString *)method
                   oriDelegate:(id)oriDel
                assistDelegate:(MIHttpDelegate *)assiDel
                          flag:(const char *)flag
{
    if ([oriDel respondsToSelector:NSSelectorFromString(method)]) {
        IMP imp1 = class_getMethodImplementation([MIHttpDelegate class], NSSelectorFromString(method));
        IMP imp2 = class_getMethodImplementation([oriDel class], NSSelectorFromString(method));
        if (imp1 != imp2) {
            [assiDel registerSel:method];
        }
    }else{
        class_addMethod([oriDel class], NSSelectorFromString(method), class_getMethodImplementation([MIHttpDelegate class], NSSelectorFromString(method)), flag);
    }
}

+ (void)monitorHttpInfo:(MIHttpInfo *)httpInfo
{
    MIHttpModel *httpModel = [MIHttpModel instanceWithHttpModel:httpInfo];
    NSLog(@"qizhang--debug---%@",httpModel);
    [[MIApmClient apmClient] miMonitorRes:httpModel];
}

- (void)registerDownloadDelegateMethod:(NSString *)method
                           oriDelegate:(id)oriDel
                        assistDelegate:(MIHttpDelegate *)assiDel
{
    if([oriDel respondsToSelector:NSSelectorFromString(method)]){
        [assiDel registerSel:method];
    }
}

@end
