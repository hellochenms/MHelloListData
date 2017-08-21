//
//  JSONRequestManager.m
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/8/21.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import "JSONRequestManager.h"

@implementation JSONRequestManager
- (void)configManager {
    [self.manager.requestSerializer setValue:@"application/vnd.github.v3+json" forHTTPHeaderField:@"Accept"];
}
@end
