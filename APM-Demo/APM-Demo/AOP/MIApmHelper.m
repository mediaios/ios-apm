//
//  MIApmHelper.m
//  APM-Demo
//
//  Created by ethan on 2019/4/10.
//  Copyright © 2019 ucloud. All rights reserved.
//

#import "MIApmHelper.h"

@implementation MIApmHelper

+ (NSInteger)currentTimestamp
{
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    return (NSInteger)currentTime;
}

@end
