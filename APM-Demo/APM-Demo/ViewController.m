//
//  ViewController.m
//  APM-Demo
//
//  Created by ethan on 2019/4/3.
//  Copyright © 2019 ucloud. All rights reserved.
//

#import "ViewController.h"
#import "NSURLConnection+MI.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [NSURLConnection hook];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSURL * url = [NSURL URLWithString:@"http://www.baidu.com"];
    //1.创建请求对象
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    //2.发送请求
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (connectionError) {
            NSLog(@"网络请求出错..");
        }else{
            NSLog(@"成功请求，数据大小是： %ld",data.length);
        }
        //3.解析服务器返回的数据（解析成字符串）
//        NSString * string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"%@",string);
    }];
    
    
//    NSURLResponse *response = nil;
//    NSError *error = nil;
//    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
}


@end
