//
//  MIHook.h
//  APM-Demo
//
//  Created by ethan on 2019/4/3.
//  Copyright © 2019 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MIHook : NSObject

+ (void)hookInstance:(NSString *)oriClass
                 sel:(NSString *)oriSel
           withClass:(NSString *)newClass
                 sel:(NSString *)newSel;

+ (void)hookClass:(NSString *)oriClass
              sel:(NSString *)oriSel
        withClass:(NSString *)newClass
              sel:(NSString *)newSel;

@end

NS_ASSUME_NONNULL_END
