//
//  RMRefreshHeader.h
//  CircleProgressView
//
//  Created by RMNestViewKit on 16/7/5.
//  Copyright © 2016年 RMNestViewKit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScrollView+RMRefresh.h"
#import "RMNestBaseController.h"

@interface RMRefreshHeader : UIView

UIKIT_EXTERN const CGFloat RMRefreshHeaderHeight;
UIKIT_EXTERN const CGFloat SURefreshPointRadius;

@property (nonatomic, copy) void(^handle)(void);

#pragma mark - 停止动画
- (void)endRefreshing;

@property (nonatomic, strong) NSArray<RMNestBaseController *> *subVCArr;
@property (nonatomic, weak ) UIScrollView * scrollView; //  当前正在滑动的scrollview

@end
