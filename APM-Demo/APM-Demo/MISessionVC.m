//
//  MISessionVC.m
//  APM-Demo
//
//  Created by ethan on 2019/4/9.
//  Copyright © 2019 ucloud. All rights reserved.
//

#import "MISessionVC.h"

@interface MISessionVC ()<NSURLSessionDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation MISessionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    NSURL *url = [NSURL URLWithString:@"http://localhost/~ethan/file_operate/uploads/test.jpg"];
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
    NSURL *url = [NSURL URLWithString:@"http://192.168.187.74:8000/usrLossDistribution"];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    NSString *params = @{@"dst_ip":@"23.236.126.69",
                         @"ucloud_top":@"5",
                         @"usr_country":@"巴西",
                         @"time_period":@"timestamp_period_1553616000~1553702399",
                         @"app_id":@"com.minitech.miniworld,com.playmini.miniworld"
                         };
    NSString *dataJson = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:params options:0 error:nil] encoding:NSUTF8StringEncoding];
    NSData *dataParam = [dataJson dataUsingEncoding:NSUTF8StringEncoding];
    [req setHTTPBody:dataParam];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //8.解析数据
        NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    }];
    [dataTask resume];
}

- (void)dataTask_get
{
    NSMutableURLRequest *req  = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://net-trace.ucloud.cn:8098/v1/ipip"]];
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

- (void)delegate_get
{
    NSURL *url = [NSURL URLWithString:@"https://net-trace.ucloud.cn:8098/v1/ipip"];
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
    NSURL *url = [NSURL URLWithString:@"http://192.168.187.74:8000/usrLossDistribution"];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    NSString *params = @{@"dst_ip":@"23.236.126.69",
                         @"ucloud_top":@"5",
                         @"usr_country":@"巴西",
                         @"time_period":@"timestamp_period_1553616000~1553702399",
                         @"app_id":@"com.minitech.miniworld,com.playmini.miniworld"
                         };
    NSString *dataJson = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:params options:0 error:nil] encoding:NSUTF8StringEncoding];
    NSData *dataParam = [dataJson dataUsingEncoding:NSUTF8StringEncoding];
    [req setHTTPBody:dataParam];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //8.解析数据
        NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    }];
    [dataTask resume];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
