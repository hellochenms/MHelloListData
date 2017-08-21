//
//  LNReturnData.m
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/7/31.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LNDataToObjectProtocol;

typedef NS_ENUM(NSInteger, LNReturnDataCode) {
    LNReturnDataCodeErrorUnknown = -1,
    LNReturnDataCodeRequestOK = 0,
    LNReturnDataCodeLocalOK = 1000,
    LNReturnDataCodeLocalOKRequesting = 1001,
    LNReturnDataCodeNetworkDisable = 2000,
    LNReturnDataCodeRequestDataFail = 2001,
};

@interface LNReturnData : NSObject
@property (nonatomic) LNReturnDataCode code;
@property (nonatomic) id responseData;
@property (nonatomic) id data;
@property (nonatomic) NSError *error;
@end

@protocol LNDataToObjectProtocol <NSObject>
+ (id)objectFromData:(NSDictionary *)dict;
@end
