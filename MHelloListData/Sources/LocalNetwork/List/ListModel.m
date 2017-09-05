//
//  ListModel.m
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/7/31.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import "ListModel.h"
#import "JSONRequestManager.h"

#import "Request.h"

static NSTimeInterval const kExpiredTimeInterval = 10;

@interface ListModel ()
@property (nonatomic) NSInteger page;
@property (nonatomic) BOOL isLoadMore;
@property (nonatomic) BOOL isRefreshing;
@property (nonatomic) BOOL isLoadingMore;
@property (nonatomic) Request *request;
@property (nonatomic) ListModelRule rule;
@property (nonatomic) ListModelRequestCount requestCount;
@property (nonatomic) NSMutableArray *datas;
@property (nonatomic) NSTimeInterval modelRefreshTimestamp;
@property (nonatomic) BOOL hasMore;
@end

@implementation ListModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.page = 1;
    }
    
    return self;
}

#pragma mark - Public
- (BOOL)needRefresh {
    if ([self.datas count] == 0) {
        return YES;
    }
    
    if ([self hasExpired]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isFetching {
    return (self.isRefreshing || self.isLoadingMore);
}

- (void)refresh {
    NSLog(@"【chenms】  %s", __func__);
    [self cancel];
    
    self.isLoadMore = NO;
    self.isRefreshing = YES;
    
    // 选择策略
    if ([self.datas count] == 0) {
        NSArray *datas = [self fetchCacheData];
        if (datas && [datas isKindOfClass:[NSArray class]]) {
            ReturnData *cacheData = [ReturnData new];
            cacheData.data = datas;
            cacheData.code = ReturnDataCodeLocalOKRequesting;
            self.datas = [NSMutableArray arrayWithArray:datas];
            [self didReceivedData:cacheData];
        }
        self.requestCount = ListModelRequestCountBig;
    } else {
        if ([self hasExpired]) {
            self.requestCount = ListModelRequestCountBig;
        } else {
            self.requestCount = ListModelRequestCountSmall;
        }
    }
    
    // 请求
    __weak typeof(self) weakSelf = self;
    self.request = [[JSONRequestManager sharedInstance] GET:[self urlString]
                                               parameters:[self paramtersForRefresh]
                                                 progress:nil
                                                  success:^(Request *request, ReturnData *returnData) {
                                                      weakSelf.modelRefreshTimestamp = [[NSDate date] timeIntervalSince1970];
                                                      id data = [weakSelf dataWithResponseData:returnData.responseData];
                                                      returnData.data = data;
                                                      if (returnData.responseData
                                                          && (!returnData.data || ![returnData.data isKindOfClass:[NSArray class]])) {
                                                          returnData.code = ReturnDataCodeRequestDataFail;
                                                      }
                                                      
                                                      [weakSelf didReceivedNetworkData:returnData];
                                                      weakSelf.isRefreshing = NO;
                                                  }
                                                  failure:^(Request *request, ReturnData *returnData) {
                                                      NSLog(@"【chenms】  %s", __func__);
                                                      weakSelf.isRefreshing = NO;
                                                  }];
    [self.request resume];
}

- (void)loadMore {
    [self cancel];
    
    self.isLoadMore = YES;
    self.isLoadingMore = YES;
    
    // 请求
    __weak typeof(self) weakSelf = self;
    self.request = [[JSONRequestManager sharedInstance] GET:[self urlString]
                                               parameters:[self paramtersForLoadMore]
                                                 progress:nil
                                                  success:^(Request *request, ReturnData *returnData) {
                                                      id data = [weakSelf dataWithResponseData:returnData.responseData];
                                                      returnData.data = data;
                                                      if (returnData.responseData
                                                          && (!returnData.data || ![returnData.data isKindOfClass:[NSArray class]])) {
                                                          returnData.code = ReturnDataCodeRequestDataFail;
                                                      }
                                                      
                                                      [weakSelf didReceivedNetworkData:returnData];
                                                      weakSelf.isLoadingMore = NO;
                                                  }
                                                  failure:^(Request *request, ReturnData *returnData) {
                                                      NSLog(@"【chenms】  %s", __func__);
                                                      [weakSelf didReceivedNetworkData:returnData];
                                                      weakSelf.isLoadingMore = NO;
                                                  }];
    [self.request resume];
}

#pragma mark - data 
- (void)didReceivedNetworkData:(ReturnData *)data {
    if (!self.isLoadMore) {
        [self didReceivedNetworkRefreshData:data];
    } else {
        [self didReceivedNetworkLoadMoreData:data];
    }
    [self didReceivedData:data];
}

- (NSArray *)datasOfCleanDuplicatedDatas:(NSArray *)datas {
    NSMutableArray *responseArray = [NSMutableArray arrayWithArray:datas];
    NSMutableDictionary *existsRIDDict = [NSMutableDictionary dictionary];
    [self.datas enumerateObjectsUsingBlock:^(id _Nonnull data, NSUInteger idx, BOOL * _Nonnull stop) {
        [existsRIDDict setObject:@YES forKey:[self keyForData:data]];
    }];
    NSMutableArray *duplicatedArray = [NSMutableArray array];
    [responseArray enumerateObjectsUsingBlock:^(id _Nonnull data, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[existsRIDDict objectForKey:[self keyForData:data]] boolValue]) {
            [duplicatedArray addObject:data];
        }
    }];
    
    [responseArray removeObjectsInArray:duplicatedArray];
    
    return [responseArray copy];
}

- (void)didReceivedNetworkRefreshData:(ReturnData *)data {
    // 清理数据
    [self.datas removeAllObjects];
    [self.datas addObjectsFromArray:data.data];
    // 缓存
    [self saveDataToCache:data.data];
}

- (void)saveDataToCache:(NSArray *)datas {
    [self saveNewDatas: datas];
    // 去除超出阈值的数据
    NSInteger count = [self cacheDataCount];
    if (count > [self maxCount]) {
        [self cleanOverflowDatas: [self maxCount]];
    }
}

- (void)didReceivedNetworkLoadMoreData:(ReturnData *)data {
    // 去重
    NSArray *datas = [self datasOfCleanDuplicatedDatas:data.data];
    data.data = datas;
    [self.datas addObjectsFromArray:data.data];
    // 页数变更
    self.page += 1;
}

- (void)didReceivedData:(ReturnData *)data {
    switch (data.code) {
        case ReturnDataCodeLocalOK:
            [self didFetchDataFromCache:NO];
            break;
        case ReturnDataCodeLocalOKRequesting:
            [self didFetchDataFromCache:YES];
            break;
        case ReturnDataCodeRequestOK:
            [self requestDidFinish];
            break;
        case ReturnDataCodeRequestDataFail:
        case ReturnDataCodeErrorUnknown:
            [self requestDidFail];
            break;
        default:
            [self requestDidFail];
            break;
    }
}

#pragma mark - Callback
- (void)didFetchDataFromCache:(BOOL)isRequesting {
    if (self.onModelDidFetchDataFromCacheBlock) {
        self.onModelDidFetchDataFromCacheBlock(self, isRequesting);
    }
}

- (void)requestDidFinish {
    if (self.onModelRequestDidFinishBlock) {
        self.onModelRequestDidFinishBlock(self);
    }
}

- (void)requestDidFail {
    if (self.onModelRequestDidFailBlock) {
        self.onModelRequestDidFailBlock(self);
    }
}

#pragma mark - cancel
- (void)cancel {
    [self.request cancel];
}

#pragma mark - Should Override
// request
- (NSString *)urlString {
    return nil;
}
- (NSDictionary *)paramtersForRefresh {
    return nil;
}
- (NSDictionary *)paramtersForLoadMore {
    return nil;
}

// response
- (id)dataWithResponseData:(id)responseData {
    return nil;
}

- (NSString *)keyForData:(id)data {
    return @"";
}

// cache
- (NSArray *)fetchCacheData {
    return nil;
}

- (void)saveNewDatas:(NSArray *)datas {}
- (NSInteger)cacheDataCount {
    return 0;
}
- (NSInteger)maxCount {
    return 20;
}
- (void)cleanOverflowDatas:(NSInteger)maxCount {}

#pragma mark - Tools
- (BOOL)hasExpired {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    BOOL expired = (now - self.modelRefreshTimestamp > kExpiredTimeInterval);
    
    return expired;
}

#pragma mark - Getter
- (NSMutableArray *)datas {
    if (!_datas) {
        _datas = [NSMutableArray array];
    }
    
    return _datas;
}

#pragma mark - Life Cycle
- (void)dealloc {
    [self cancel];
}

@end
