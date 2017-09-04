//
//  OCStarListDAO_FM.m
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/9/4.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import "OCStarListDAO_FM.h"

@implementation OCStarListDAO_FM

- (NSArray<Repo *> *)selectReposOrderByStarCountLimit:(NSInteger)limit {
    return nil;
}

- (BOOL)insertOrReplaceRepos:(NSArray<Repo *> *)repos {
    return NO;
}

- (NSInteger)selectRepoCount {
    return 0;
}

- (BOOL)deleteOverflowRepos:(NSInteger)maxCount {
    return NO;
}

@end
