//
//  ViewController.m
//  APM-Demo
//
//  Created by ethan on 2019/4/3.
//  Copyright © 2019 ucloud. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self session_async];
}

/********* NSURLConnection请求 **********/
- (void)connection
{
        NSURL * url = [NSURL URLWithString:@"http://www.baidu.com"];
        //1.创建请求对象
        NSURLRequest * request = [NSURLRequest requestWithURL:url];
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
    
    
//        NSURLResponse *response = nil;
//        NSError *error = nil;
//        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
}

/********* NSURLSession请求 **********/
- (void)session_async
{
    NSMutableURLRequest *req  = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]];
    [req setHTTPMethod:@"GET"];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 10;
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:req  completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"出错了");
            return;
        }
        NSString * string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }];
    
    [task resume];
    
}


@end
