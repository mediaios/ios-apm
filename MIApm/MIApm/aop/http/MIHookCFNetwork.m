//
//  MIHookCFNetwork.m
//  MIApm
//
//  Created by mediaios on 2019/10/18.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import "MIHookCFNetwork.h"
#import "fishhook.h"
#import <dlfcn.h>
#import <objc/runtime.h>
#import "MIInputStream.h"
#import "MICFNetworkProxy.h"
#import "MINSStreamDelegate.h"


@implementation MIHookCFNetwork

static CFReadStreamRef (*orig_CFReadStreamCreateForHTTPRequest)(CFAllocatorRef __nullable alloc, CFHTTPMessageRef request);
static CFReadStreamRef (*orig_CFReadStreamCreateForStreamedHTTPRequest)(CFAllocatorRef __nullable alloc, CFHTTPMessageRef requestHeaders, CFReadStreamRef requestBody);
static Boolean (*orig_CFReadStreamSetClient)(CFReadStreamRef _Null_unspecified stream, CFOptionFlags streamEvents, CFReadStreamClientCallBack _Null_unspecified clientCB, CFStreamClientContext * _Null_unspecified clientContext);
static Boolean (*orig_CFReadStreamOpen)(CFReadStreamRef _Null_unspecified stream);
static CFIndex (*orig_CFReadStreamRead)(CFReadStreamRef _Null_unspecified stream, UInt8 * _Null_unspecified buffer, CFIndex bufferLength);

void save_orignal_symbols(){
    orig_CFReadStreamCreateForHTTPRequest = dlsym(RTLD_DEFAULT, "CFReadStreamCreateForHTTPRequest");
    orig_CFReadStreamCreateForStreamedHTTPRequest = dlsym(RTLD_DEFAULT, "CFReadStreamCreateForStreamedHTTPRequest");
    orig_CFReadStreamSetClient = dlsym(RTLD_DEFAULT, "CFReadStreamSetClient");
    orig_CFReadStreamOpen = dlsym(RTLD_DEFAULT, "CFReadStreamOpen");
    orig_CFReadStreamRead = dlsym(RTLD_DEFAULT, "CFReadStreamRead");
}

CFReadStreamRef MI_CFReadStreamCreateForHTTPRequest(CFAllocatorRef __nullable alloc, CFHTTPMessageRef request)
{
    CFReadStreamRef readStreamRef = orig_CFReadStreamCreateForHTTPRequest(alloc,request);
    // 将 CFReadStreamRef 转换成 NSInputStream，并保存在 XXInputStreamProxy，最后返回的时候再转回 CFReadStreamRef
    NSInputStream *stream = (__bridge NSInputStream *)readStreamRef;
    MIInputStream *outStream = [[MIInputStream alloc] initWithStream:stream];
    CFRelease(readStreamRef);
    CFReadStreamRef result = (__bridge_retained CFReadStreamRef)outStream;
    return result;
}

CFReadStreamRef MI_CFReadStreamCreateForStreamedHTTPRequest(CFAllocatorRef __nullable alloc, CFHTTPMessageRef requestHeaders, CFReadStreamRef requestBody)
{
    CFReadStreamRef readStreamRef = orig_CFReadStreamCreateForStreamedHTTPRequest(alloc,requestHeaders,requestBody);
    printf(__func__);
    printf("\n");
    return readStreamRef;
}

Boolean MI_CFReadStreamSetClient(CFReadStreamRef _Null_unspecified stream, CFOptionFlags streamEvents, CFReadStreamClientCallBack _Null_unspecified clientCB, CFStreamClientContext * _Null_unspecified clientContext)
{
    Boolean b = orig_CFReadStreamSetClient(stream,streamEvents,clientCB,clientContext);
    printf(__func__);
    printf("\n");
    return b;
}

Boolean MI_CFReadStreamOpen(CFReadStreamRef _Null_unspecified stream)
{
    Boolean b = orig_CFReadStreamOpen(stream);
    printf(__func__);
    printf("\n");
    return b;
}

CFIndex MI_CFReadStreamRead(CFReadStreamRef _Null_unspecified stream, UInt8 * _Null_unspecified buffer, CFIndex bufferLength)
{
    
    MINSStreamDelegate *streamDelegate = [[MINSStreamDelegate alloc] init];
    if (streamDelegate) {
        [MIHookCFNetwork ]
    }
    
    CFHTTPMessageRef myResponse = (CFHTTPMessageRef)CFReadStreamCopyProperty(stream, kCFStreamPropertyHTTPResponseHeader);
    CFStringRef myStatusLine = CFHTTPMessageCopyResponseStatusLine(myResponse);
    UInt32 myErrCode = CFHTTPMessageGetResponseStatusCode(myResponse);
    NSLog(@"statusLine: %@ ,statusCode:%d",myStatusLine,myErrCode);
    
    
    CFIndex index = orig_CFReadStreamRead(stream,buffer,bufferLength);
    printf(__func__);
    printf("\n");
    return index;
}


+ (void)hook
{
    save_orignal_symbols();
    rebind_symbols((struct rebinding[5]){
        {"CFReadStreamCreateForHTTPRequest",MI_CFReadStreamCreateForHTTPRequest,(void *)&orig_CFReadStreamCreateForHTTPRequest},
        {"CFReadStreamCreateForStreamedHTTPRequest",MI_CFReadStreamCreateForStreamedHTTPRequest,(void *)&orig_CFReadStreamCreateForStreamedHTTPRequest},
        {"CFReadStreamSetClient",MI_CFReadStreamSetClient,(void *)&orig_CFReadStreamSetClient},
        {"CFReadStreamOpen",MI_CFReadStreamOpen,(void *)&orig_CFReadStreamOpen},
        {"CFReadStreamRead",MI_CFReadStreamRead,(void *)&orig_CFReadStreamRead}
    }, 5);
}


//代理方法分类处理
+ (void)registerDelegateMethod:(NSString *)method oriDelegate:(id<NSStreamDelegate>)oriDel assistDelegate:(MINSStreamDelegate *)assiDel flag:(const char *)flag {
    if ([oriDel respondsToSelector:NSSelectorFromString(method)]) {
        IMP imp1 = class_getMethodImplementation([MINSStreamDelegate class], NSSelectorFromString(method));
        IMP imp2 = class_getMethodImplementation([oriDel class], NSSelectorFromString(method));
        if (imp1 != imp2) {
            [assiDel registerSel:method];
        }
    } else {
        class_addMethod([oriDel class], NSSelectorFromString(method), class_getMethodImplementation([MINSStreamDelegate class], NSSelectorFromString(method)), flag);
    }
}

@end
