//
//  MICFNetworkProxy.m
//  MIApm
//
//  Created by mediaios on 2019/10/18.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import "MICFNetworkProxy.h"


@interface MICFNetworkProxy()
{
    id _object;
    MINSStreamDelegate *_objDelegate;
}

@end

@implementation MICFNetworkProxy

+ (id)proxyForObject:(id)obj delegate:(MINSStreamDelegate *)delgate
{
    MICFNetworkProxy *instance  = [MICFNetworkProxy alloc];
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
