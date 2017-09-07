//
//  M7PropertyHelper.m
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/9/6.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import "M7PropertyHelper.h"
#import <objc/runtime.h>

@interface M7PropertyHelper ()
@property (nonatomic) NSArray *propertyNames;
@property (nonatomic) NSDictionary *excludePropertyNames;
@property (nonatomic) NSDictionary *nameTypeMapping;
@end

@implementation M7PropertyHelper
+ (instancetype)helperWithClass:(Class)clz {
    return [[self alloc] initWithClass:clz];
}


- (instancetype)init {
    return [self initWithClass:nil];
}

- (instancetype)initWithClass:(Class)clz {
    self = [super init];
    if (self) {
        [self prepareDatasWithClass:clz];
    }
    
    return self;
}

#pragma mark - Mapping
- (void)prepareDatasWithClass:(Class)clz {
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(clz, &propertyCount);
    if (properties) {
        NSMutableArray *propertyNames = [NSMutableArray array];
        NSMutableDictionary *nameTypeMapping = [NSMutableDictionary dictionary];
        
        NSMutableDictionary *propertyInfos = [NSMutableDictionary new];
        for (unsigned int i = 0; i < propertyCount; i++) {
            objc_property_t property = properties[i];
            const char *propertyCName = property_getName(property);
            if (!propertyCName) {
                continue;
            }
            NSString *propertyName = [NSString stringWithUTF8String:propertyCName];
            if ([self.excludePropertyNames objectForKey:propertyName]) {
                continue;
            }
            [propertyNames addObject:propertyName];
            
            unsigned int attrCount;
            objc_property_attribute_t *attrs = property_copyAttributeList(property, &attrCount);
            for (unsigned int i = 0; i < attrCount; i++) {
                if (attrs[i].name[0] == 'T') {
                    if (attrs[i].value) {
                        NSString *typeString = [NSString stringWithUTF8String:attrs[i].value];
                        M7PHPropertyType type = m7_extractPropertyType(attrs[i].value);
                        
                        // 如果是对象类型，尝试转化为支持的具体对象类型
                        if (type == M7PHPropertyTypeObject) {
                            NSScanner *scanner = [NSScanner scannerWithString:typeString];
                            if (![scanner scanString:@"@\"" intoString:NULL]) continue;
                            
                            NSString *clsName = nil;
                            if ([scanner scanUpToCharactersFromSet: [NSCharacterSet characterSetWithCharactersInString:@"\"<"] intoString:&clsName]) {
                                if (clsName.length) {
                                    Class clz = objc_getClass(clsName.UTF8String);
                                    type = [self objectTypeWithClz:clz];
                                }
                            }
                        }
                        [nameTypeMapping setObject:@(type) forKey:propertyName];
                    }
                    break;
                }
            }
            if (attrs) {
                free(attrs);
                attrs = NULL;
            }
        }
        self.propertyNames = propertyNames;
        self.nameTypeMapping = nameTypeMapping;
        free(properties);
        properties = NULL;
    }
}

M7PHPropertyType m7_extractPropertyType(const char *typeEncoding) {
    char *type = (char *)typeEncoding;
    if (!type) return M7PHPropertyTypeUnknown;
    size_t len = strlen(type);
    if (len == 0) return M7PHPropertyTypeUnknown;
    
    // 去掉修饰符
    bool prefix = true;
    while (prefix) {
        switch (*type) {
            case 'r':
            case 'n':
            case 'N':
            case 'o':
            case 'O':
            case 'R':
            case 'V':
                type++;
                break;
            default:
                prefix = false;
                break;
        }
    }
    
    len = strlen(type);
    if (len == 0) return M7PHPropertyTypeUnknown;
    
    switch (*type) {
        case 'c':
        case 'C':
        case 's':
        case 'S':
        case 'i':
        case 'I':
        case 'l':
        case 'L':
        case 'q':
        case 'Q':
            return M7PHPropertyTypeInteger;
        case 'f':
        case 'd':
        case 'D':
            return M7PHPropertyTypeDouble;
        case '@': {
            if (len == 2 && *(type + 1) == '?')
                return M7PHPropertyTypeUnknown;
            else
                return M7PHPropertyTypeObject;
        }
        default: return M7PHPropertyTypeUnknown;
    }
}

- (M7PHPropertyType)objectTypeWithClz:(Class)clz {
    M7PHPropertyType type = M7PHPropertyTypeObject;
    if (!clz) {
        return type;
    }
    
    if ([clz isSubclassOfClass:[NSString class]]) {
        type = M7PHPropertyTypeString;
    } else if ([clz isSubclassOfClass:[NSData class]]) {
        type = M7PHPropertyTypeData;
    } else if ([clz isSubclassOfClass:[NSDate class]]) {
        type = M7PHPropertyTypeDate;
    }
    
    return type;
}

#pragma mark - Public
- (M7PHPropertyType)typeWithPropertyName:(NSString *)name {
    NSNumber *typeNumber = [self.nameTypeMapping objectForKey:name];
    if (!typeNumber) {
        return M7PHPropertyTypeUnknown;
    }
    
    M7PHPropertyType type = [typeNumber unsignedIntegerValue];
    
    return type;
}

#pragma mark - Getter
- (NSDictionary *)excludePropertyNames {
    if (!_excludePropertyNames) {
        _excludePropertyNames = @{
                                  @"hash": @YES,
                                  @"superclass": @YES,
                                  @"description": @YES,
                                  @"debugDescription": @YES,
                                  };
    }
    
    return _excludePropertyNames;
}

@end
