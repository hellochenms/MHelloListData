//
//  StarListModel.m
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/8/18.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import "OCStarListModel.h"
#import "Repo.h"
#import <YYModel/YYModel.h>
#import "OCStarListDAO_WC.h"
#import "OCStarListDAO_FM_SQL.h"
#import "OCStarListDAO_FM.h"

@interface OCStarListModel ()
//@property (nonatomic) OCStarListDAO_WC *dao;
//@property (nonatomic) OCStarListDAO_FM_SQL *dao;
@property (nonatomic) OCStarListDAO_FM *dao;
@end

@implementation OCStarListModel

#pragma mark - Override
// Request
- (NSString *)urlString {
    return @"search/repositories";
}

- (NSDictionary *)paramtersForRefresh {
    return  @{@"q" : @"language:objective-c",
              @"sort" : @"stars",
              @"page" : @1,
              @"per_page" : @10
              };
}

- (NSDictionary *)paramtersForLoadMore {
    return  @{@"q" : @"language:objective-c",
              @"sort" : @"stars",
              @"page" : @(self.page + 1),
              @"per_page" : @10
              };
}

// Response
- (id)dataWithResponseData:(id)responseData {
    if (![responseData isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    NSArray *itemsJSON = [responseData objectForKey:@"items"];
    if (!itemsJSON || ![itemsJSON isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    NSArray<Repo*> *items = [NSArray yy_modelArrayWithClass:[Repo class] json:itemsJSON];
    
    return items;
}

- (NSString *)keyForData:(id)data {
    if (![data isKindOfClass:[Repo class]]) {
        return @"";
    }
    
    NSString *key = [NSString stringWithFormat:@"%ld", ((Repo *)data).rID];
    
    return key;
}

// Cache
- (NSArray *)fetchCacheData {
    NSArray *repos = [self.dao selectReposOrderByStarCountLimit:20];
    
    return repos;
}

- (void)saveNewDatas:(NSArray *)datas {
    if (!datas || [datas count] == 0) {
        return;
    }
    
    __block BOOL valid = YES;
    [datas enumerateObjectsUsingBlock:^(Repo *  _Nonnull repo, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![repo isKindOfClass:[Repo class]]) {
            valid = NO;
            *stop = YES;
        }
    }];
    
    if (!valid) {
        return;
    }
    
    // 插入新数据
    [self.dao insertOrReplaceRepos:datas];

}

- (NSInteger)cacheDataCount {
    NSInteger count = [self.dao selectRepoCount];
    
    return count;
}


- (void)cleanOverflowDatas:(NSInteger)maxCount {
    [self.dao deleteOverflowRepos:maxCount];
}

#pragma mark - Getter
//- (OCStarListDAO_WC *)dao {
//    if(!_dao){
//        _dao = [[OCStarListDAO_WC alloc] init];
//    }
//    return _dao;
//}

//- (OCStarListDAO_FM_SQL *)dao {
//    if(!_dao){
//        _dao = [[OCStarListDAO_FM_SQL alloc] init];
//    }
//    return _dao;
//}

- (OCStarListDAO_FM *)dao {
    if(!_dao){
        _dao = [[OCStarListDAO_FM alloc] init];
    }
    return _dao;
}

@end
