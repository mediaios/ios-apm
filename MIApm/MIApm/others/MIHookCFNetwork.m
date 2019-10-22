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
#import "MINSStreamDelegate.h"
#import "MINSStreamProxy.h"
#import "MIInputStream.h"
#import "MIHttpDelegate.h"
#import "MIProxy.h"


@interface MIHookCFNetwork()<NSStreamDelegate>

@end

@implementation MIHookCFNetwork

static CFReadStreamRef (*orig_CFReadStreamCreateForHTTPRequest)(CFAllocatorRef __nullable alloc, CFHTTPMessageRef request);
static CFReadStreamRef (*orig_CFReadStreamCreateForStreamedHTTPRequest)(CFAllocatorRef __nullable alloc, CFHTTPMessageRef requestHeaders, CFReadStreamRef requestBody);
static Boolean (*orig_CFReadStreamSetClient)(CFReadStreamRef _Null_unspecified stream, CFOptionFlags streamEvents, CFReadStreamClientCallBack _Null_unspecified clientCB, CFStreamClientContext * _Null_unspecified clientContext);
static Boolean (*orig_CFReadStreamOpen)(CFReadStreamRef _Null_unspecified stream);
static CFIndex (*orig_CFReadStreamRead)(CFReadStreamRef _Null_unspecified stream, UInt8 * _Null_unspecified buffer, CFIndex bufferLength);
static void (*orig_CFReadStreamClose)(CFReadStreamRef _Null_unspecified stream);


void save_orignal_symbols(){
    orig_CFReadStreamCreateForHTTPRequest = dlsym(RTLD_DEFAULT, "CFReadStreamCreateForHTTPRequest");
    orig_CFReadStreamCreateForStreamedHTTPRequest = dlsym(RTLD_DEFAULT, "CFReadStreamCreateForStreamedHTTPRequest");
    orig_CFReadStreamSetClient = dlsym(RTLD_DEFAULT, "CFReadStreamSetClient");
    orig_CFReadStreamOpen = dlsym(RTLD_DEFAULT, "CFReadStreamOpen");
    orig_CFReadStreamRead = dlsym(RTLD_DEFAULT, "CFReadStreamRead");
    orig_CFReadStreamClose = dlsym(RTLD_DEFAULT, "CFReadStreamClose");
}


CFReadStreamRef MI_CFReadStreamCreateForHTTPRequest(CFAllocatorRef __nullable alloc, CFHTTPMessageRef request)
{
    CFReadStreamRef originalStream = orig_CFReadStreamCreateForHTTPRequest(alloc,request);
    // 将 CFReadStreamRef 转换成 NSInputStream，并保存在 XXInputStreamProxy，最后返回的时候再转回 CFReadStreamRef
    NSInputStream *stream = (__bridge NSInputStream *)originalStream;
    MINSStreamProxy *outStream = [[MINSStreamProxy alloc] initWithStream:stream];
    CFRelease(originalStream);
    CFReadStreamRef result = (__bridge_retained CFReadStreamRef)((id)outStream);
    return result;
}

CFReadStreamRef MI_CFReadStreamCreateForStreamedHTTPRequest(CFAllocatorRef __nullable alloc, CFHTTPMessageRef requestHeaders, CFReadStreamRef requestBody)
{
    CFReadStreamRef readStreamRef = orig_CFReadStreamCreateForStreamedHTTPRequest(alloc,requestHeaders,requestBody);
    printf(__func__);
    printf("\n");
    return readStreamRef;
}

static MIHookCFNetwork *global_cfnetwork = nil;

Boolean MI_CFReadStreamSetClient(CFReadStreamRef _Null_unspecified stream, CFOptionFlags streamEvents, CFReadStreamClientCallBack _Null_unspecified clientCB, CFStreamClientContext * _Null_unspecified clientContext)
{
    NSInputStream *inputStream = (__bridge NSInputStream *)stream;
    inputStream.delegate = global_cfnetwork;
    
    Boolean b = orig_CFReadStreamSetClient(stream,streamEvents,clientCB,clientContext);
    printf(__func__);
    printf("\n");
    return b;
}

Boolean MI_CFReadStreamOpen(CFReadStreamRef _Null_unspecified stream)
{
//    MIOriginalStream *inputStream = (__bridge MIOriginalStream *)stream;
//    [inputStream open];
    
    Boolean b = orig_CFReadStreamOpen(stream);
    printf(__func__);
    printf("\n");
    return b;
}

CFIndex MI_CFReadStreamRead(CFReadStreamRef _Null_unspecified stream, UInt8 * _Null_unspecified buffer, CFIndex bufferLength)
{
    
//    MIOriginalStream *inputStream = (__bridge MIOriginalStream *)stream;
//    [inputStream read:buffer maxLength:bufferLength];
    
    CFHTTPMessageRef myResponse = (CFHTTPMessageRef)CFReadStreamCopyProperty(stream, kCFStreamPropertyHTTPResponseHeader);
    CFStringRef myStatusLine = CFHTTPMessageCopyResponseStatusLine(myResponse);
    UInt32 myErrCode = CFHTTPMessageGetResponseStatusCode(myResponse);
    NSLog(@"statusLine: %@ ,statusCode:%d",myStatusLine,myErrCode);
    
    CFIndex index = orig_CFReadStreamRead(stream,buffer,bufferLength);
    printf(__func__);
    printf("\n");
    return index;
}


void MI_CFReadStreamClose(CFReadStreamRef _Null_unspecified stream)
{
    printf(__func__);
       printf("\n");
    return orig_CFReadStreamClose(stream);
}


+ (void)hook
{
    if (!global_cfnetwork) {
        global_cfnetwork = [[MIHookCFNetwork alloc] init];
    }
    save_orignal_symbols();
    rebind_symbols((struct rebinding[6]){
        {"CFReadStreamCreateForHTTPRequest",MI_CFReadStreamCreateForHTTPRequest,(void *)&orig_CFReadStreamCreateForHTTPRequest},
        {"CFReadStreamCreateForStreamedHTTPRequest",MI_CFReadStreamCreateForStreamedHTTPRequest,(void *)&orig_CFReadStreamCreateForStreamedHTTPRequest},
        {"CFReadStreamSetClient",MI_CFReadStreamSetClient,(void *)&orig_CFReadStreamSetClient},
        {"CFReadStreamOpen",MI_CFReadStreamOpen,(void *)&orig_CFReadStreamOpen},
        {"CFReadStreamRead",MI_CFReadStreamRead,(void *)&orig_CFReadStreamRead},
        {"CFReadStreamClose",MI_CFReadStreamClose,(void *)&orig_CFReadStreamClose}
    }, 6);
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    NSLog(@"%s",__func__);
}

@end
