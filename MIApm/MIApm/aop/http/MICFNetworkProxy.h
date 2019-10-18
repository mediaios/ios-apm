//
//  MICFNetworkProxy.h
//  MIApm
//
//  Created by mediaios on 2019/10/18.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MINSStreamDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface MICFNetworkProxy : NSProxy

+ (id)proxyForObject:(id)obj delegate:(MINSStreamDelegate *)delgate;

@end

NS_ASSUME_NONNULL_END
