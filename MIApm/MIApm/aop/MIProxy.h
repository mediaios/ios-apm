//
//  MIProxy.h
//  MIApm
//
//  Created by mediaios on 2019/4/4.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MIHttpDelegate;

@interface MIProxy : NSProxy

+ (id)proxyForObject:(id)obj delegate:(id)delgate;

@end

NS_ASSUME_NONNULL_END
