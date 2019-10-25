//
//  MIHttpDelegate.h
//  MIApm
//
//  Created by mediaios on 2019/4/4.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MINSSessionDelegate : NSObject<NSURLSessionDelegate>


- (void)invoke:(NSInvocation *)invocation;
- (void)registerSel:(NSString *)sel;
- (void)unregisterSel:(NSString *)sel;
@end

NS_ASSUME_NONNULL_END
