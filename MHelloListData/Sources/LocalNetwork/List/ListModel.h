//
//  ListModel.h
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/7/31.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReturnData.h"
#import "Request.h"

@protocol ListModelDelegate;

typedef NS_ENUM(NSUInteger, ListModelRule) {
    ListModelRuleNetwork = 0,
    ListModelRuleLocalNetwork,
};

typedef NS_ENUM(NSUInteger, ListModelRequestCount) {
    ListModelRequestCountSmall = 10,
    ListModelRequestCountBig = 15,
};

@interface ListModel : NSObject
@property (nonatomic, readonly) BOOL isFetching;
@property (nonatomic, readonly) NSInteger page;
@property (nonatomic, readonly) BOOL isLoadMore;
@property (nonatomic, readonly) NSMutableArray *datas;
@property (nonatomic, readonly) BOOL hasMore;
@property (nonatomic, copy) void(^onModelDidFetchDataFromCacheBlock)(ListModel *model, BOOL isRequesting);
@property (nonatomic, copy) void(^onModelRequestDidFinishBlock)(ListModel *model);
@property (nonatomic, copy) void(^onModelRequestDidFailBlock)(ListModel *model);

// Public
- (BOOL)needRefresh;
- (void)refresh;
- (void)loadMore;

// Should Override
// Request
- (NSString *)urlString;
- (NSDictionary *)paramtersForRefresh;
- (NSDictionary *)paramtersForLoadMore;
// Response
- (id)dataWithResponseData:(id)responseData;
- (NSArray *)datasOfCleanDuplicatedDatas:(NSArray *)datas;
// Cache
- (NSArray *)fetchCacheData;
- (void)saveNewDatas:(NSArray *)datas;
- (NSInteger)cacheDataCount;
- (NSInteger)maxCount;
- (void)cleanOverflowDatas:(NSInteger)maxCount;
@end

