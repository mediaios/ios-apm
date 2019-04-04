//
//  NSURLConnection+MI.m
//  APM-Demo
//
//  Created by ethan on 2019/4/3.
//  Copyright © 2019 ucloud. All rights reserved.
//

#import "NSURLConnection+MI.h"
#import "MIHook.h"

typedef void (^CompletionHandler)(NSURLResponse* _Nullable response, NSData* _Nullable data, NSError* _Nullable connectionError);
@implementation NSURLConnection (MI)

+ (void)hook
{
    // hook NSURLConnection 中的方法
    [MIHook hookClass:@"NSURLConnection" sel:@"sendSynchronousRequest:returningResponse:error:" withClass:@"NSURLConnection" sel:@"mi_sendSynchronousRequest:returningResponse:error:"];
    [MIHook hookClass:@"NSURLConnection" sel:@"sendAsynchronousRequest:queue:completionHandler:" withClass:@"NSURLConnection" sel:@"mi_sendAsynchronousRequest:queue:completionHandler:"];
    
    [MIHook hookInstance:@"NSURLConnection" sel:@"initWithRequest:delegate:startImmediately:" withClass:@"NSURLConnection" sel:@"mi_initWithRequest:delegate:startImmediately:"];
    [MIHook hookInstance:@"NSURLConnection" sel:@"initWithRequest:delegate:" withClass:@"NSURLConnection" sel:@"mi_initWithRequest:delegate:"];
    
    [MIHook hookInstance:@"NSURLConnection" sel:@"start" withClass:@"NSURLConnection" sel:@"hook_start"];
    [MIHook hookInstance:@"NSURLConnection" sel:@"cancel" withClass:@"NSURLConnection" sel:@"hook_cancel"];
    
}


#pragma mark -swizzed method
+ (nullable NSData *)mi_sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse * _Nullable * _Nullable)response error:(NSError **)error
{
    NSLog(@"%s----",__func__);
    NSMutableURLRequest *mutaReq  = (NSMutableURLRequest *)request;
    [[self class] monitorRequest:mutaReq];
    // 发送请求
    NSData *data  = [[self class] mi_sendSynchronousRequest:request returningResponse:response error:error];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)(*response);
    [[self class] monitorResponse:httpResponse data:data error:*error];
    
    return [[self class] mi_sendSynchronousRequest:request returningResponse:response error:error];
}

+ (void)mi_sendAsynchronousRequest:(NSURLRequest*)request queue:(NSOperationQueue*)queue completionHandler:(void (^)(NSURLResponse* _Nullable response, NSData* _Nullable data, NSError* _Nullable connectionError)) handler
{
    NSLog(@"%s----",__func__);
    NSMutableURLRequest *mutaReq = (NSMutableURLRequest *)request;
    [[self class] monitorRequest:mutaReq];
    CompletionHandler hook_handler = ^(NSURLResponse * _Nullable response, NSData* _Nullable data, NSError* _Nullable connectionError){
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        [self monitorResponse:httpResponse data:data error:connectionError];
        if (handler) {
            handler(httpResponse,data,connectionError);
        }
    };
    
    [[self class] mi_sendAsynchronousRequest:request queue:queue completionHandler:hook_handler];
}

- (nullable instancetype)mi_initWithRequest:(NSURLRequest *)request delegate:(nullable id)delegate startImmediately:(BOOL)startImmediately
{
    NSLog(@"%s----",__func__);
    return [self mi_initWithRequest:request delegate:delegate startImmediately:startImmediately];
}

- (nullable instancetype)mi_initWithRequest:(NSURLRequest *)request delegate:(nullable id)delegate
{
    NSLog(@"%s----",__func__);
    return [self mi_initWithRequest:request delegate:delegate];
}

- (void)mi_start
{
    NSLog(@"%s----",__func__);
    [self mi_start];
}

- (void)mi_cancel
{
    NSLog(@"%s----",__func__);
    [self mi_cancel];
}

static CFAbsoluteTime beginTime = 0;
static CFAbsoluteTime endTime = 0;

+ (void)monitorRequest:(NSURLRequest *)req
{
    CFAbsoluteTime time = CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970;
    beginTime = time*1000;
    NSLog(@"begin time: %.f",time * 1000);
}

+ (void)monitorResponse:(NSHTTPURLResponse *)httpResponse data:(NSData *)data error:(NSError *)error
{
    CFAbsoluteTime time = CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970;
    endTime = time*1000;
    NSLog(@"end time: %.f",time * 1000);
    NSLog(@"时长: %.f",endTime-beginTime);
    
    NSUInteger bodySize = data.length;
    //响应相关监控
    NSInteger statusCode = httpResponse.statusCode;
    if (error) {

    } else {
        switch (statusCode) {
            case 200:
            case 304:
                NSLog(@"请求成功,body size: %ld KB",bodySize/1024);
                break;
            default:
                NSLog(@"请求失败");
                break;
        }
        //        [[NMCache sharedNMCache] cacheValue:[NSString stringWithFormat:@"%lu", (unsigned long)httpResponse.description.length + data.length] key:NMDATA_KEY_RESPONSESIZE traceId:traceId];
    }
}

@end
