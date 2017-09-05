//
//  DBManager_FM.m
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/9/4.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import "DBManager_FM.h"

@interface DBManager_FM ()
@property (nonatomic) FMDatabase *database;
@end

@implementation DBManager_FM
+ (instancetype)sharedInstance {
    static DBManager_FM *s_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [self new];
    });
    
    return s_instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _database = [FMDatabase databaseWithPath:[self path]];
        [_database open];
    }
    
    return self;
}

#pragma mark - Tools
- (NSString *)path {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    path = [path stringByAppendingPathComponent:@"db"];
    BOOL isDir = NO;
    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
    if (!isExists || !isDir) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    path = [path stringByAppendingPathComponent:@"default.sqlite"];
    
    return path;
}

@end
