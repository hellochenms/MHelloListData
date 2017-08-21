//
//  LNRequest.h
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/7/31.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LNRequest : NSObject
@property (nonatomic, readonly) NSURLSessionDataTask *task;
+ (instancetype)requestWithTask:(NSURLSessionDataTask *)task;
@property (nonatomic, copy) void(^onDidCancelBlock)(LNRequest *);
- (void)resume;
- (void)cancel;
@end
