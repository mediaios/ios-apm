//
//  MIHookCFNetwork.h
//  MIApm
//
//  Created by mediaios on 2019/10/18.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MINSStreamDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface MIHookCFNetwork : NSObject

+ (void)hook;

+ (void)registerDelegateMethod:(NSString *)method oriDelegate:(id<NSStreamDelegate>)oriDel assistDelegate:(MINSStreamDelegate *)assiDel flag:(const char *)flag;

@end

NS_ASSUME_NONNULL_END
