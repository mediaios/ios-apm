//
//  MIProxy.m
//  APM-Demo
//
//  Created by ethan on 2019/4/4.
//  Copyright © 2019 ucloud. All rights reserved.
//

#import "MIProxy.h"
#import "MIObjectDelegate.h"

@interface MIProxy()
{
    id _object;
    MIObjectDelegate *_objDelegate;
}

@end


@implementation MIProxy

+ (id)proxyForObject:(id)obj delegate:(MIObjectDelegate *)delgate
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
