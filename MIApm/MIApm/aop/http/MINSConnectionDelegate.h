//
//  MINSConnectionDelegate.h
//  MIApm
//
//  Created by mediaios on 2019/10/25.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MINSConnectionDelegate : NSObject
- (void)invoke:(NSInvocation *)invocation;
- (void)registerSel:(NSString *)sel;
- (void)unregisterSel:(NSString *)sel;
@end

NS_ASSUME_NONNULL_END
