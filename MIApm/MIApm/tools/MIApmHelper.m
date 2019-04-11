//
//  MIApmHelper.m
//  MIApm
//
//  Created by mediaios on 2019/4/10.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import "MIApmHelper.h"

@implementation MIApmHelper

+ (NSInteger)currentTimestamp
{
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    return (NSInteger)currentTime;
}

@end
