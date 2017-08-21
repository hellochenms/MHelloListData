//
//  Repo.m
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/8/18.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import "Repo.h"

@implementation Repo
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"starID" : @"id",
             @"starCount" : @"stargazers_count",
             @"desc" : @"description",
             @"ownerName" : @"owner.login",
             @"ownerAvatarURLString" : @"owner.avatar_url",
             @"updateTime" : @"updated_at",
             };
}
@end
