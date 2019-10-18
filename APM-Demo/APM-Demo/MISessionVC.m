//
//  MISessionVC.m
//  APM-Demo
//
//  Created by mediaios on 2019/4/9.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import "MISessionVC.h"
#import <MIApm/MIApm.h>
@interface MISessionVC ()<NSURLSessionDelegate,MIApmClientDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *debugView;

@end

@implementation MISessionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [MIApmClient apmClient].delegate = self;
}

- (IBAction)btnClickDataTask:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择网络请求方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"GET" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dataTask_get];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"POST" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dataTask_post];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)btnClickDelegate:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择网络请求方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"GET" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self delegate_get];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"POST" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self delegate_post];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)btnClickUpload:(id)sender {
    UIImage *img = [UIImage imageNamed:@"test.jpg"];
    NSURL *url = [NSURL URLWithString:@"http://192.168.187.74/~ethan/file_operate/upload.php"];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    //设置Method
    urlRequest.HTTPMethod = @"POST";
    
    //4.设置请求头
    //在请求头中添加content-type字段
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; charset=utf-8;boundary=%@",boundry];
    [urlRequest setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    //NSURLSession
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[[NSOperationQueue alloc]init]];
    
    //定义上传操作
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:urlRequest fromData:[self getBodydataWithImage:img] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"响应结果:%@", response);
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"返回数据:\n%@",str);
    }];
    
    [uploadTask resume];
}

- (IBAction)btnClickDownload:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://raw.githubusercontent.com/mediaios/OpenGL-iOS/master/images/20190916_opengl_10.png"];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"GET"];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 10;
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:req  completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"出错了");
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = [UIImage imageWithData:data];
        });
        
    }];
    
    [task resume];
}


static NSString *boundry = @"----------V2ymHFg03ehbqgZCaKO6jy";//设置边界
- (NSData *)getBodydataWithImage:(UIImage *)image
{
    //把文件转换为NSData
    NSData *fileData = UIImageJPEGRepresentation(image, 0.8);
    
    //文件名
    NSString *fileName=@"test";
    
    //1.构造body string
    NSMutableString *bodyString = [[NSMutableString alloc] init];
    
    //2.拼接body string
    //(1)file_name
    [bodyString appendFormat:@"--%@\r\n",boundry];
    [bodyString appendFormat:@"Content-Disposition: form-data; name=\"FileName\"\r\n"];
    [bodyString appendFormat:@"Content-Type: text/plain; charset=\"utf-8\"\r\n\r\n"];
    [bodyString appendFormat:@"aaa%@.jpg\r\n",fileName];
    
    //(2)PostID
    //    [bodyString appendFormat:@"--%@\r\n",boundry];
    //    [bodyString appendFormat:@"Content-Disposition: form-data; name=\"PostID\"\r\n"];
    //    [bodyString appendFormat:@"Content-Type: text/plain; charset=\"utf-8\"\r\n\r\n"];
    //    [bodyString appendFormat:@"%@\r\n",self.uuID];
    
    //(3)pic
    [bodyString appendFormat:@"--%@\r\n",boundry];
    [bodyString appendFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@.jpg\"\r\n",fileName];
    [bodyString appendFormat:@"Content-Type: image/jpeg\r\n\r\n"];
    //[bodyString appendFormat:@"Content-Type: application/octet-stream\r\n\r\n"];
    
    //3.string --> data
    NSMutableData *bodyData = [NSMutableData data];
    //拼接的过程
    //前面的bodyString, 其他参数
    [bodyData appendData:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    //图片数据
    [bodyData appendData:fileData];
    
    //4.结束的分隔线
    NSString *endStr = [NSString stringWithFormat:@"\r\n--%@--\r\n",boundry];
    //拼接到bodyData最后面
    [bodyData appendData:[endStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    return bodyData;
}

- (void)dataTask_post
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:@"http://apis.juhe.cn/simpleWeather/query"];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    NSString  *params = @"city=上海&key=5be112d55b4fe1fc620b4a662904b4d8";
    NSData *dataParam = [params dataUsingEncoding:NSUTF8StringEncoding];
    [req setHTTPBody:dataParam];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSString *errorInfo = [NSString stringWithFormat:@"网络请求出错,error info:%@",error.description];
            [self showDebugInfo:errorInfo];
            return;
        }
        //8.解析数据
        NSString *resStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"res: %@",resStr);
        [self showDebugInfo:resStr];
    }];
    [dataTask resume];
}

- (void)dataTask_get
{
    NSMutableURLRequest *req  = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://apis.juhe.cn/simpleWeather/query?city=%E4%B8%8A%E6%B5%B7&key=5be112d55b4fe1fc620b4a662904b4d8"]];
    [req setHTTPMethod:@"GET"];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 10;
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:req  completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"出错了,error info: %@",error.description);
            NSString *errorInfo = [NSString stringWithFormat:@"网络请求出错,error info:%@",error.description];
            [self showDebugInfo:errorInfo];
            return;
        }
        NSString *resStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
               NSLog(@"res: %@\n,数据大小是：%lu",resStr,data.length);
        [self showDebugInfo:resStr];
    }];
    
    [task resume];
}

- (void)delegate_get
{
    NSURL *url = [NSURL URLWithString:@"http://apis.juhe.cn/simpleWeather/query?city=%E4%B8%8A%E6%B5%B7&key=5be112d55b4fe1fc620b4a662904b4d8"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    //4.根据会话对象创建一个Task(发送请求）
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request];
    
    //5.执行任务
    [dataTask resume];
}

- (void)delegate_post
{
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURL *url = [NSURL URLWithString:@"http://apis.juhe.cn/simpleWeather/query"];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    NSString  *params = @"city=上海&key=5be112d55b4fe1fc620b4a662904b4d8";
    NSData *dataParam = [params dataUsingEncoding:NSUTF8StringEncoding];
    [req setHTTPBody:dataParam];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:req];
    
//    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        //8.解析数据
//        NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
//    }];
    [dataTask resume];
}


#pragma mark -NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveData:(NSData *)data
{
    NSString *resStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self showDebugInfo:resStr];
    NSLog(@"res: %@\n,数据大小是：%lu",resStr,data.length);
}


#pragma mark - MIApmClientDelegate
- (void)apm:(MIApmClient *)apm monitorNetworkRequest:(MIRequestMonitorRes *)netModel
{
    [self showDebugInfo:netModel.description];
}


- (void)showDebugInfo:(NSString *)debugInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
         NSMutableString *debug_str = [NSMutableString stringWithString:self.debugView.text];
         [debug_str appendString:[NSString stringWithFormat:@"\n\n%@",debugInfo]];
         self.debugView.text = debug_str;
        
        [self.debugView scrollRangeToVisible:NSMakeRange(self.debugView.text.length, 1)];
        self.debugView.layoutManager.allowsNonContiguousLayout = NO;
    });
}

@end
