//
//  ViewController.m
//  APM-Demo
//
//  Created by mediaios on 2019/4/3.
//  Copyright © 2019 mediaios. All rights reserved.
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

- (void)apm:(MIApmClient *)apm monitorNetworkRequest:(MIHttpModel *)netModel
{
    NSLog(@"%@",netModel);
}

- (void)apm:(MIApmClient *)apm monitorUIWebView:(MIWebModel *)webViewMonitorRes
{
    NSLog(@"%@",webViewMonitorRes);
}




@end
