# ios-apm

## 介绍 

### 背景

此前曾关注过一些`apm(应用性能管理平台)系统`，对其实现很是好奇。此SDK是对`apm系统`中ios平台信息采集的一个技术预研。我觉得在整个`apm系统`中,对网络的监控是最复杂的，所以我们先从网络监控入手循序渐进的理解整个系统。

整个技术预研的过程是通过一个SDK的形式展现的，该SDK只做信息采集和回显。


### 灵感 

由于市场上很多的`apm系统`都是收费的(不收费的有数量和查询功能的限制)，所以我觉得我们可以在我们自己的应用中做一个隐藏开关来控制debug信息的显示，这些debug信息就是我们应用中很多关键性能的信息，比如：http请求情况、当前应用的帧率、cpu利用率等信息。当用户反馈哪个功能有问题时，可以通过打开隐藏开关来显示debug信息的方式进行黑盒测试，进而更直观的定位到引起bug的原因。 

所以，你可以使用该SDK查看应用中这些关键的信息。


## 环境要求

* iOS >= 10.0 
* XCode >= 8.0
* 设置`Enable Bitcode`为`NO`

## 安装使用 

### 通过pod方式 

在你工程的`Podfile`中添加以下依赖： 

```
pod 'MIApm'
```

### 快速开始 

首先是引入SDK，在你的项目中最开始的地方(我们推荐是`main.m`中)导入`SDK`头文件：

```
#import <MIApm/MIApm.h>
```

然后再main方法中调用`MIApmClient`中的`apmClient`方法： 

```
 int main(int argc, char * argv[]) {
    @autoreleasepool {
        [MIApmClient apmClient];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
```

另外，你需要将 -ObjC 添加到项目的Build Setting->other links flags中。 如下所示：

![](https://ws2.sinaimg.cn/large/006tNc79gy1g24lgmsy9oj30n406zmxx.jpg)


### 回显监控的数据 

当前版本支持持网络请求监控和对`UIWebView`的监控。

#### 监控网路请求

支持的网络请求有：
 
 * NSURLConnection
 * NSURLSession
 * AFNetWorking 
 * 其它使用`NSURLConnection`，`NSURLSession`请求的网络请求框架

首先在你想要回显的类里面引入头文件，利用SDK中的代理回显相关信息。 

```
// 设置代理  
[MIApmClient apmClient].delegate = self;

// 回显数据 
- (void)apm:(MIApmClient *)apm monitorNetworkRequest:(MIRequestMonitorRes *)netModel
{
	// 你的处理逻辑 
    NSLog(@"%@",netModel);
}


```

#### 监控UIWebView

同样通过实现代理的方式回显相关信息：

```
- (void)apm:(MIApmClient *)apm monitorUIWebView:(MIWebViewRequestMonitorRes *)webViewMonitorRes{
	// 你的处理逻辑
	NSLog(@"%@", webViewMonitorRes);
}
```

#### 其它功能

* 待完善中。。。

## 联系我们

* 如果你有任何问题或需求，请提交[issue](https://github.com/mediaios/ios-apm/issues) 
* 如果你要提交代码，欢迎提交 pull request
* 欢迎点星

