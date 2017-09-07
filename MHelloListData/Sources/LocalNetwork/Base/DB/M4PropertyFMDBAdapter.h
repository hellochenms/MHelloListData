//
//  M4PropertyFMDBAdapter.h
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/9/7.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M7PropertyHelper.h"
#import <FMDB/FMDB.h>

@interface M4PropertyFMDBAdapter : NSObject
@property (nonatomic) M7PropertyHelper *helper;
- (instancetype)initWithPropertyHelper:(M7PropertyHelper *)helper;
+ (instancetype)adapterWithPropertyHelper:(M7PropertyHelper *)helper;
- (NSString *)dbTypeWithPropertyName:(NSString *)name;
- (NSObject *)dbValueFromPropertyValue:(NSObject *)propertyValue
                          propertyType:(M7PHPropertyType)propertyType;
- (NSObject *)valueFromResultSet:(FMResultSet *)resultSet
                    propertyName:(NSString *)propertyName;
@end
