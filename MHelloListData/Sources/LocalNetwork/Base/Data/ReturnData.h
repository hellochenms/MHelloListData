//
//  ReturnData.m
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/7/31.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DataToObjectProtocol;

typedef NS_ENUM(NSInteger, ReturnDataCode) {
    ReturnDataCodeErrorUnknown = -1,
    ReturnDataCodeRequestOK = 0,
    ReturnDataCodeLocalOK = 1000,
    ReturnDataCodeLocalOKRequesting = 1001,
    ReturnDataCodeNetworkDisable = 2000,
    ReturnDataCodeRequestDataFail = 2001,
};

@interface ReturnData : NSObject
@property (nonatomic) ReturnDataCode code;
@property (nonatomic) id responseData;
@property (nonatomic) id data;
@property (nonatomic) NSError *error;
@end

@protocol DataToObjectProtocol <NSObject>
+ (id)objectFromData:(NSDictionary *)dict;
@end
