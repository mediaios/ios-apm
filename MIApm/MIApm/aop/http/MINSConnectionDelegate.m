//
//  MINSConnectionDelegate.m
//  MIApm
//
//  Created by mediaios on 2019/10/25.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import "MINSConnectionDelegate.h"
#import "MIApmHelper.h"
#import "MIHttpModel.h"
#import "MIApmClient.h"

@interface MINSConnectionDelegate()<NSURLConnectionDelegate>
@property (nonatomic,strong) NSMutableArray *selList;
@property (nonatomic,assign) NSUInteger reqDate;
@property (nonatomic,assign) CFAbsoluteTime beginTim;
@property (nonatomic,assign) CFAbsoluteTime endTim;
@property (nonatomic,strong) NSURLRequest *miRequest;
@property (nonatomic,strong) NSHTTPURLResponse *miResponse;
@property (nonatomic,strong) NSError *miError;
@property (nonatomic,assign) NSUInteger sendSize;
@property (nonatomic,assign) NSUInteger receiveSize;
@end

@implementation MINSConnectionDelegate
- (NSMutableArray *)selList
{
    if (!_selList) {
        _selList = [NSMutableArray arrayWithCapacity:0];
    }
    return _selList;
}

- (void)invoke:(NSInvocation *)invocation
{
    if ([self.selList containsObject:NSStringFromSelector(invocation.selector)]) {
        if ([self respondsToSelector:invocation.selector]) {
            invocation.target = self;
            [invocation invoke];
        }
    }
}

- (void)registerSel:(NSString *)sel
{
    if (![self.selList containsObject:sel]) {
        [self.selList addObject:sel];
    }
}

- (void)unregisterSel:(NSString *)sel
{
    if ([self.selList containsObject:sel]) {
        [self.selList removeObject:sel];
    }
}

- (void)resetPropertys
{
    _reqDate = 0;
    _beginTim = 0;
    _endTim = 0;
    _miRequest = nil;
    _miResponse = nil;
    _miError = nil;
    _sendSize = 0;
    _receiveSize = 0;
}

#pragma mark -NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    _endTim = (CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970)*1000;
    [MIApmHelper monitorConnectionHttpWithReuest:_miRequest
                                        response:_miResponse
                                           error:error
                                         reqTime:_reqDate
                                       beginTime:_beginTim
                                         endTime:_endTim];
    [self resetPropertys];
}

#pragma mark -NSURLConnectionDataDelegate
- (nullable NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(nullable NSURLResponse *)response
{
    _reqDate = [MIApmHelper currentTimestamp];
    _beginTim = (CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970)*1000;
    _miRequest = request;
    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _miResponse = (NSHTTPURLResponse *)response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    _receiveSize = data.length;
}

- (void)connection:(NSURLConnection *)connection   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    _sendSize = totalBytesWritten;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    _endTim = (CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970)*1000;
    [MIApmHelper monitorConnectionHttpWithReuest:_miRequest
                                        response:_miResponse
                                           error:_miError
                                         reqTime:_reqDate
                                       beginTime:_beginTim
                                         endTime:_endTim];
    [self resetPropertys];
}


#pragma mark -NSURLConnectionDownloadDelegate

- (void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes
{
//    NSLog(@"%s----",__func__);
}

- (void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes
{
//    NSLog(@"%s----",__func__);
}

- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *) destinationURL
{
//    NSLog(@"%s----",__func__);
}

@end
