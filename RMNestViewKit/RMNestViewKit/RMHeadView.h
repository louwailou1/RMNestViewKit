//
//  RMNestScrollview.h
//  RMNestScrollview
//
//  Created by RMNestViewKit on 2018/1/5.
//  Copyright © 2018年 RMNestViewKit. All rights reserved.
//

// 关于这里我为什么要用UIScrollView呢？解释：假如使用UIView，其subViews中的类似于UIButton控件则不响应UIView中添加的tableView.panGestureRecognizer手势，但是我仔细一想，为什么tableview中的cell或者说header为什么中添加了UIButton，为什么触摸到button却可以响应pan手势呢，所以肯定是苹果内部做了处理，那么我就遵循苹果的规则，讲UIView替换成UIScrollView，让苹果帮我处理这个问题，对吧？

#import <UIKit/UIKit.h>
#import "RMNestBaseController.h"
@interface RMHeadView : UIScrollView

@property (nonatomic, strong) NSArray<RMNestBaseController *> *subVCArr;

@property (nonatomic, assign) NSInteger currentIndex; // 当前显示的tablview

- (void)changeY:(CGFloat)y ;

@end
