//
//  DBManager_FM.h
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/9/4.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>

@interface DBManager_FM : NSObject
@property (nonatomic, readonly) FMDatabase *database;
+ (instancetype)sharedInstance;
@end
