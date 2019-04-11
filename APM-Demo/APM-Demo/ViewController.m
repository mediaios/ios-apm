//
//  ViewController.m
//  APM-Demo
//
//  Created by ethan on 2019/4/3.
//  Copyright © 2019 ucloud. All rights reserved.
//

#import "ViewController.h"
#import <MIApm/MIApm.h>


@interface ViewController ()<MIApmClientDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [MIApmClient apmClient].delegate = self;
}

- (void)apm:(MIApmClient *)apm monitorNetworkRequest:(MIRequestMonitorRes *)netModel
{
    NSLog(@"%@",netModel);
}


@end
