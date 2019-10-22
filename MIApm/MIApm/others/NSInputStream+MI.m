//
//  NSInputStream+MI.m
//  MIApm
//
//  Created by ethan on 2019/10/21.
//  Copyright © 2019 ucloud. All rights reserved.
//

#import "NSInputStream+MI.h"

#import <objc/runtime.h>
#import "MIHook.h"
#import "MIProxy.h"
#import "MIHttpDelegate.h"


@implementation NSInputStream (MI)

+ (void)hook
{
    [MIHook hookInstance:@"NSInputStream" sel:@"setDelegate:" withClass:@"NSInputStream" sel:@"mi_setDelegate:"];
    [MIHook hookInstance:@"NSInputStream" sel:@"delegate" withClass:@"NSInputStream" sel:@"mi_delegate:"];
    [MIHook hookInstance:@"NSInputStream" sel:@"open" withClass:@"NSInputStream" sel:@"mi_open:"];
    [MIHook hookInstance:@"NSInputStream" sel:@"read:maxLength:" withClass:@"NSInputStream" sel:@"mi_read:maxLength:"];
}

- (void)mi_setDelegate:(id<NSStreamDelegate>)delegate
{
    MIHttpDelegate *objDelegate = [[MIHttpDelegate alloc] init];
    if (delegate) {
        [[self class] registerDelegateMethod:@"stream:handleEvent:" oriDelegate:delegate assistDelegate:objDelegate flag:"v@:@"];
        delegate = [MIProxy proxyForObject:delegate delegate:objDelegate];
    }else{
        delegate = objDelegate;
    }
    return [self mi_setDelegate:delegate];
}

- (id<NSStreamDelegate>)mi_delegate
{
    return [self mi_delegate];
}

- (void)mi_open
{
    [self mi_open];
}

- (NSInteger)mi_read:(uint8_t *)buffer maxLength:(NSUInteger)len
{
    return [self mi_read:buffer maxLength:len];
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
