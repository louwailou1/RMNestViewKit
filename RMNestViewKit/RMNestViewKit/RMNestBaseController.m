//
//  RMNestBaseController.m
//  RMNestScrollview
//
//  Created by RMNestViewKit on 2018/1/5.
//  Copyright © 2018年 RMNestViewKit. All rights reserved.
//

#import "RMNestBaseController.h"
#import "UIScrollView+RMRefresh.h"
#import "RMRefreshHeader.h"

@interface RMNestBaseController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong, readwrite) RMNestTableView *tableView;

@end

@implementation RMNestBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = [NSString stringWithFormat:@"%@cellId", NSStringFromClass(self.class)];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.backgroundColor = [UIColor colorWithWhite:0.998 alpha:1];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    return cell;
}
    
    
- (void)viewWillDisappear:(BOOL)animated {
    self.isPushing = YES;
}

    
- (void)viewDidDisappear:(BOOL)animated {
    self.isPushing = NO;
}
    
- (RMNestTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[RMNestTableView alloc] initWithFrame:self.view.bounds];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.backgroundColor = [UIColor colorWithWhite:0.998 alpha:1];
        _tableView.tableFooterView = [[UIView alloc]init];
        
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        
        // 创建一个假的headerView，高度等于headerView的高度
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectZero];
        _tableView.tableHeaderView = headerView;
        
    }
    return _tableView;
}

- (void)refreshHandle {
    
}
- (void)endRefreshing {
    [self.noUseScrollview.header endRefreshing];
}

@end
