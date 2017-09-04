//
//  OCStarListStorage.h
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/9/1.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Repo.h"

@interface OCStarListDAO_WC : NSObject
- (NSArray<Repo *> *)selectReposOrderByStarCountLimit:(NSInteger)limit;
- (BOOL)insertOrReplaceRepos:(NSArray<Repo *> *)repos;
- (NSInteger)selectRepoCount;
- (BOOL)deleteOverflowRepos:(NSInteger)maxCount;
@end
