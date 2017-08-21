//
//  LNRequestManager.h
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/8/20.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "LNRequest.h"
#import "LNReturnData.h"

@interface LNRequestManager : NSObject
@property (nonatomic, readonly) AFHTTPSessionManager *manager;
+ (instancetype)sharedInstance;
- (LNRequest *)GET:(NSString *)URLString
        parameters:(id)parameters
          progress:(void (^)(NSProgress *))downloadProgressBlock
           success:(void (^)(LNRequest *, LNReturnData *))successBlock
           failure:(void (^)(LNRequest *, LNReturnData *))failureBlock;
@end
