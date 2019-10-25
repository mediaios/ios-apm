//
//  MIApmHelper.h
//  MIApm
//
//  Created by mediaios on 2019/4/10.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MIApmHelper : NSObject

+ (NSInteger)currentTimestamp;

+ (void)monitorConnectionHttpWithReuest:(NSURLRequest *)request
                     response:(NSHTTPURLResponse *)response
                        error:(NSError *)error
                      reqTime:(NSUInteger)reqTim
                    beginTime:(CFAbsoluteTime)beginTim
                      endTime:(CFAbsoluteTime)endTim;

+ (void)monitorHttpWithSessionTaskMetrics:(NSURLSessionTaskMetrics *)metrics
                                    error:(NSError *)error API_AVAILABLE(ios(10.0));
@end

NS_ASSUME_NONNULL_END
