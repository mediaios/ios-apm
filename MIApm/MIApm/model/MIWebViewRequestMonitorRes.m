//
//  MIWebViewRequestMonitorRes.m
//  MIApm
//
//  Created by mediaios on 2019/4/12.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import "MIWebViewRequestMonitorRes.h"

@implementation MIWebViewRequestMonitorRes

- (instancetype)initWithReqDst:(NSString *)reqDst
                        reqTim:(NSUInteger)reqTim
                      totalTim:(NSUInteger)totalTim
                 webViewStatus:(MIWebViewStatus)webViewStatus
{
    if (self = [super init]) {
        _reqDst = reqDst;
        _reqTim = reqTim;
        _totalTim = totalTim;
        _webViewStatus = webViewStatus;
    }
    return self;
}

+ (instancetype)instanceWithReqDst:(NSString *)reqDst
                            reqTim:(NSUInteger)reqTim
                          totalTim:(NSUInteger)totalTim
                     webViewStatus:(MIWebViewStatus)webViewStatus
{
    return [[self alloc] initWithReqDst:reqDst
                                 reqTim:reqTim
                               totalTim:totalTim
                          webViewStatus:webViewStatus];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"reqTim:%ld, webViewStatus:%lu reqDst:%@, totalTim:%ld",self.reqTim,(unsigned long)self.webViewStatus,self.reqDst,self.totalTim];
}
@end
