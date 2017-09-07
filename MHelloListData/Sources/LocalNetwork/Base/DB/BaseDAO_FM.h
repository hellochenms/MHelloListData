//
//  BaseDAO_FM.h
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/9/7.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseDAO_FM : NSObject
- (BOOL)tryCreateTableSQLForTableName:(NSString *)tableName
                                  clz:(Class)clz
                           primaryKey:(NSString *)primaryKey;
- (NSString *)tableSQLForTableName:(NSString *)tableName
                               clz:(Class)clz
                        primaryKey:(NSString *)primaryKey;
- (BOOL)tryCreateIndexForTableName:(NSString *)tableName
                           indexes:(NSArray *)indexes;
- (NSString *)indexSQLForTableName:(NSString *)tableName
                           indexes:(NSArray *)indexes;
- (NSArray *)selectObjectsFromTableName:(NSString *)tableName
                                    clz:(Class)clz
                                orderBy:(NSString *)orderBy
                          isOrderByDesc:(BOOL)isOrderByDesc
                                  limit:(NSInteger)limit;
- (NSString *)selectSQLForTableName:(NSString *)tableName
                            orderBy:(NSString *)orderBy
                      isOrderByDesc:(BOOL)isOrderByDesc
                              limit:(NSInteger)limit;
- (BOOL)insertOrReplaceObjects:(NSArray *)objects
                     tableName:(NSString *)tableName
                           clz:(Class)clz;
- (BOOL)insertOrReplaceObject:(NSObject *)object
                    tableName:(NSString *)tableName
                          clz:(Class)clz;
- (NSString *)insertOrReplaceSQLForObject:(NSObject *)object
                                tableName:(NSString *)tableName
                                      clz:(Class)clz
                                     args:(NSArray **)args;
- (NSInteger)selectCountFromTableName:(NSString *)tableName;
- (BOOL)deleteOverflowObjects:(NSInteger)maxCount
                    tableName:(NSString *)tableName
                   primaryKey:(NSString *)primaryKey
                      orderBy:(NSString *)orderBy
                isOrderByDesc:(BOOL)isOrderByDesc;
@end
