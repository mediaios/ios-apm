//
//  main.m
//  APM-Demo
//
//  Created by ethan on 2019/4/3.
//  Copyright © 2019 ucloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <MIApm/MIApm.h>

int main(int argc, char * argv[]) {
    @autoreleasepool {
        
        [MIApmClient apmClient];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
