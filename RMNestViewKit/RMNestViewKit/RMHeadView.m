//
//  RMHeadView.m
//  RMNestScrollview
//
//  Created by RMNestViewKit on 2018/1/5.
//  Copyright © 2018年 RMNestViewKit. All rights reserved.
//

#import "RMHeadView.h"
#import <objc/runtime.h>

@interface RMHeadView ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIPanGestureRecognizer *pan;

@end

@implementation RMHeadView

- (void)changeY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

// 当点击到heaview时，将子控制器的tableview手势传递给headview
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    RMNestBaseController *vc = _subVCArr[_currentIndex];
    [self addGestureRecognizer:vc.tableView.panGestureRecognizer];
    return view;
}

@end
