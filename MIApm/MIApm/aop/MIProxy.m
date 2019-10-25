//
//  MIProxy.m
//  MIApm
//
//  Created by mediaios on 2019/4/4.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import "MIProxy.h"
#import "MINSSessionDelegate.h"

@interface MIProxy()
{
    id _object;
    id _objDelegate;
}

@end


@implementation MIProxy

+ (id)proxyForObject:(id)obj delegate:(id)delgate
{
    MIProxy *instance  = [MIProxy alloc];
    instance->_object = obj;
    instance->_objDelegate = delgate;
    
    return instance;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    return [_object methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    if ([_object respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:_object];
        [_objDelegate invoke:invocation];
    }
}

@end
