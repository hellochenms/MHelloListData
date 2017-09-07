//
//  M7PropertyHelper.h
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/9/6.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, M7PHPropertyType) {
    M7PHPropertyTypeUnknown = 0,
    M7PHPropertyTypeInteger = 1001,
    M7PHPropertyTypeDouble = 1002,
    M7PHPropertyTypeObject = 2000,
    M7PHPropertyTypeString = 2001,
    M7PHPropertyTypeData = 2002,
    M7PHPropertyTypeDate = 2003,
};

@interface M7PropertyHelper : NSObject
@property (nonatomic, readonly) NSArray *propertyNames;
+ (instancetype)helperWithClass:(Class)clz;
- (M7PHPropertyType)typeWithPropertyName:(NSString *)name;
@end
