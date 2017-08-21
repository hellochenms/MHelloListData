//
//  Repo.h
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/8/18.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>

@interface Repo : NSObject
@property (nonatomic) NSInteger starID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSInteger starCount;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *ownerName;
@property (nonatomic, copy) NSString *ownerAvatarURLString;
@property (nonatomic) NSDate *updateTime;

@end
