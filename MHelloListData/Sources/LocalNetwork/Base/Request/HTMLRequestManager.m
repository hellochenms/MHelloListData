//
//  HTMLRequestManager.m
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/8/21.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import "HTMLRequestManager.h"

@implementation HTMLRequestManager
- (void)configManager {
    [self.manager.requestSerializer setValue:@"application/vnd.github.v3.html" forHTTPHeaderField:@"Accept"];
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
}

@end
