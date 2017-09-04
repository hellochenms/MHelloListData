//
//  DBManager_WC.h
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/9/1.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WCDB/WCDB.h>

@interface DBManager_WC : NSObject
@property (nonatomic, readonly) WCTDatabase *database;
+ (instancetype)sharedInstance;

@end
