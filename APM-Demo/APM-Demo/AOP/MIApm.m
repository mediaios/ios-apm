//
//  MIApm.m
//  APM-Demo
//
//  Created by ethan on 2019/4/10.
//  Copyright © 2019 ucloud. All rights reserved.
//

#import "MIApm.h"
#import "NSURLConnection+MI.h"
#import "NSURLSession+MI.h"

@implementation MIApm
+ (void)startMonitor
{
    [NSURLConnection hook];
    [NSURLSession hook];
}
@end
