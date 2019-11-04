//
//  MIHook.m
//  MIApm
//
//  Created by mediaios on 2019/4/3.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import "MIHook.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

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

+ (void)hookInstanceToOtherClass:(NSString *)oriClass
                             sel:(NSString *)oriSel
                       withClass:(NSString *)newClass
                             sel:(NSString *)newSel
{
    Class origin_class = objc_getClass([oriClass UTF8String]);
    Class swizzed_class = objc_getClass([newClass UTF8String]);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    SEL oldSel = NSSelectorFromString(oriSel);
    SEL swizzSel = NSSelectorFromString(newSel);
#pragma clang diagnostic pop
    Method oldMethod = class_getInstanceMethod(origin_class, oldSel);
    Method swizzMethod = class_getInstanceMethod(swizzed_class, swizzSel);
    BOOL add_method = class_addMethod(origin_class,
                                      swizzSel,
                                      method_getImplementation(swizzMethod),
                                      method_getTypeEncoding(swizzMethod));
    if (!add_method) {
        NSLog(@"hook failed,%s,%d",__func__,__LINE__);
        return;
    }
    swizzMethod = class_getInstanceMethod(origin_class, swizzSel);
    if (!swizzMethod) {
        NSLog(@"hook failed,%s,%d",__func__,__LINE__);
        return;
    }
    BOOL did_add_method = class_addMethod(origin_class,
                                          oldSel,
                                          method_getImplementation(swizzMethod),
                                          method_getTypeEncoding(swizzMethod));
    if (did_add_method) {
        class_replaceMethod(origin_class,
                            swizzSel,
                            method_getImplementation(oldMethod),
                            method_getTypeEncoding(oldMethod));
    }else{
        method_exchangeImplementations(oldMethod, swizzMethod);
    }
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
