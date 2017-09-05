//
//  OCStarListStorage.m
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/9/1.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import "OCStarListDAO_WC.h"
#import "DBManager_WC.h"
#import "DBConstants.h"
#import "Repo+WCTTableCoding.h"
#import <WCDB/WCDB.h>

@implementation OCStarListDAO_WC
- (instancetype)init {
    self = [super init];
    if (self) {
        [[DBManager_WC sharedInstance].database createTableAndIndexesOfName:kTableName_oc_star withClass:Repo.class];
    }
    
    return self;
}

- (NSArray<Repo *> *)selectReposOrderByStarCountLimit:(NSInteger)limit {
    NSArray<Repo *> *repos = [[DBManager_WC sharedInstance].database
                              getObjectsOfClass:Repo.class
                              fromTable:kTableName_oc_star
                              orderBy:Repo.starCount.order(WCTOrderedDescending)
                              limit:limit];
    
    return repos;
}

- (BOOL)insertOrReplaceRepos:(NSArray<Repo *> *)repos {
    if (!repos) {
        return NO;
    }
    BOOL success = [[DBManager_WC sharedInstance].database insertOrReplaceObjects:repos into:kTableName_oc_star];
    
    return success;
}

- (NSInteger)selectRepoCount {
    NSInteger count = [[[DBManager_WC sharedInstance].database getOneValueOnResult:Repo.rID.count() fromTable:kTableName_oc_star] integerValue];
    
    return count;
}

- (BOOL)deleteOverflowRepos:(NSInteger)maxCount {
    BOOL success = [[DBManager_WC sharedInstance].database deleteObjectsFromTable:kTableName_oc_star
                                                                          orderBy:Repo.starCount.order(WCTOrderedDescending)
                                                                            limit:1000
                                                                           offset:maxCount];
    return success;
}

@end
