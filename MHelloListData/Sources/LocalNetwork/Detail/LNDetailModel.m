//
//  LNDetailModel.m
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/8/21.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import "LNDetailModel.h"
#import "HTMLRequestManager.h"
#import "LNRequest.h"

@interface LNDetailModel ()
@property (nonatomic) LNRequest *request;
@property (nonatomic) BOOL isFetching;
@end

@implementation LNDetailModel

- (void)fetchWithOwnerName:(NSString *)ownerName repoName:(NSString *)repoName {
    NSLog(@"【chenms】  %s", __func__);
    [self cancel];
    
    self.isFetching = YES;
    
    __weak typeof(self) weakSelf = self;
    self.request = [[HTMLRequestManager sharedInstance] GET:[self urlStringWithOwnerName:ownerName repoName:repoName]
                                               parameters:nil
                                                 progress:nil
                                                  success:^(LNRequest *request, LNReturnData *returnData) {
                                                      id data = [weakSelf dataWithResponseData:returnData.responseData];
                                                      returnData.data = data;
                                                      if (returnData.responseData
                                                          && (!returnData.data || ![returnData.data isKindOfClass:[NSString class]])) {
                                                          returnData.code = LNReturnDataCodeRequestDataFail;
                                                          [weakSelf onModelRequestDidFail];
                                                          
                                                          return;
                                                      }
                                                      
                                                      self.detailHTML = returnData.data;
                                                      weakSelf.isFetching = NO;
                        
                                                      if (weakSelf.onModelRequestDidFinishBlock) {
                                                          weakSelf.onModelRequestDidFinishBlock(weakSelf);
                                                      }
                                                  }
                                                  failure:^(LNRequest *request, LNReturnData *returnData) {
                                                      NSLog(@"【chenms】  %s", __func__);
                                                      [weakSelf onModelRequestDidFail];
                                                  }];
    [self.request resume];
}

- (NSString *)urlStringWithOwnerName:(NSString *)ownerName repoName:(NSString *)repoName {
    return [NSString stringWithFormat:@"repos/%@/%@/readme", ownerName, repoName];
}

- (id)dataWithResponseData:(id)responseData {
    if (![responseData isKindOfClass:[NSData class]]) {
        return nil;
    }
    NSString *html = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    return html;
}

- (void)onModelRequestDidFail {
    self.isFetching = NO;
    if (self.onModelRequestDidFailBlock) {
        self.onModelRequestDidFailBlock(self);
    }
}

#pragma mark - Life Cycle
- (void)cancel {
    [self.request cancel];
}

@end
