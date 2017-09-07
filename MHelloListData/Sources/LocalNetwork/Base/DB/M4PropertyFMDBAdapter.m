//
//  M4PropertyFMDBAdapter.m
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/9/7.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import "M4PropertyFMDBAdapter.h"

@interface M4PropertyFMDBAdapter ()
@property (nonatomic) NSDictionary *propertyTypeDBTypeMapping;
@end

@implementation M4PropertyFMDBAdapter

#pragma mark - Init
- (instancetype)init {
    return [self initWithPropertyHelper:nil];
}

- (instancetype)initWithPropertyHelper:(M7PropertyHelper *)helper {
    self = [super init];
    if (self) {
        _helper = helper;
    }
    
    return self;
}

+ (instancetype)adapterWithPropertyHelper:(M7PropertyHelper *)helper {
    M4PropertyFMDBAdapter *adapter = [[self alloc] initWithPropertyHelper:helper];
    
    return adapter;
}

#pragma mark - Public
- (NSString *)dbTypeWithPropertyName:(NSString *)name {
    M7PHPropertyType type = [self.helper typeWithPropertyName:name];
    NSString *dbType = [self.propertyTypeDBTypeMapping objectForKey:@(type)];
    
    return dbType;
}

- (NSObject *)dbValueFromPropertyValue:(NSObject *)propertyValue
                          propertyType:(M7PHPropertyType)propertyType {
    if (propertyType == M7PHPropertyTypeDate && [propertyValue isKindOfClass:[NSDate class]]) {
        propertyValue = @((NSInteger)[((NSDate *)propertyValue) timeIntervalSince1970]);
    }
    
    return propertyValue;
}

- (NSObject *)valueFromResultSet:(FMResultSet *)resultSet
                    propertyName:(NSString *)propertyName {
    M7PHPropertyType type = [self.helper typeWithPropertyName:propertyName];
    NSObject *value = nil;
    switch (type) {
        case M7PHPropertyTypeInteger:
            value = @([resultSet intForColumn:propertyName]);
            break;
        case M7PHPropertyTypeDouble:
            value = @([resultSet doubleForColumn:propertyName]);
            break;
        case M7PHPropertyTypeString:
            value = [resultSet stringForColumn:propertyName];
            break;
        case M7PHPropertyTypeData:
            value = [resultSet dataForColumn:propertyName];
            break;
        case M7PHPropertyTypeDate:
            value = [NSDate dateWithTimeIntervalSince1970:[resultSet intForColumn:propertyName]];
            break;
        default:
            break;
    }
    
    return value;
}

#pragma mark - Getter
- (NSDictionary *)propertyTypeDBTypeMapping {
    if (!_propertyTypeDBTypeMapping) {
        _propertyTypeDBTypeMapping = @{@(M7PHPropertyTypeInteger): @"integer",
                                       @(M7PHPropertyTypeDouble): @"real",
                                       @(M7PHPropertyTypeString): @"text",
                                       @(M7PHPropertyTypeData): @"blob",
                                       @(M7PHPropertyTypeDate): @"integer", //赋值时要转换
                                       };
    }
    
    return _propertyTypeDBTypeMapping;
}

@end
