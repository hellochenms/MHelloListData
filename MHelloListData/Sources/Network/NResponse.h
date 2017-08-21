//
//  NResponse.h
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/7/31.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, NResponseCode) {
    NResponseCodeUnknown = -1,
    NResponseCodeOK = 0,
    NResponseCodeNetworkDisabled = 1025,
};

@interface NResponse : NSObject
@property (nonatomic) NResponseCode code;
@property (nonatomic) id data;
@end
