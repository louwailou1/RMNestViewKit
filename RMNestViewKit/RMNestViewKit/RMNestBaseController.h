//
//  RMNestBaseController.h
//  RMNestScrollview
//
//  Created by RMNestViewKit on 2018/1/5.
//  Copyright © 2018年 RMNestViewKit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMNestTableView.h"

@interface RMNestBaseController : UIViewController

@property (nonatomic, strong, readonly) RMNestTableView *tableView;
@property (nonatomic, weak) UIScrollView *noUseScrollview;
@property (nonatomic, assign) BOOL isPushing;

// 下拉刷新处理事件
- (void)refreshHandle;
// 结束下拉刷新
- (void)endRefreshing;

@end
