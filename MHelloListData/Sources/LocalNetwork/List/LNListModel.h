//
//  LNListModel.h
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/7/31.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LNReturnData.h"
#import "LNRequest.h"

@protocol LNListModelDelegate;

typedef NS_ENUM(NSUInteger, LNListModelRule) {
    LNListModelRuleNetwork = 0,
    LNListModelRuleLocalNetwork,
};

typedef NS_ENUM(NSUInteger, LNListModelRequestCount) {
    LNListModelRequestCountSmall = 10,
    LNListModelRequestCountBig = 15,
};

@interface LNListModel : NSObject
@property (nonatomic, readonly) BOOL isFetching;
@property (nonatomic, readonly) NSInteger page;
@property (nonatomic, readonly) BOOL isLoadMore;
@property (nonatomic, readonly) NSMutableArray *datas;
@property (nonatomic, readonly) BOOL hasMore;
@property (nonatomic, copy) void(^onModelDidFetchDataFromCacheBlock)(LNListModel *model, BOOL isRequesting);
@property (nonatomic, copy) void(^onModelRequestDidFinishBlock)(LNListModel *model);
@property (nonatomic, copy) void(^onModelRequestDidFailBlock)(LNListModel *model);

// Public
- (BOOL)needRefresh;
- (void)refresh;
- (void)loadMore;

// Should Override
- (LNReturnData *)fetchCacheData;
- (NSString *)urlString;
- (NSDictionary *)paramtersForRefresh;
- (NSDictionary *)paramtersForLoadMore;
- (id)dataWithResponseData:(id)responseData;
//- (void)didReceivedNetworkRefreshData:(LNReturnData *)data;
//- (void)didReceivedNetworkLoadMoreData:(LNReturnData *)data;
- (void)handleWithData:(LNReturnData *)data;
@end

