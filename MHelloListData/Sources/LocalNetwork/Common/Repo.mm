//
//  Repo.m
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/8/18.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import "Repo.h"
#import <WCDB/WCDB.h>

@implementation Repo

WCDB_IMPLEMENTATION(Repo)
WCDB_SYNTHESIZE(Repo, rID)
WCDB_SYNTHESIZE(Repo, name)
WCDB_SYNTHESIZE(Repo, starCount)
WCDB_SYNTHESIZE(Repo, desc)
WCDB_SYNTHESIZE(Repo, ownerName)
WCDB_SYNTHESIZE(Repo, ownerAvatarURLString)
WCDB_SYNTHESIZE(Repo, updateTime)

WCDB_PRIMARY(Repo, rID)
WCDB_INDEX(Repo, "_index", rID) // TableName_index
WCDB_INDEX(Repo, "_index", starCount)

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"rID" : @"id",
             @"starCount" : @"stargazers_count",
             @"desc" : @"description",
             @"ownerName" : @"owner.login",
             @"ownerAvatarURLString" : @"owner.avatar_url",
             @"updateTime" : @"updated_at",
             };
}
@end
