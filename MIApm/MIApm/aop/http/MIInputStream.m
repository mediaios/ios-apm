//
//  MIInputStream.m
//  MIApm
//
//  Created by mediaios on 2019/10/18.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import "MIInputStream.h"
#import "MINSStreamDelegate.h"

@interface MIInputStream()
{
    id _object;
    MINSStreamDelegate *_objDelegate;
    
}
@property (nonatomic,strong) NSInputStream *stream;
@end

@implementation MIInputStream

- (instancetype)initWithStream:(id)stream
{
    if (self = [super init]) {
        _stream = stream;
    }
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    return [_stream methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    [anInvocation invokeWithTarget:_stream];
}

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len
{
    NSInteger readSize = [_stream read:buffer maxLength:len];
    // 记录 readSize
    return readSize;
}


@end
