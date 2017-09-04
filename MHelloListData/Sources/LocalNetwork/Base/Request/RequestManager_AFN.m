//
//  LNRequestManager.m
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/8/20.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import "RequestManager_AFN.h"

static NSString * const kBaseURLString = @"https://api.github.com/";

@interface RequestManager_AFN ()
@property (nonatomic) AFHTTPSessionManager *manager;
@property (nonatomic) NSMutableDictionary *requestDict;
@end

@implementation RequestManager_AFN

+ (instancetype)sharedInstance {
    static RequestManager_AFN *s_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [self new];
    });
    
    return s_instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.requestDict = [NSMutableDictionary dictionary];
        
        self.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:[self baseURLString]]];
        [self configManager];
    }
    
    return self;
}

#pragma mark - Should Override
- (NSString *)baseURLString {
    return kBaseURLString;
}

- (void)configManager {}

#pragma mark - Public
- (Request *)GET:(NSString *)URLString
      parameters:(id)parameters
        progress:(void (^)(NSProgress *))downloadProgressBlock
         success:(void (^)(Request *, ReturnData *))successBlock
         failure:(void (^)(Request *, ReturnData *))failureBlock {
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [self.manager GET:URLString
           parameters:parameters
             progress:^(NSProgress * _Nonnull downloadProgress) {
                 if (downloadProgressBlock) {
                     downloadProgressBlock(downloadProgress);
                 }
             }
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  if (!successBlock) {
                      return;
                  }
                  Request *request = [weakSelf.requestDict objectForKey:@(task.taskIdentifier)];
                  [weakSelf.requestDict removeObjectForKey:@(task.taskIdentifier)];
                  ReturnData *data = [ReturnData new];
                  data.code = ReturnDataCodeRequestOK;
                  data.responseData = responseObject;
                  successBlock(request, data);
              }
              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  NSLog(@"【chenms】error:%@  %s", error, __func__);
                  if (!failureBlock) {
                      return;
                  }
                  Request *request = [weakSelf.requestDict objectForKey:@(task.taskIdentifier)];
                  [weakSelf.requestDict removeObjectForKey:@(task.taskIdentifier)];
                  ReturnData *data = [ReturnData new];
                  data.code = ReturnDataCodeRequestDataFail;
                  data.error = error;
                  successBlock(request, data);
              }];
    
    
    Request *request = [Request requestWithTask:task];
    request.onDidCancelBlock = ^(Request *request) {
        [weakSelf.requestDict removeObjectForKey:@(request.task.taskIdentifier)];
    };
    [self.requestDict setObject:request forKey:@(task.taskIdentifier)];
    
    return request;
}

@end
