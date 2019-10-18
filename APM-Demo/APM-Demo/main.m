//
//  main.m
//  APM-Demo
//
//  Created by mediaios on 2019/4/3.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <MIApm/MIApm.h>
#import <tingyunApp/NBSAppAgent.h>

int main(int argc, char * argv[]) {
    @autoreleasepool {
//        [NBSAppAgent startWithAppID:@"b6b772d29266484eb2415efc5bf8dca7"];
        [MIApmClient apmClient];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
