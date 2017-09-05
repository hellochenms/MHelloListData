//
//  OCStarListDAO_FM.m
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/9/4.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import "OCStarListDAO_FM_SQL.h"
#import "DBManager_FM.h"
#import "DBConstants.h"
#import "Repo+FM_SQL.h"

@implementation OCStarListDAO_FM_SQL

- (instancetype)init {
    self = [super init];
    if (self) {
        if (![[DBManager_FM sharedInstance].database tableExists:kTableName_oc_star]) {
            // table
            NSMutableString *tableSQL = [NSMutableString string];
            [tableSQL appendString:@"create table if not exists"];
            [tableSQL appendFormat:@" %@", kTableName_oc_star];
            [tableSQL appendFormat:@" (%@ integer primary key", kColumnRID];
            [tableSQL appendFormat:@", %@ text", kColumnName];
            [tableSQL appendFormat:@", %@ integer", kColumnStarCount];
            [tableSQL appendFormat:@", %@ text", kColumnDesc];
            [tableSQL appendFormat:@", %@ text", kColumnOwnerName];
            [tableSQL appendFormat:@", %@ text", kColumnOwnerAvatarURLString];
            [tableSQL appendFormat:@", %@ integer);", kColumnUpdateTime];
            [[DBManager_FM sharedInstance].database executeUpdate:tableSQL];
            
            // index
            NSMutableString *indexSQL = [NSMutableString string];
            [indexSQL appendString:@"create index if not exists"];
            [indexSQL appendFormat:@" %@_%@", kTableName_oc_star, kIndexPostfix];
            [indexSQL appendFormat:@" on %@", kTableName_oc_star];
            [indexSQL appendFormat:@" (%@", kColumnRID];
            [indexSQL appendFormat:@", %@);", kColumnStarCount];
            [[DBManager_FM sharedInstance].database executeUpdate:indexSQL];
        }
    }
    
    return self;
}

- (NSArray<Repo *> *)selectReposOrderByStarCountLimit:(NSInteger)limit {
    NSString *sql = [NSString stringWithFormat:@"select * from %@ order by %@ desc limit %ld;", kTableName_oc_star, kColumnStarCount, limit];

    FMResultSet *resultSet = [[DBManager_FM sharedInstance].database executeQuery:sql];
    NSMutableArray *repos = [NSMutableArray array];
    while ([resultSet next]) {
        Repo *repo = [Repo new];
        repo.rID = [resultSet intForColumn:kColumnRID];
        repo.name = [resultSet stringForColumn:kColumnName];
        repo.starCount = [resultSet intForColumn:kColumnStarCount];
        repo.desc = [resultSet stringForColumn:kColumnDesc];
        repo.ownerName = [resultSet stringForColumn:kColumnOwnerName];
        repo.ownerAvatarURLString = [resultSet stringForColumn:kColumnOwnerAvatarURLString];
        repo.updateTime = [NSDate dateWithTimeIntervalSince1970:[resultSet intForColumn:kColumnUpdateTime]];
        [repos addObject:repo];
    }
    
    return repos;
}

- (BOOL)insertOrReplaceRepos:(NSArray<Repo *> *)repos {
    [[DBManager_FM sharedInstance].database beginTransaction];
    __block BOOL allSuccess = YES;
    [repos enumerateObjectsUsingBlock:^(Repo * _Nonnull repo, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableString *sql = [NSMutableString string];
        [sql appendString:@"insert or replace into"];
        [sql appendFormat:@" %@", kTableName_oc_star];
        
        NSMutableArray *args = [NSMutableArray array];
        
        NSInteger count = 0;
        
        [sql appendFormat:@" (%@", kColumnRID];
        [args addObject:[NSString stringWithFormat:@"%ld", repo.rID]];
        count++;
        [sql appendFormat:@", %@", kColumnName];
        [args addObject:repo.name ?: @""];
        count++;
        [sql appendFormat:@", %@", kColumnStarCount];
        [args addObject:[NSString stringWithFormat:@"%ld", repo.starCount]];
        count++;
        [sql appendFormat:@", %@", kColumnDesc];
        [args addObject:repo.desc ?: @""];
        count++;
        [sql appendFormat:@", %@", kColumnOwnerName];
        [args addObject:repo.ownerName ?: @""];
        count++;
        [sql appendFormat:@", %@", kColumnOwnerAvatarURLString];
        [args addObject:repo.ownerAvatarURLString ?: @""];
        count++;
        [sql appendFormat:@", %@) ", kColumnUpdateTime];
        [args addObject:[NSString stringWithFormat:@"%ld", (NSInteger)[repo.updateTime timeIntervalSince1970]]];
        count++;
        [sql appendString:@" values ("];
        for (NSInteger i = 0; i < count; i++) {
            [sql appendString:@"?,"];
        }
        if (count > 0) {
            [sql deleteCharactersInRange:NSMakeRange([sql length] - 1, 1)];
        }
        [sql appendString:@");"];
        
        BOOL success = [[DBManager_FM sharedInstance].database executeUpdate:sql withArgumentsInArray:args];
        if (!success) {
            allSuccess = NO;
            *stop = YES;
        }
    }];
    if (allSuccess) {
        [[DBManager_FM sharedInstance].database commit];
    } else {
        [[DBManager_FM sharedInstance].database rollback];
    }
    
    return allSuccess;
}

- (NSInteger)selectRepoCount {
    NSString *sql = [NSString stringWithFormat:@"select count(*) from %@;", kTableName_oc_star];
    FMResultSet *resultSet = [[DBManager_FM sharedInstance].database executeQuery:sql];
    [resultSet next];
    
    NSInteger count = [resultSet intForColumnIndex:0];
    
    return count;
}

- (BOOL)deleteOverflowRepos:(NSInteger)maxCount {
    NSString *subSQL = [NSString stringWithFormat:@"select %@ from %@ order by %@ desc limit %d offset %ld", kColumnRID, kTableName_oc_star, kColumnStarCount, 1000, maxCount];
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@ in (%@);", kTableName_oc_star, kColumnRID, subSQL];
    BOOL success = [[DBManager_FM sharedInstance].database executeUpdate:sql];
    
    return success;
}

@end
