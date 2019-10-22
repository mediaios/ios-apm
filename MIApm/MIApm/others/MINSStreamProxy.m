//
//  MIOriginalStream.m
//  MIApm
//
//  Created by mediaios on 2019/10/18.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import "MINSStreamProxy.h"
#import "MIInputStream.h"

@interface MINSStreamProxy()
{
    MIInputStream *_stream;
}

@end

@implementation MINSStreamProxy

- (instancetype)initWithStream:(id)stream
{
    if (self = [super init]) {
        NSLog(@"%s",__func__);
        _stream = stream;
    }
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSLog(@"%s",__func__);
    return [_stream methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSLog(@"%s",__func__);
    [anInvocation invokeWithTarget:_stream];
}


@end
