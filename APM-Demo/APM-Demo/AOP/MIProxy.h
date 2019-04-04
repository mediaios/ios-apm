//
//  MIProxy.h
//  APM-Demo
//
//  Created by ethan on 2019/4/4.
//  Copyright © 2019 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MIObjectDelegate;

@interface MIProxy : NSProxy

+ (id)proxyForObject:(id)obj delegate:(MIObjectDelegate *)delgate;

@end

NS_ASSUME_NONNULL_END
