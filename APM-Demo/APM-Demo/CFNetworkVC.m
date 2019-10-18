//
//  CFNetworkVC.m
//  APM-Demo
//
//  Created by mediaios on 2019/10/18.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import "CFNetworkVC.h"

@interface CFNetworkVC ()

@end

@implementation CFNetworkVC

void cfNetCallBack(CFReadStreamRef stream,CFStreamEventType type, void *clientCallBackInfo);

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

void cfNetCallBack(CFReadStreamRef stream,CFStreamEventType type, void *clientCallBackInfo)
{
    CFHTTPMessageRef myResponse = (CFHTTPMessageRef)CFReadStreamCopyProperty(stream, kCFStreamPropertyHTTPResponseHeader);
    CFStringRef myStatusLine = CFHTTPMessageCopyResponseStatusLine(myResponse);
    UInt32 myErrCode = CFHTTPMessageGetResponseStatusCode(myResponse);
    NSLog(@"statusLine: %@ ,statusCode:%d",myStatusLine,myErrCode);
    
    if (type == kCFStreamEventHasBytesAvailable) {
        UInt8 buff[1024];
        CFReadStreamRead(stream, buff, 1024);
        printf("%s\n",buff);
    }else if(type == kCFStreamEventOpenCompleted){
        NSLog(@"open");
    }else if(type == kCFStreamEventErrorOccurred){
        NSLog(@"error:%@",CFErrorCopyDescription(CFReadStreamCopyError(stream)));
    }else if(type == kCFStreamEventCanAcceptBytes){
        NSLog(@"KCFStreamEventCanAcceptBytes");
    }else if(type == kCFStreamEventEndEncountered){
        NSLog(@"end");
        CFReadStreamClose(stream);
        CFReadStreamUnscheduleFromRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    }
}



- (IBAction)getmethod:(id)sender {
      CFStringRef method = CFSTR("GET");
      CFStringRef urlStr = CFSTR("http://apis.juhe.cn/simpleWeather/query?city=%E4%B8%8A%E6%B5%B7&key=5be112d55b4fe1fc620b4a662904b4d8");
      CFURLRef url = CFURLCreateWithString(kCFAllocatorDefault, urlStr, NULL);
      CFHTTPMessageRef request = CFHTTPMessageCreateRequest(kCFAllocatorDefault, method, url, kCFHTTPVersion1_1);
      CFReadStreamRef readStream = CFReadStreamCreateForHTTPRequest(kCFAllocatorDefault, request);
      CFStreamClientContext ctxt = {0,(__bridge void *)(self),NULL,NULL,NULL};
      CFReadStreamSetClient(readStream, kCFStreamEventHasBytesAvailable | kCFStreamEventEndEncountered |kCFStreamEventOpenCompleted|kCFStreamEventCanAcceptBytes|kCFStreamEventErrorOccurred, cfNetCallBack, &ctxt);
      CFReadStreamScheduleWithRunLoop(readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
      
       // 开启流
      printf("%d\n",CFReadStreamOpen(readStream));
}

- (IBAction)postmethod:(id)sender {
      CFStringRef method = CFSTR("POST");
      CFStringRef urlStr = CFSTR("http://apis.juhe.cn/simpleWeather/query");
      CFURLRef url = CFURLCreateWithString(kCFAllocatorDefault, urlStr, NULL);
      CFHTTPMessageRef request = CFHTTPMessageCreateRequest(kCFAllocatorDefault,method,url,kCFHTTPVersion1_1);
      NSString  *params = @"city=上海&key=5be112d55b4fe1fc620b4a662904b4d8";
      NSData *dataParam = [params dataUsingEncoding:NSUTF8StringEncoding];
      CFHTTPMessageSetBody(request, (__bridge CFDataRef)dataParam);
      CFHTTPMessageSetHeaderFieldValue(request, CFSTR("Content-Type"), CFSTR("application/x-www-form-urlencoded"));
      CFReadStreamRef readStream = CFReadStreamCreateForHTTPRequest(kCFAllocatorDefault, request);
      CFStreamClientContext ctxt = {0,(__bridge void *)(self),NULL,NULL,NULL};
      CFReadStreamSetClient(readStream, kCFStreamEventHasBytesAvailable | kCFStreamEventEndEncountered |kCFStreamEventOpenCompleted|kCFStreamEventCanAcceptBytes|kCFStreamEventErrorOccurred, cfNetCallBack, &ctxt);
      CFReadStreamScheduleWithRunLoop(readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
       // 开启流
      printf("%d\n",CFReadStreamOpen(readStream));
}

@end
