//
//  RMNestScrollview.h
//  RMNestScrollview
//
//  Created by RMNestViewKit on 2018/1/5.
//  Copyright © 2018年 RMNestViewKit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMNestBaseController.h"

@interface RMNestScrollview : UIView

+ (instancetype)nestScrollviewWithTitleArr:(NSArray<NSString*> *)titleArr
                                  SubVCArr:(NSArray<RMNestBaseController *> *)subVCArr
                                  Frame:(CGRect)frame;

+ (instancetype)nestScrollviewWithTitleArr:(NSArray<NSString*> *)titleArr
                                  SubVCArr:(NSArray<RMNestBaseController *> *)subVCArr
                                     Frame:(CGRect)frame
                             CustomNavView:(UIView *)customNavView;

@property (nonatomic, strong, readonly) UIView *headView;

@property (nonatomic, assign) CGFloat headViewH;
@property (nonatomic, assign) CGFloat titleViewH;
@property (nonatomic, assign) CGFloat sliderW;
@property (nonatomic, assign) CGFloat sliderH;

@property (nonatomic, strong) UIColor *titleViewBgColor;
@property (nonatomic, strong) UIColor *titleViewButtonColor;
@property (nonatomic, assign) CGFloat titleViewButtonWidth;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *titleColorNormal;
@property (nonatomic, strong) UIColor *titleColorSelected;
@property (nonatomic, strong) UIColor *sliderColor;
    
- (void)removeTwoLinesFromSuperView;

@property (nonatomic, assign, readonly) NSInteger currentIndex; // 当前显示的tablview

@end
