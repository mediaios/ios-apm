//
//  MIHook.m
//  APM-Demo
//
//  Created by ethan on 2019/4/3.
//  Copyright © 2019 ucloud. All rights reserved.
//

#import "MIHook.h"
#import <objc/runtime.h>

@implementation MIHook
+ (void)hookInstance:(NSString *)oriClass
                 sel:(NSString *)oriSel
           withClass:(NSString *)newClass
                 sel:(NSString *)newSel
{
    Class oldClass = objc_getClass([oriClass UTF8String]);
    Class swizzClass = objc_getClass([newClass UTF8String]);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    SEL oldSel = NSSelectorFromString(oriSel);
    SEL swizzSel = NSSelectorFromString(newSel);
#pragma clang diagnostic pop
    Method oldMethod = class_getInstanceMethod(oldClass, oldSel);
    Method swizzMethod = class_getInstanceMethod(swizzClass, swizzSel);
    method_exchangeImplementations(oldMethod, swizzMethod);
}

+ (void)hookClass:(NSString *)oriClass
              sel:(NSString *)oriSel
        withClass:(NSString *)newClass
              sel:(NSString *)newSel
{
    Class oldClass = objc_getClass([oriClass UTF8String]);
    Class swizzClass = objc_getClass([newClass UTF8String]);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    SEL oldSel = NSSelectorFromString(oriSel);
    SEL swizzSel = NSSelectorFromString(newSel);
    Method oldMethod = class_getClassMethod(oldClass, oldSel);
    Method swizzMethod = class_getClassMethod(swizzClass, swizzSel);
    method_exchangeImplementations(oldMethod, swizzMethod);
}
@end
