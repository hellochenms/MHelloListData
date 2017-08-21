//
//  LNRequest.m
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/7/31.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import "LNRequest.h"

@interface LNRequest ()
@property (nonatomic) NSURLSessionDataTask *task;
@end

@implementation LNRequest
+ (instancetype)requestWithTask:(NSURLSessionDataTask *)task {
    LNRequest *request = [self new];
    request.task = task;
    
    return request;
}

- (void)resume {
    [self.task resume];
}

- (void)cancel {
    [self.task cancel];
    if (self.onDidCancelBlock) {
        self.onDidCancelBlock(self);
    }
}

@end
