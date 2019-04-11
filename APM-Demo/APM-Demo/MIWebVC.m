//
//  MIWebVC.m
//  UNetAnalysisDemo_01
//
//  Created by ethan on 2019/4/10.
//  Copyright © 2019 ucloud. All rights reserved.
//

#import "MIWebVC.h"

@interface MIWebVC ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation MIWebVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self startLoad];
}


- (void)startLoad
{
    NSURL *url = [NSURL URLWithString:@"http://www.baidu.com"];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [self.webView loadRequest:req];
}



- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"%s",__func__);
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"%s",__func__);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"%s",__func__);
}

@end
