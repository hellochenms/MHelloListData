//
//  LocalNetworkViewController.m
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/7/31.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import "LocalNetworkViewController.h"
#import "LNListModel.h"
#import "OCStarListModel.h"
#import "LNDetailModel.h"

@interface LocalNetworkViewController ()
@property (nonatomic) UIButton *refreshButton;
@property (nonatomic) UIButton *tryRefreshButton;
@property (nonatomic) UIButton *loadMoreButton;
@property (nonatomic) UIButton *refreshDetailButton;
@property (nonatomic) OCStarListModel *model;
@property (nonatomic) LNDetailModel *detailModel;
@property (nonatomic) UIActivityIndicatorView *loadingView;
@end

@implementation LocalNetworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.refreshButton];
    [self.view addSubview:self.tryRefreshButton];
    [self.view addSubview:self.loadMoreButton];
    [self.view addSubview:self.refreshDetailButton];
    [self.view addSubview:self.loadingView];
}

#pragma mark - Life Cycle
- (void)viewDidLayoutSubviews {
    double margin = 20;
    double buttonWidth = CGRectGetWidth(self.view.bounds) - margin * 2;
    double buttonHeight = 60;
    self.refreshButton.frame = CGRectMake(margin, 64 + margin, buttonWidth, buttonHeight);
    self.tryRefreshButton.frame = CGRectMake(margin, CGRectGetMaxY(self.refreshButton.frame) + margin, buttonWidth, buttonHeight);
    self.loadMoreButton.frame = CGRectMake(margin, CGRectGetMaxY(self.tryRefreshButton.frame) + margin, buttonWidth, buttonHeight);
    self.refreshDetailButton.frame = CGRectMake(margin, CGRectGetMaxY(self.loadMoreButton.frame) + margin, buttonWidth, buttonHeight);
    self.loadingView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
}

#pragma mark - Event
- (void)onTapRefresh {
    if (self.model.isFetching) {
        NSLog(@"【chenms】self.model.isFetching:%d  %s", self.model.isFetching, __func__);
        return;
    }
    [self.model refresh];
    [self startLoadingUI];
}

- (void)onTapTryRefreshButton {
    if (self.model.isFetching) {
        NSLog(@"【chenms】self.model.isFetching:%d  %s", self.model.isFetching, __func__);
        return;
    }
    if ([self.model needRefresh]) {
        [self.model refresh];
        [self startLoadingUI];
    }
}

- (void)onTapLoadMore {
    if (self.model.isFetching) {
        NSLog(@"【chenms】self.model.isFetching:%d  %s", self.model.isFetching, __func__);
        return;
    }
    [self.model loadMore];
    [self startLoadingUI];
}

- (void)onTapRefreshDetail {
    if (self.detailModel.isFetching) {
        NSLog(@"【chenms】self.model.isFetching:%d  %s", self.model.isFetching, __func__);
        return;
    }
    [self.detailModel fetchWithOwnerName:@"AFNetworking" repoName:@"AFNetworking"];
    [self startLoadingUI];
}

#pragma mark - Loading UI
- (void)startLoadingUI {
    [self.loadingView startAnimating];
}

- (void)stopLoadingUI {
    [self.loadingView stopAnimating];
}

#pragma mark - Getter
-(UIButton *)refreshButton{
    if(!_refreshButton){
        _refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _refreshButton.backgroundColor = [UIColor brownColor];
        [_refreshButton setTitle:@"refresh" forState:UIControlStateNormal];
        [_refreshButton addTarget:self action:@selector(onTapRefresh) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _refreshButton;
}

-(UIButton *)tryRefreshButton{
    if(!_tryRefreshButton){
        _tryRefreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _tryRefreshButton.backgroundColor = [UIColor brownColor];
        [_tryRefreshButton setTitle:@"tryRefreshButton" forState:UIControlStateNormal];
        [_tryRefreshButton addTarget:self action:@selector(onTapTryRefreshButton) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _tryRefreshButton;
}

-(UIButton *)loadMoreButton{
    if(!_loadMoreButton){
        _loadMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _loadMoreButton.backgroundColor = [UIColor brownColor];
        [_loadMoreButton setTitle:@"loadMore" forState:UIControlStateNormal];
        [_loadMoreButton addTarget:self action:@selector(onTapLoadMore) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _loadMoreButton;
}

-(UIButton *)refreshDetailButton{
    if(!_refreshDetailButton){
        _refreshDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _refreshDetailButton.backgroundColor = [UIColor brownColor];
        [_refreshDetailButton setTitle:@"refresh-detail" forState:UIControlStateNormal];
        [_refreshDetailButton addTarget:self action:@selector(onTapRefreshDetail) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _refreshDetailButton;
}

- (UIActivityIndicatorView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    return _loadingView;
}

-(OCStarListModel *)model{
    if(!_model){
        _model = [[OCStarListModel alloc] init];
        __weak typeof(self) weakSelf = self;
        _model.onModelDidFetchDataFromCacheBlock = ^(LNListModel *model, BOOL isRequesting) {
            NSLog(@"【chenms】model.datas:%@  %s", model.datas, __func__);
            if (!isRequesting) {
                [weakSelf stopLoadingUI];
            }
        };
        _model.onModelRequestDidFinishBlock = ^(LNListModel *model) {
            NSLog(@"【chenms】model.datas:%@  %s", model.datas, __func__);
            [weakSelf stopLoadingUI];
        };
        _model.onModelRequestDidFailBlock = ^(LNListModel *model) {
            NSLog(@"【chenms】  %s", __func__);
            [weakSelf stopLoadingUI];
        };
    }
    
    return _model;
}

-(LNDetailModel *)detailModel {
    if(!_detailModel){
        _detailModel = [[LNDetailModel alloc] init];
        __weak typeof(self) weakSelf = self;
        _detailModel.onModelRequestDidFinishBlock = ^(LNDetailModel *model) {
            NSLog(@"【chenms】model.datas:%@  %s", model.detailHTML, __func__);
            [weakSelf stopLoadingUI];
        };
        _detailModel.onModelRequestDidFailBlock = ^(LNDetailModel *model) {
            NSLog(@"【chenms】  %s", __func__);
            [weakSelf stopLoadingUI];
        };
    }
    
    return _detailModel;
}

@end
