//
//  MIInputStream.m
//  MIApm
//
//  Created by mediaios on 2019/10/21.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import "MIInputStream.h"

@implementation MIInputStream


- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len
{
    NSInteger readSize = [self read:buffer maxLength:len];
    // 记录 readSize
    NSLog(@"read Size: %lu",readSize);
    return readSize;
}

@end
