//
//  NModel.m
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/7/31.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import "NModel.h"

@interface NModel ()
@property (nonatomic) NSPointerArray *delegates;
@end

@implementation NModel
- (void)refresh {
    NSLog(@"【chenms】  %s", __func__);
    
}
- (void)loadMore {
    NSLog(@"【chenms】  %s", __func__);
}

#pragma mark - Getter
-(NSPointerArray *)delegates {
    if(!_delegates){
        _delegates = [NSPointerArray weakObjectsPointerArray];
    }
    
    return _delegates;
}

@end
