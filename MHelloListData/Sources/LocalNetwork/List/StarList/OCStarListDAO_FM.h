//
//  OCStarListDAO_FM.h
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/9/5.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseDAO_FM.h"
#import "Repo.h"

@interface OCStarListDAO_FM : BaseDAO_FM
- (NSArray<Repo *> *)selectReposOrderByStarCountLimit:(NSInteger)limit;
- (BOOL)insertOrReplaceRepos:(NSArray<Repo *> *)repos;
- (NSInteger)selectRepoCount;
- (BOOL)deleteOverflowRepos:(NSInteger)maxCount;
@end
