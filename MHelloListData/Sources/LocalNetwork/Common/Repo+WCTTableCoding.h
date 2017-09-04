//
//  Repo+WCTTableCoding.h
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/9/4.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import "Repo.h"
#import <WCDB/WCDB.h>

@interface Repo (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(rID)
WCDB_PROPERTY(name)
WCDB_PROPERTY(starCount)
WCDB_PROPERTY(desc)
WCDB_PROPERTY(ownerName)
WCDB_PROPERTY(ownerAvatarURLString)
WCDB_PROPERTY(updateTime)

@end
