//
//  NetworkViewController.m
//  MHelloListData
//
//  Created by Chen,Meisong on 2017/7/31.
//  Copyright © 2017年 hellochenms. All rights reserved.
//

#import "NetworkViewController.h"
#import "NModel.h"

@interface NetworkViewController ()
@property (nonatomic) UIButton *refreshButton;
@property (nonatomic) UIButton *loadMoreButton;
@property (nonatomic) NModel *model;
@end

@implementation NetworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.refreshButton];
    [self.view addSubview:self.loadMoreButton];
}

#pragma mark - Life Cycle
- (void)viewDidLayoutSubviews {
    double margin = 20;
    double buttonWidth = CGRectGetWidth(self.view.bounds) - margin * 2;
    double buttonHeight = 60;
    self.refreshButton.frame = CGRectMake(margin, 64 + margin, buttonWidth, buttonHeight);
    self.loadMoreButton.frame = CGRectMake(margin, CGRectGetMaxY(self.refreshButton.frame) + margin, buttonWidth, buttonHeight);
}

#pragma mark - Event
- (void)onTapRefresh {
    [self.model refresh];
}

- (void)onTapLoadMore {
    [self.model loadMore];
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

-(UIButton *)loadMoreButton{
    if(!_loadMoreButton){
        _loadMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _loadMoreButton.backgroundColor = [UIColor brownColor];
        [_loadMoreButton setTitle:@"loadMore" forState:UIControlStateNormal];
        [_loadMoreButton addTarget:self action:@selector(onTapLoadMore) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _loadMoreButton;
}

-(NModel *)model{
    if(!_model){
        _model = [[NModel alloc] init];
    }
    
    return _model;
}

@end
