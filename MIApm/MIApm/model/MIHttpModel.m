//
//  MIHttpModel.m
//  MIApm
//
//  Created by mediaios on 2019/4/10.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import "MIHttpModel.h"

@implementation MIHttpModel

- (instancetype)initWith:(NSString *)reqDst
               reqMethod:(NSString *)reqMethod
                  reqTim:(NSUInteger)reqTim
                totalTim:(NSUInteger)totalTim
              statusCode:(NSInteger)statusCode
{
    if (self = [super init]) {
        _reqDst = reqDst;
        _reqMethod = reqMethod;
        _reqTim = reqTim;
        _totalTim = totalTim;
        _statusCode = statusCode;
    }
    return self;
}

- (instancetype)initWith:(NSString *)reqDst
               reqMethod:(NSString *)reqMethod
                  reqTim:(NSUInteger)reqTim
           clientWastTim:(NSUInteger)clientWastTim
                totalTim:(NSUInteger)totalTim
                  dnsTim:(NSUInteger)dnsTim
                  sslTim:(NSUInteger)sslTim
                  tcpTim:(NSUInteger)tcpTim
          firstPacketTim:(NSUInteger)firstPacketTim
              statusCode:(NSInteger)statusCode;
{
    if (self = [self initWith:reqDst
                    reqMethod:reqMethod
                       reqTim:reqTim
                     totalTim:totalTim
                   statusCode:statusCode]) {
        _clientWastTim = clientWastTim;
        _dnsTim = dnsTim;
        _sslTim = sslTim;
        _tcpTim = tcpTim;
        _firstPacketTim = firstPacketTim;
        _statusCode =  statusCode;
    }
    return self;
}

+ (instancetype)instanceWith:(NSString *)reqDst
                   reqMethod:(NSString *)reqMethod
                      reqTim:(NSUInteger)reqTim
                    totalTim:(NSUInteger)totalTim
                  statusCode:(NSInteger)statusCode
{
    return [[self alloc] initWith:reqDst
                        reqMethod:reqMethod
                           reqTim:reqTim
                         totalTim:totalTim
                       statusCode:statusCode];
}

+ (instancetype)instanceWith:(NSString *)reqDst
                   reqMethod:(NSString *)reqMethod
                      reqTim:(NSUInteger)reqTim
               clientWastTim:(NSUInteger)clientWastTim
                    totalTim:(NSUInteger)totalTim
                      dnsTim:(NSUInteger)dnsTim
                      sslTim:(NSUInteger)sslTim
                      tcpTim:(NSUInteger)tcpTim
              firstPacketTim:(NSUInteger)firstPacketTim
                  statusCode:(NSInteger)statusCode
{
    return [[self alloc] initWith:reqDst
                        reqMethod:reqMethod
                           reqTim:reqTim
                    clientWastTim:clientWastTim
                         totalTim:totalTim
                           dnsTim:dnsTim
                           sslTim:sslTim
                           tcpTim:tcpTim
                   firstPacketTim:firstPacketTim
                       statusCode:statusCode];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"reqTime: %ld, reqDst:%@, reqMethod:%@, clientWastTim:%ld, totalTim:%ld, dnsTim:%ld, sslTim:%ld, tcpTim:%ld, firstPacketTim:%ld, statusCode:%ld",self.reqTim,self.reqDst,self.reqMethod,self.clientWastTim,self.totalTim,self.dnsTim,self.sslTim,self.tcpTim,self.firstPacketTim,self.statusCode];
}

@end
