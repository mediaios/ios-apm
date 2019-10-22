//
//  UIWebView+MI.m
//  MIApm
//
//  Created by mediaios on 2019/4/12.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import "UIWebView+MI.h"
#import "MIHook.h"
#import <objc/runtime.h>
#import "MIProxy.h"
#import "MIApmHelper.h"
#import "MIWebModel.h"
#import "MIApmClient.h"

static NSString *reqDst;
static CFAbsoluteTime beginTim;
static NSInteger web_reqTim;

static void constructWebViewMonitorRestuls(MIWebViewStatus webViewStatus)
{
    CFAbsoluteTime endTim = (CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970)*1000;
    NSInteger totalTim = endTim - beginTim;
    MIWebModel *webMonitorRes = [MIWebModel instanceWithReqDst:reqDst
                                                                                        reqTim:web_reqTim
                                                                                      totalTim:totalTim
                                                                                 webViewStatus:webViewStatus];
    reqDst = nil;
    beginTim = 0;
    web_reqTim = 0;
    
    [[MIApmClient apmClient] miMonitorRes:webMonitorRes];
}

@implementation UIWebView (MI)

+ (void)hook
{
    // hook start load url method
    
    [MIHook hookInstance:@"UIWebView" sel:@"loadRequest:" withClass:@"UIWebView" sel:@"mi_loadRequest:"];
    [MIHook hookInstance:@"UIWebView" sel:@"loadHTMLString:baseURL:" withClass:@"UIWebView" sel:@"mi_loadHTMLString:baseURL:"];
    [MIHook hookInstance:@"UIWebView" sel:@"loadData:MIMEType:textEncodingName:baseURL:" withClass:@"UIWebView" sel:@"mi_loadData:MIMEType:textEncodingName:baseURL:"];
    
    [MIHook hookInstance:@"UIWebView" sel:@"reload" withClass:@"UIWebView" sel:@"mi_reload"];
    [MIHook hookInstance:@"UIWebView" sel:@"stopLoading" withClass:@"UIWebView" sel:@"mi_stopLoading"];
    [MIHook hookInstance:@"UIWebView" sel:@"goBack" withClass:@"UIWebView" sel:@"mi_goBack"];
    [MIHook hookInstance:@"UIWebView" sel:@"goForward" withClass:@"UIWebView" sel:@"mi_goForward"];
    
    
    [MIHook hookInstance:@"UIWebView" sel:@"setDelegate:" withClass:@"UIWebView" sel:@"mi_setDelegate:"];
}

#pragma mark -swizzed method

- (void)mi_loadRequest:(NSURLRequest *)request
{
    [self mi_loadRequest:request];
}

- (void)mi_loadHTMLString:(NSString *)string baseURL:(nullable NSURL *)baseURL
{
    [self mi_loadHTMLString:string baseURL:baseURL];
}

- (void)mi_loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL
{
    [self mi_loadData:data MIMEType:MIMEType textEncodingName:textEncodingName baseURL:baseURL];
}

- (void)mi_reload
{
    [self mi_reload];
}

- (void)mi_stopLoading
{
    [self mi_stopLoading];
    constructWebViewMonitorRestuls(MIWebViewStatus_STOP);
}

- (void)mi_goBack
{
    [self mi_goBack];
}

- (void)mi_goForward
{

    [self mi_goForward];
}


- (void)mi_setDelegate:(id<UIWebViewDelegate>)delegate
{
    
    // hook UIWebViewDelegate
    [self mi_setDelegate:delegate];
    [[self class] hookMethod:[delegate class]
                   originSel:@selector(webView:shouldStartLoadWithRequest:navigationType:)
               replacedClass:[self class]
                replacedSel:@selector(mi_webView:shouldStartLoadWithRequest:navigationType:)
                noneSel:@selector(none_webView:shouldStartLoadWithRequest:navigationType:)];
    
    [[self class] hookMethod:[delegate class]
                   originSel:@selector(webViewDidStartLoad:)
               replacedClass:[self class]
                 replacedSel:@selector(mi_webViewDidStartLoad:)
                     noneSel:@selector(none_webViewDidStartLoad:)];
    
    [[self class] hookMethod:[delegate class]
                   originSel:@selector(webViewDidFinishLoad:)
               replacedClass:[self class]
                 replacedSel:@selector(mi_webViewDidFinishLoad:)
                     noneSel:@selector(none_webViewDidFinishLoad:)];
    
    [[self class] hookMethod:[delegate class]
                   originSel:@selector(webView:didFailLoadWithError:)
               replacedClass:[self class]
                 replacedSel:@selector(mi_webView:didFailLoadWithError:)
                     noneSel:@selector(none_webView:didFailLoadWithError:)];
}

+ (void)hookMethod:(Class)originalClass
         originSel:(SEL)originSel
     replacedClass:(Class)replacedClass
       replacedSel:(SEL)replacedSel
           noneSel:(SEL)noneSel
{
    Method originalMethod = class_getInstanceMethod(originalClass, originSel);
    Method replacedMethod = class_getInstanceMethod(replacedClass, replacedSel);
    if (!originalMethod) {
        Method noneMethod = class_getInstanceMethod(replacedClass, noneSel);
        BOOL didAddNoneMethod = class_addMethod(originalClass, originSel, method_getImplementation(noneMethod), method_getTypeEncoding(noneMethod));
        if (didAddNoneMethod) {
            NSLog(@"app has not implement %@ method，manual add success",NSStringFromSelector(originSel));
        }
        return ;
    }
    
    BOOL didAddMethod = class_addMethod(originalClass, replacedSel, method_getImplementation(replacedMethod), method_getTypeEncoding(replacedMethod));
    if (didAddMethod) {
        Method newMethod = class_getInstanceMethod(originalClass, replacedSel);
        method_exchangeImplementations(originalMethod, newMethod);
    }
    
}

#pragma mark- UIWebViewDelegate
- (BOOL)mi_webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    reqDst = request.URL.absoluteString;
    NSLog(@"start url: %@",reqDst);
    web_reqTim = [MIApmHelper currentTimestamp];
    beginTim = (CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970)*1000;

    return [self mi_webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
}

- (void)none_webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{

}

- (void)mi_webViewDidStartLoad:(UIWebView *)webView
{

    [self mi_webViewDidStartLoad:webView];
}

- (void)none_webViewDidStartLoad:(UIWebView *)webView
{

}

- (void)mi_webViewDidFinishLoad:(UIWebView *)webView
{
    [self mi_webViewDidFinishLoad:webView];
    constructWebViewMonitorRestuls(MIWebViewStatus_NORMAL);
    
}

- (void)none_webViewDidFinishLoad:(UIWebView *)webView
{
    constructWebViewMonitorRestuls(MIWebViewStatus_NORMAL);
}


- (void)mi_webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self mi_webView:webView didFailLoadWithError:error];
    constructWebViewMonitorRestuls(MIWebViewStatus_FAILLOAD);
}

- (void)none_webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    constructWebViewMonitorRestuls(MIWebViewStatus_FAILLOAD);
}


@end
