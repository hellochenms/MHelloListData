//
//  OCStarListDAO_FM.m
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/9/5.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import "OCStarListDAO_FM.h"
#import "DBManager_FM.h"
#import "DBConstants.h"

@implementation OCStarListDAO_FM
- (instancetype)init {
    self = [super init];
    if (self) {
        if (![[DBManager_FM sharedInstance].database tableExists:kTableName_oc_star]) {
            // table
            [self tryCreateTableSQLForTableName:kTableName_oc_star
                                            clz:Repo.class
                                     primaryKey:kRFMColumnRID];
            
            // index
            [self tryCreateIndexForTableName:kTableName_oc_star
                                     indexes:@[kRFMColumnRID, kRFMColumnStarCount]];
        }
    }
    
    return self;
}

- (NSArray<Repo *> *)selectReposOrderByStarCountLimit:(NSInteger)limit {
    NSArray *repos = [self selectObjectsFromTableName:kTableName_oc_star
                                                  clz:Repo.class
                                              orderBy:kRFMColumnStarCount
                                        isOrderByDesc:YES
                                                limit:limit];
    
    return repos;
}

- (BOOL)insertOrReplaceRepos:(NSArray<Repo *> *)repos {
    BOOL success = [self insertOrReplaceObjects:repos
                                      tableName:kTableName_oc_star
                                            clz:Repo.class];
    
    return success;
}

- (NSInteger)selectRepoCount {
    NSInteger count = [self selectCountFromTableName:kTableName_oc_star];
    
    return count;
}

- (BOOL)deleteOverflowRepos:(NSInteger)maxCount {
    BOOL success = [self deleteOverflowObjects:maxCount
                                     tableName:kTableName_oc_star
                                    primaryKey:kRFMColumnRID
                                       orderBy:kRFMColumnStarCount
                                 isOrderByDesc:YES];
    
    return success;
}

@end
