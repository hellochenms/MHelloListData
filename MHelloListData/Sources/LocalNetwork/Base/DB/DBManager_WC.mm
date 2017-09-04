//
//  DBManager_WC.m
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/9/1.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import "DBManager_WC.h"

@interface DBManager_WC ()
@property (nonatomic) WCTDatabase *database;
@end

@implementation DBManager_WC

+ (instancetype)sharedInstance {
    static DBManager_WC *s_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [self new];
    });
    
    return s_instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _database = [[WCTDatabase alloc] initWithPath:[self path]];
    }
    
    return self;
}

#pragma mark - Tools
- (NSString *)path {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    path = [path stringByAppendingPathComponent:@"db"];
    path = [path stringByAppendingPathComponent:@"default.sqlite"];
    
    return path;
}

@end
