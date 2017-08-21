//
//  LNDetailModel.h
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/8/21.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LNDetailModel : NSObject
@property (nonatomic, readonly) BOOL isFetching;
@property (nonatomic, copy) NSString *detailHTML;
@property (nonatomic, copy) void(^onModelRequestDidFinishBlock)(LNDetailModel *model);
@property (nonatomic, copy) void(^onModelRequestDidFailBlock)(LNDetailModel *model);
- (void)fetchWithOwnerName:(NSString *)ownerName repoName:(NSString *)repoName;
@end
