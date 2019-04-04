//
//  main.m
//  APM-Demo
//
//  Created by ethan on 2019/4/3.
//  Copyright © 2019 ucloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "NSURLConnection+MI.h"
#import "NSURLSession+MI.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        
        [NSURLConnection hook];
        [NSURLSession hook];
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
