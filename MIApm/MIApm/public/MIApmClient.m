//
//  MIApmClient.m
//  MIApm
//
//  Created by mediaios on 2019/4/11.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import "MIApmClient.h"
#import "NSURLConnection+MI.h"
#import "NSURLSession+MI.h"

@implementation MIApmClient

- (instancetype)init
{
    if (self = [super init]) {
        [NSURLConnection hook];
        [NSURLSession hook];
    }
    return self;
}

static MIApmClient *apm_instance = nil;
+ (instancetype)apmClient
{
    static dispatch_once_t apm_init_onceToken;
    dispatch_once(&apm_init_onceToken, ^{
        apm_instance = [[MIApmClient alloc] init];
    });
    return apm_instance;
}

- (void)netRequestMonitor:(MIRequestMonitorRes *)netModel
{
    [self.delegate apm:self monitorNetworkRequest:netModel];
}

@end
