//
//  StarListModel.m
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/8/18.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import "OCStarListModel.h"
#import "Repo.h"
#import <YYModel/YYModel.h>

@implementation OCStarListModel

- (NSString *)urlString {
    return @"search/repositories";
}

- (NSDictionary *)paramtersForRefresh {
    return  @{@"q" : @"language:objective-c",
              @"sort" : @"stars",
              @"page" : @1,
              @"per_page" : @10
              };
}

- (NSDictionary *)paramtersForLoadMore {
    return  @{@"q" : @"language:objective-c",
              @"sort" : @"stars",
              @"page" : @(self.page + 1),
              @"per_page" : @10
              };
}

- (id)dataWithResponseData:(id)responseData {
    if (![responseData isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    NSArray *itemsJSON = [responseData objectForKey:@"items"];
    if (!itemsJSON || ![itemsJSON isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    NSArray<Repo*> *items = [NSArray yy_modelArrayWithClass:[Repo class] json:itemsJSON];
    
    return items;
}

@end
