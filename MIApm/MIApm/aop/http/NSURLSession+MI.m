//
//  NSURLSession+MI.m
//  MIApm
//
//  Created by mediaios on 2019/4/3.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import "NSURLSession+MI.h"
#import "MIHook.h"
#import "MIHttpDelegate.h"
#import <objc/runtime.h>
#import "MIProxy.h"


@implementation NSURLSession (MI)

+ (void)hook
{
    [MIHook hookClass:@"NSURLSession" sel:@"sessionWithConfiguration:delegate:delegateQueue:" withClass:@"NSURLSession" sel:@"mi_sessionWithConfiguration:delegate:delegateQueue:"];
    [MIHook hookInstance:@"NSURLSession" sel:@"dataTaskWithRequest:completionHandler:" withClass:@"NSURLSession" sel:@"mi_dataTaskWithRequest:completionHandler:"];
    
    [MIHook hookInstance:@"NSURLSession" sel:@"downloadTaskWithRequest:" withClass:@"NSURLSession" sel:@"mi_downloadTaskWithRequest:"];
    [MIHook hookInstance:@"NSURLSession" sel:@"downloadTaskWithRequest:completionHandler:" withClass:@"NSURLSession" sel:@"mi_downloadTaskWithRequest:completionHandler:"];
    
    [MIHook hookInstance:@"NSURLSession" sel:@"uploadTaskWithRequest:fromFile:" withClass:@"NSURLSession" sel:@"mi_uploadTaskWithRequest:fromFile:"];
    [MIHook hookInstance:@"NSURLSession" sel:@"uploadTaskWithRequest:fromData:" withClass:@"NSURLSession" sel:@"mi_uploadTaskWithRequest:fromData:"];
    [MIHook hookInstance:@"NSURLSession" sel:@"uploadTaskWithStreamedRequest:" withClass:@"NSURLSession" sel:@"mi_uploadTaskWithStreamedRequest:"];
    [MIHook hookInstance:@"NSURLSession" sel:@"uploadTaskWithRequest:fromFile:completionHandler:" withClass:@"NSURLSession" sel:@"mi_uploadTaskWithRequest:fromFile:completionHandler:"];
    [MIHook hookInstance:@"NSURLSession" sel:@"uploadTaskWithRequest:fromData:completionHandler:" withClass:@"NSURLSession" sel:@"mi_uploadTaskWithRequest:fromData:completionHandler:"];
    
}

#pragma mark -swizzed method
+ (NSURLSession *)mi_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration delegate:(nullable id <NSURLSessionDelegate>)delegate delegateQueue:(nullable NSOperationQueue *)queue
{
    MIHttpDelegate *objDelegate = [[MIHttpDelegate alloc] init];
    if (delegate) {
        [[self class] registerDelegateMethod:@"URLSession:task:didFinishCollectingMetrics:" oriDelegate:delegate assistDelegate:objDelegate flag:"v@:@@@"];
        [[self class] registerDelegateMethod:@"URLSession:task:didCompleteWithError:" oriDelegate:delegate assistDelegate:objDelegate flag:"v@:@@@"];
        [[self class] registerDelegateMethod:@"URLSession:dataTask:didReceiveData:" oriDelegate:delegate assistDelegate:objDelegate flag:"v@:@@@"];
        
        [[self class] registerDelegateMethod:@"URLSession:downloadTask:didFinishDownloadingToURL:" oriDelegate:delegate assistDelegate:objDelegate flag:"v@:@@@"];
        [[self class] registerDelegateMethod:@"URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:" oriDelegate:delegate assistDelegate:objDelegate flag:"v@:@@@@@"];
        [[self class] registerDelegateMethod:@"URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:" oriDelegate:delegate assistDelegate:objDelegate flag:"v@:@@@@@"];
        [[self class] registerDelegateMethod:@"URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:" oriDelegate:delegate assistDelegate:objDelegate flag:"v@:@@@@@"];
        //        [[self class] registerDelegateMethod:@"URLSession:dataTask:didReceiveResponse:completionHandler:" oriDelegate:delegate assistDelegate:objectDelegate flag:"v@:@@@@"];
        
        delegate = [MIProxy proxyForObject:delegate delegate:objDelegate];
    }else{
        delegate = objDelegate;
    }
    
    return [self mi_sessionWithConfiguration:configuration delegate:delegate delegateQueue:queue];
}

- (NSURLSessionDataTask *)mi_dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler
{
    return [self mi_dataTaskWithRequest:request completionHandler:completionHandler];
}

// 下载
- (NSURLSessionDownloadTask *)mi_downloadTaskWithRequest:(NSURLRequest *)request {
    return [self mi_downloadTaskWithRequest:request];
}

- (NSURLSessionDownloadTask *)mi_downloadTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler
{
    return [self mi_downloadTaskWithRequest:request completionHandler:completionHandler];
}


// 上传
- (NSURLSessionUploadTask *)mi_uploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL {
   
    return [self mi_uploadTaskWithRequest:request fromFile:fileURL];
}

- (NSURLSessionUploadTask *)mi_uploadTaskWithRequest:(NSURLRequest *)request fromData:(NSData *)bodyData {
   
    return [self mi_uploadTaskWithRequest:request fromData:bodyData];
}

- (NSURLSessionUploadTask *)mi_uploadTaskWithStreamedRequest:(NSURLRequest *)request {
   
    return [self mi_uploadTaskWithStreamedRequest:request];
}

- (NSURLSessionUploadTask *)mi_uploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler {
   
    return [self mi_uploadTaskWithRequest:request fromFile:fileURL completionHandler:completionHandler];
}

- (NSURLSessionUploadTask *)mi_uploadTaskWithRequest:(NSURLRequest *)request fromData:(nullable NSData *)bodyData completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler {
    
    return [self mi_uploadTaskWithRequest:request fromData:bodyData completionHandler:completionHandler];
}



//代理方法分类处理
+ (void)registerDelegateMethod:(NSString *)method oriDelegate:(id<NSURLSessionDelegate>)oriDel assistDelegate:(MIHttpDelegate *)assiDel flag:(const char *)flag {
    if ([oriDel respondsToSelector:NSSelectorFromString(method)]) {
        IMP imp1 = class_getMethodImplementation([MIHttpDelegate class], NSSelectorFromString(method));
        IMP imp2 = class_getMethodImplementation([oriDel class], NSSelectorFromString(method));
        if (imp1 != imp2) {
            [assiDel registerSel:method];
        }
    } else {
        class_addMethod([oriDel class], NSSelectorFromString(method), class_getMethodImplementation([MIHttpDelegate class], NSSelectorFromString(method)), flag);
    }
}
@end
