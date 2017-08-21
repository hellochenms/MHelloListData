//
//  NModel.h
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/7/31.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NModel : NSObject
@property (nonatomic, readonly) NSPointerArray *delegates;
@property (nonatomic) BOOL hasMore;
- (void)refresh;
- (void)loadMore;
@end
