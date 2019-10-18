//
//  MIInputStream.h
//  MIApm
//
//  Created by mediaios on 2019/10/18.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MIInputStream : NSInputStream

- (instancetype)initWithStream:(id)stream;

@end

NS_ASSUME_NONNULL_END
