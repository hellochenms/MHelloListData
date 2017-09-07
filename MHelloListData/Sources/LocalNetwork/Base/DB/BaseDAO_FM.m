//
//  BaseDAO_FM.m
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/9/7.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import "BaseDAO_FM.h"
#import "M7PropertyHelper.h"
#import "DBManager_FM.h"
#import "M4PropertyFMDBAdapter.h"

@implementation BaseDAO_FM
- (BOOL)tryCreateTableSQLForTableName:(NSString *)tableName
                                  clz:(Class)clz
                           primaryKey:(NSString *)primaryKey {
    NSString *tableSQL = [self tableSQLForTableName:tableName
                                                clz:clz
                                         primaryKey:primaryKey];
    return [[DBManager_FM sharedInstance].database executeUpdate:tableSQL];
}

- (NSString *)tableSQLForTableName:(NSString *)tableName
                               clz:(Class)clz
                        primaryKey:(NSString *)primaryKey {
    if ([tableName length] == 0 || !clz || [primaryKey length] == 0) {
        return nil;
    }
    
    M7PropertyHelper *helper = [M7PropertyHelper helperWithClass:clz];
    M4PropertyFMDBAdapter *adapter = [M4PropertyFMDBAdapter adapterWithPropertyHelper:helper];
    if ([helper.propertyNames count] == 0) {
        return nil;
    }
    
    NSMutableString *tableSQL = [NSMutableString string];
    [tableSQL appendString:@"create table if not exists"];
    [tableSQL appendFormat:@" %@ (", tableName];
    
    [helper.propertyNames enumerateObjectsUsingBlock:^(NSString *  _Nonnull propertyName, NSUInteger idx, BOOL * _Nonnull stop) {
        [tableSQL appendFormat:@"%@ %@,", propertyName, [adapter dbTypeWithPropertyName:propertyName]];
    }];
    
    [tableSQL appendFormat:@" primary key (%@));", primaryKey];
    
    return tableSQL;
}

- (BOOL)tryCreateIndexForTableName:(NSString *)tableName
                           indexes:(NSArray *)indexes {
    NSString *indexSQL = [self indexSQLForTableName:tableName
                                            indexes:indexes];
    return [[DBManager_FM sharedInstance].database executeUpdate:indexSQL];
}

- (NSString *)indexSQLForTableName:(NSString *)tableName
                           indexes:(NSArray *)indexes {
    if ([tableName length] == 0 || [indexes count] == 0) {
        return nil;
    }
    
    NSMutableString *indexSQL = [NSMutableString string];
    [indexSQL appendString:@"create index if not exists"];
    [indexSQL appendFormat:@" %@_index on %@ (", tableName, tableName];
    [indexes enumerateObjectsUsingBlock:^(NSString *  _Nonnull index, NSUInteger idx, BOOL * _Nonnull stop) {
        [indexSQL appendFormat:@"%@,", index];
    }];
    [indexSQL deleteCharactersInRange:NSMakeRange([indexSQL length] - 1, 1)];
    [indexSQL appendString:@");"];
    
    return indexSQL;
}

- (NSArray *)selectObjectsFromTableName:(NSString *)tableName
                                    clz:(Class)clz
                                orderBy:(NSString *)orderBy
                          isOrderByDesc:(BOOL)isOrderByDesc
                                  limit:(NSInteger)limit {
    if ([tableName length] == 0 || !clz) {
        return nil;
    }
    
    M7PropertyHelper *helper = [M7PropertyHelper helperWithClass:clz];
    M4PropertyFMDBAdapter *adapter = [M4PropertyFMDBAdapter adapterWithPropertyHelper:helper];
    if ([helper.propertyNames count] == 0) {
        return nil;
    }
    
    NSString *sql = [self selectSQLForTableName:tableName orderBy:orderBy isOrderByDesc:isOrderByDesc limit:limit];
    
    FMResultSet *resultSet = [[DBManager_FM sharedInstance].database executeQuery:sql];
    NSMutableArray *objects = [NSMutableArray array];
    while ([resultSet next]) {
        NSObject *object = [clz new];
        [helper.propertyNames enumerateObjectsUsingBlock:^(NSString *  _Nonnull name, NSUInteger idx, BOOL * _Nonnull stop) {
            NSObject *value = [adapter valueFromResultSet:resultSet propertyName:name];
            if (value) {
                [object setValue:value forKey:name];
            }
        }];
        [objects addObject:object];
    }
    
    return objects;
}


- (NSString *)selectSQLForTableName:(NSString *)tableName
                            orderBy:(NSString *)orderBy
                      isOrderByDesc:(BOOL)isOrderByDesc
                              limit:(NSInteger)limit {
    if ([tableName length] == 0) {
        return nil;
    }
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select * from %@", tableName];
    if ([orderBy length] > 0) {
        [sql appendFormat:@" order by %@ %@", orderBy, (isOrderByDesc ? @"desc" :@"asc")];
    }
    if (limit > 0) {
        [sql appendFormat:@" limit %ld", limit];
    }
    [sql appendString:@";"];
    
    return sql;
}

- (BOOL)insertOrReplaceObjects:(NSArray *)objects
                     tableName:(NSString *)tableName
                           clz:(Class)clz {
    if ([objects count] == 0 || [tableName length] == 0 || !clz) {
        return NO;
    }
    
    [[DBManager_FM sharedInstance].database beginTransaction];
    __block BOOL allSuccess = YES;
    
    [objects enumerateObjectsUsingBlock:^(NSObject *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL success = [self insertOrReplaceObject:obj
                                         tableName:tableName
                                               clz:clz];
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

- (BOOL)insertOrReplaceObject:(NSObject *)object
                    tableName:(NSString *)tableName
                          clz:(Class)clz {
    NSArray *args = nil;
    NSString *sql = [self insertOrReplaceSQLForObject:object
                                            tableName:tableName
                                                  clz:clz
                                                 args:&args];
    
    BOOL success = [[DBManager_FM sharedInstance].database executeUpdate:sql withArgumentsInArray:args];
    
    return success;
}

- (NSString *)insertOrReplaceSQLForObject:(NSObject *)object
                                tableName:(NSString *)tableName
                                      clz:(Class)clz
                                     args:(NSArray **)args {
    if (!object || [tableName length] == 0 || !clz) {
        return nil;
    }
    
    M7PropertyHelper *helper = [M7PropertyHelper helperWithClass:clz];
    M4PropertyFMDBAdapter *adapter = [M4PropertyFMDBAdapter adapterWithPropertyHelper:helper];
    if ([helper.propertyNames count] == 0) {
        return nil;
    }
    
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:@"insert or replace into"];
    [sql appendFormat:@" %@ (", tableName];
    
    NSMutableArray *theArgs = [NSMutableArray array];
    
    [helper.propertyNames enumerateObjectsUsingBlock:^(NSString *  _Nonnull name, NSUInteger idx, BOOL * _Nonnull stop) {
        NSObject *value = [object valueForKey:name];
        if (value) {
            [sql appendFormat:@"%@,", name];
            [theArgs addObject:[adapter dbValueFromPropertyValue:value propertyType:[helper typeWithPropertyName:name]]];
        }
    }];
    *args = theArgs;
    
    if ([sql hasSuffix:@","]) {
        [sql deleteCharactersInRange:NSMakeRange([sql length] - 1, 1)];
    }
    [sql appendString:@") values ("];
    NSInteger count = [theArgs count];
    for (NSInteger i = 0; i < count; i++) {
        [sql appendString:@"?,"];
    }
    if ([sql hasSuffix:@","]) {
        [sql deleteCharactersInRange:NSMakeRange([sql length] - 1, 1)];
    }
    [sql appendString:@");"];
    
    return sql;
}

- (NSInteger)selectCountFromTableName:(NSString *)tableName {
    if ([tableName length] == 0) {
        return 0;
    }
    
    NSString *sql = [NSString stringWithFormat:@"select count(*) from %@;", tableName];
    FMResultSet *resultSet = [[DBManager_FM sharedInstance].database executeQuery:sql];
    [resultSet next];
    
    NSInteger count = [resultSet intForColumnIndex:0];
    
    return count;
}


- (BOOL)deleteOverflowObjects:(NSInteger)maxCount
                    tableName:(NSString *)tableName
                   primaryKey:(NSString *)primaryKey
                      orderBy:(NSString *)orderBy
                isOrderByDesc:(BOOL)isOrderByDesc {
    if (maxCount < 0 || [tableName length] == 0 || [primaryKey length] == 0) {
        return NO;
    }
    
    NSMutableString *subSQL = [NSMutableString stringWithFormat:@"select %@ from %@", primaryKey, tableName];
    if ([orderBy length] > 0) {
        [subSQL appendFormat:@" order by %@ %@", orderBy, (isOrderByDesc ? @"desc" :@"asc")];
    }
    [subSQL appendFormat:@" limit %d offset %ld", 10000, maxCount];
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@ in (%@);", tableName, primaryKey, subSQL];
    BOOL success = [[DBManager_FM sharedInstance].database executeUpdate:sql];
    
    return success;
}

@end
