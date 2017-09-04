//
//  LNRequestManager.h
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/8/20.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "Request.h"
#import "ReturnData.h"

@interface RequestManager_AFN : NSObject
@property (nonatomic, readonly) AFHTTPSessionManager *manager;
+ (instancetype)sharedInstance;
- (Request *)GET:(NSString *)URLString
        parameters:(id)parameters
          progress:(void (^)(NSProgress *))downloadProgressBlock
           success:(void (^)(Request *, ReturnData *))successBlock
           failure:(void (^)(Request *, ReturnData *))failureBlock;
@end
