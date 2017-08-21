//
//  LNListModel.m
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/7/31.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import "LNListModel.h"
#import "JSONRequestManager.h"

#import "LNRequest.h"

static NSTimeInterval const kExpiredTimeInterval = 10;

@interface LNListModel ()
@property (nonatomic) NSInteger page;
@property (nonatomic) BOOL isLoadMore;
@property (nonatomic) BOOL isRefreshing;
@property (nonatomic) BOOL isLoadingMore;
@property (nonatomic) LNRequest *request;
@property (nonatomic) LNListModelRule rule;
@property (nonatomic) LNListModelRequestCount requestCount;
@property (nonatomic) NSMutableArray *datas;
@property (nonatomic) NSTimeInterval modelRefreshTimestamp;
@property (nonatomic) BOOL hasMore;
@end

@implementation LNListModel

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
        LNReturnData *cacheData = [self fetchCacheData];
        if (cacheData.data) {
            cacheData.code = LNReturnDataCodeLocalOKRequesting;
            [self didReceivedData:cacheData];
        }
        self.requestCount = LNListModelRequestCountBig;
    } else {
        if ([self hasExpired]) {
            self.requestCount = LNListModelRequestCountBig;
        } else {
            self.requestCount = LNListModelRequestCountSmall;
        }
    }
    
    // 请求
    __weak typeof(self) weakSelf = self;
    self.request = [[JSONRequestManager sharedInstance] GET:[self urlString]
                                               parameters:[self paramtersForRefresh]
                                                 progress:nil
                                                  success:^(LNRequest *request, LNReturnData *returnData) {
                                                      weakSelf.modelRefreshTimestamp = [[NSDate date] timeIntervalSince1970];
                                                      id data = [weakSelf dataWithResponseData:returnData.responseData];
                                                      returnData.data = data;
                                                      if (returnData.responseData
                                                          && (!returnData.data || ![returnData.data isKindOfClass:[NSArray class]])) {
                                                          returnData.code = LNReturnDataCodeRequestDataFail;
                                                      }
                                                      
                                                      [weakSelf didReceivedNetworkData:returnData];
                                                      weakSelf.isRefreshing = NO;
                                                  }
                                                  failure:^(LNRequest *request, LNReturnData *returnData) {
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
                                                  success:^(LNRequest *request, LNReturnData *returnData) {
                                                      id data = [weakSelf dataWithResponseData:returnData.responseData];
                                                      returnData.data = data;
                                                      if (returnData.responseData
                                                          && (!returnData.data || ![returnData.data isKindOfClass:[NSArray class]])) {
                                                          returnData.code = LNReturnDataCodeRequestDataFail;
                                                      }
                                                      
                                                      [weakSelf didReceivedNetworkData:returnData];
                                                      weakSelf.isLoadingMore = NO;
                                                  }
                                                  failure:^(LNRequest *request, LNReturnData *returnData) {
                                                      NSLog(@"【chenms】  %s", __func__);
                                                      [weakSelf didReceivedNetworkData:returnData];
                                                      weakSelf.isLoadingMore = NO;
                                                  }];
    [self.request resume];
}

#pragma mark - data 
- (void)didReceivedNetworkData:(LNReturnData *)data {
    if (!self.isLoadMore) {
        [self didReceivedNetworkRefreshData:data];
    } else {
        [self didReceivedNetworkLoadMoreData:data];
    }
    [self didReceivedData:data];
}

- (void)didReceivedNetworkRefreshData:(LNReturnData *)data {
    
}

- (void)didReceivedNetworkLoadMoreData:(LNReturnData *)data {
    self.page += 1;
}

- (void)didReceivedData:(LNReturnData *)data {
    [self handleWithData:data];
    
    switch (data.code) {
        case LNReturnDataCodeLocalOK:
            [self didFetchDataFromCache:NO];
            break;
        case LNReturnDataCodeLocalOKRequesting:
            [self didFetchDataFromCache:YES];
            break;
        case LNReturnDataCodeRequestOK:
            [self requestDidFinish];
            break;
        case LNReturnDataCodeRequestDataFail:
        case LNReturnDataCodeErrorUnknown:
            [self requestDidFail];
            break;
        default:
            [self requestDidFail];
            break;
    }
}

- (void)handleWithData:(LNReturnData *)data {
    [self.datas removeAllObjects];
    [self.datas addObjectsFromArray:data.data];
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
- (LNReturnData *)fetchCacheData {
    return nil;
}
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
