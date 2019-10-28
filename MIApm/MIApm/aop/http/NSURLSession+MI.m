//
//  NSURLSession+MI.m
//  MIApm
//
//  Created by mediaios on 2019/4/3.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import "NSURLSession+MI.h"
#import "MIHook.h"
#import "MINSSessionDelegate.h"
#import <objc/runtime.h>
#import "MIProxy.h"


@implementation NSURLSession (MI)

+ (void)hook
{
    [MIHook hookClass:@"NSURLSession" sel:@"sessionWithConfiguration:delegate:delegateQueue:" withClass:@"NSURLSession" sel:@"mi_sessionWithConfiguration:delegate:delegateQueue:"];
    [MIHook hookInstanceToOtherClass:@"NSURLSession" sel:@"dataTaskWithRequest:completionHandler:" withClass:@"MINSSessionDelegate" sel:@"mi_dataTaskWithRequest:completionHandler:"];
    
    [MIHook hookInstanceToOtherClass:@"NSURLSession" sel:@"downloadTaskWithRequest:" withClass:@"MINSSessionDelegate" sel:@"mi_downloadTaskWithRequest:"];
    [MIHook hookInstanceToOtherClass:@"NSURLSession" sel:@"downloadTaskWithRequest:completionHandler:" withClass:@"MINSSessionDelegate" sel:@"mi_downloadTaskWithRequest:completionHandler:"];
    
    [MIHook hookInstanceToOtherClass:@"NSURLSession" sel:@"uploadTaskWithRequest:fromFile:" withClass:@"MINSSessionDelegate" sel:@"mi_uploadTaskWithRequest:fromFile:"];
    [MIHook hookInstanceToOtherClass:@"NSURLSession" sel:@"uploadTaskWithRequest:fromData:" withClass:@"MINSSessionDelegate" sel:@"mi_uploadTaskWithRequest:fromData:"];
    [MIHook hookInstanceToOtherClass:@"NSURLSession" sel:@"uploadTaskWithStreamedRequest:" withClass:@"MINSSessionDelegate" sel:@"mi_uploadTaskWithStreamedRequest:"];
    [MIHook hookInstanceToOtherClass:@"NSURLSession" sel:@"uploadTaskWithRequest:fromFile:completionHandler:" withClass:@"MINSSessionDelegate" sel:@"mi_uploadTaskWithRequest:fromFile:completionHandler:"];
    [MIHook hookInstanceToOtherClass:@"NSURLSession" sel:@"uploadTaskWithRequest:fromData:completionHandler:" withClass:@"MINSSessionDelegate" sel:@"mi_uploadTaskWithRequest:fromData:completionHandler:"];
    
}

#pragma mark -swizzed method
+ (NSURLSession *)mi_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration delegate:(nullable id <NSURLSessionDelegate>)delegate delegateQueue:(nullable NSOperationQueue *)queue
{
    MINSSessionDelegate *objDelegate = [[MINSSessionDelegate alloc] init];
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

//代理方法分类处理
+ (void)registerDelegateMethod:(NSString *)method oriDelegate:(id<NSURLSessionDelegate>)oriDel assistDelegate:(MINSSessionDelegate *)assiDel flag:(const char *)flag {
    if ([oriDel respondsToSelector:NSSelectorFromString(method)]) {
        IMP imp1 = class_getMethodImplementation([MINSSessionDelegate class], NSSelectorFromString(method));
        IMP imp2 = class_getMethodImplementation([oriDel class], NSSelectorFromString(method));
        if (imp1 != imp2) {
            [assiDel registerSel:method];
        }
    } else {
        class_addMethod([oriDel class], NSSelectorFromString(method), class_getMethodImplementation([MINSSessionDelegate class], NSSelectorFromString(method)), flag);
    }
}
@end
