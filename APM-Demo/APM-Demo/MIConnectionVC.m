//
//  MIConnectionVC.m
//  APM-Demo
//
//  Created by mediaios on 2019/4/9.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import "MIConnectionVC.h"
#import <MIApm/MIApm.h>
@interface MIConnectionVC ()<NSURLConnectionDelegate,MIApmClientDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *debugView;

@end

@implementation MIConnectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [MIApmClient apmClient].delegate = self;
}

- (IBAction)btnClickSendSync:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择网络请求方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"GET" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self sendSynch_get];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"POST" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self sendSynch_post];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (IBAction)btnClickSendAsync:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择网络请求方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"GET" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self sendAsync_get];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"POST" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self sendAsynch_post];
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
    [urlRequest setHTTPBody:[self getBodydataWithImage:img]];
    
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        
    }];
}


- (IBAction)btnClickDownload:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://raw.githubusercontent.com/mediaios/OpenGL-iOS/master/images/20190916_opengl_10.png"];
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        self.imageView.image = [UIImage imageWithData:data];
    }];
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

- (NSData *)setHttpBody
{
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString* strPath = [bundle pathForResource:@"test" ofType:@"png"];
    NSData *fileData = [NSData dataWithContentsOfFile:strPath];
    return fileData;
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


- (void)sendSynch_get
{
    NSURL *url = [NSURL URLWithString:@"http://apis.juhe.cn/simpleWeather/query?city=%E4%B8%8A%E6%B5%B7&key=5be112d55b4fe1fc620b4a662904b4d8"];
    //1.创建请求对象
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        NSLog(@"error,error info:%@",error.description);
        NSString *errorInfo = [NSString stringWithFormat:@"网络请求出错,error info:%@",error.description];
        [self showDebugInfo:errorInfo];
    }else{
        NSString *resStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"res: %@\n,数据大小是：%lu",resStr,data.length);
        [self showDebugInfo:resStr];
    }
}

- (void)sendSynch_post
{
    NSURL *url = [NSURL URLWithString:@"http://apis.juhe.cn/simpleWeather/query"];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    NSString  *params = @"city=上海&key=5be112d55b4fe1fc620b4a662904b4d8";
    NSData *dataParam = [params dataUsingEncoding:NSUTF8StringEncoding];
    [req setHTTPBody:dataParam];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    if (error) {
        NSString *errorInfo = [NSString stringWithFormat:@"网络请求出错,error info:%@",error.description];
        [self showDebugInfo:errorInfo];
    }else{
        NSString *resStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"res: %@",resStr);
        [self showDebugInfo:resStr];
    }
   
    

    
}

- (void)sendAsync_get
{
    NSURL *url = [NSURL URLWithString:@"http://apis.juhe.cn/simpleWeather/query?city=%E4%B8%8A%E6%B5%B7&key=5be112d55b4fe1fc620b4a662904b4d8"];
    //1.创建请求对象
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (connectionError) {
            NSLog(@"网络请求出错,error info: %@",connectionError.description);
            NSString *errorInfo = [NSString stringWithFormat:@"网络请求出错,error info:%@",connectionError.description];
            [self showDebugInfo:errorInfo];
        }else{
            NSString *resStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"res: %@\n,数据大小是：%lu",resStr,data.length);
            [self showDebugInfo:resStr];
        }
    }];
}

- (void)sendAsynch_post
{
    NSURL *url = [NSURL URLWithString:@"http://apis.juhe.cn/simpleWeather/query"];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    NSString  *params = @"city=上海&key=5be112d55b4fe1fc620b4a662904b4d8";
    NSData *dataParam = [params dataUsingEncoding:NSUTF8StringEncoding];
    [req setHTTPBody:dataParam];
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (connectionError) {
            NSLog(@"网络请求出错,error info: %@",connectionError.description);
            NSString *errorInfo = [NSString stringWithFormat:@"网络请求出错,error info:%@",connectionError.description];
            [self showDebugInfo:errorInfo];
            
        }else{
            NSString *resStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"res: %@\n,数据大小是：%lu",resStr,data.length);
            [self showDebugInfo:resStr];
        }
    }];
}

- (void)delegate_get
{
    NSURL * url = [NSURL URLWithString:@"http://apis.juhe.cn/simpleWeather/query?city=%E4%B8%8A%E6%B5%B7&key=5be112d55b4fe1fc620b4a662904b4d8"];
    //1.创建请求对象
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    if (!conn) {
        NSLog(@"连接没有创建成功");
    }
}

- (void)delegate_post
{
    NSURL *url = [NSURL URLWithString:@"http://apis.juhe.cn/simpleWeather/query"];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    NSString  *params = @"city=上海&key=5be112d55b4fe1fc620b4a662904b4d8";
    NSData *dataParam = [params dataUsingEncoding:NSUTF8StringEncoding];
    [req setHTTPBody:dataParam];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
    if (!conn) {
        NSLog(@"连接没有创建成功");
    }
    
//    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
//        if (connectionError) {
//            NSLog(@"请求出错了...");
//        }else{
//            NSString *resStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//            NSLog(@"res: %@",resStr);
//        }
//    }];
}



#pragma mark -NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge API_DEPRECATED("Use -connection:willSendRequestForAuthenticationChallenge: instead.", macos(10.2,10.10), ios(2.0,8.0), watchos(2.0,2.0), tvos(9.0,9.0))
{
    
}
- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge API_DEPRECATED("Use -connection:willSendRequestForAuthenticationChallenge: instead.", macos(10.2,10.10), ios(2.0,8.0), watchos(2.0,2.0), tvos(9.0,9.0))
{
    
}


#pragma mark - NSURLConnectionDataDelegate
- (nullable NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(nullable NSURLResponse *)response
{
    return request;
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
    
    NSString *resStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self showDebugInfo:resStr];
}

- (void)connection:(NSURLConnection *)connection   didSendBodyData:(NSInteger)bytesWritten
                                                 totalBytesWritten:(NSInteger)totalBytesWritten
                                         totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
}

#pragma mark - MIApmClientDelegate
- (void)apm:(MIApmClient *)apm monitorNetworkRequest:(MIHttpModel *)netModel
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
