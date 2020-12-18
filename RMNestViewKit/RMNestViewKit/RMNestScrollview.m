//
//  RMNestScrollview.m
//  RMNestScrollview
//
//  Created by RMNestViewKit on 2018/1/5.
//  Copyright © 2018年 RMNestViewKit. All rights reserved.
//

#import "RMNestScrollview.h"
#import "RMSegmentedControl.h"
#import "RMBaseScrollview.h"
#import "RMHeadView.h"
#import "RMRefreshHeader.h"

#define selfW self.bounds.size.width
#define selfH self.bounds.size.height
// 三个数中最大一个
#define MAXValue(a,b,c) (a>b?(a>c?a:c):(b>c?b:c))
// rgb
#define WZBColor(r, g, b) [UIColor colorWithRed:(r) / 255.0f green:(g) / 255.0f blue:(b) / 255.0f alpha:1.0]

#define iPhoneX ([UIScreen mainScreen].bounds.size.height == 812 || [UIScreen mainScreen].bounds.size.height == 896 || [UIScreen mainScreen].bounds.size.height == 832)

@interface RMNestScrollview ()<UIScrollViewDelegate>

@property (nonatomic, strong) RMSegmentedControl *titleView;
@property (nonatomic, strong) RMHeadView *contentHeadView;
@property (nonatomic, strong) RMBaseScrollview *contentScrollview;

@property (nonatomic, strong) NSArray<NSString*> *titleArr;
@property (nonatomic, strong) NSArray<RMNestBaseController *> *subVCArr;

@property (nonatomic, assign) CGFloat contentHeadViewH;
@property (nonatomic, assign, readwrite) NSInteger currentIndex; // 当前显示的tablview

@property (nonatomic, assign) BOOL isCustomNavBar;
@property (nonatomic, strong) UIView *customNavView;

@end

@implementation RMNestScrollview

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _headViewH              = 150;
        _titleViewH             = 45;
        _sliderH                = 1;
        _sliderW                = 0;
        _contentHeadViewH       = _headViewH + _titleViewH;
        
        _titleFont              = [UIFont systemFontOfSize:15.f];
        _titleColorNormal       = [UIColor blackColor];
        _titleColorSelected     = [UIColor redColor];
        _sliderColor            =_titleColorSelected;
        
    }
    return self;
}

+ (instancetype)nestScrollviewWithTitleArr:(NSArray<NSString*> *)titleArr
                                  SubVCArr:(NSArray<RMNestBaseController *> *)subVCArr
                                  Frame:(CGRect)frame {
    if (!titleArr || !subVCArr) {
        NSException *exception = [[NSException alloc] initWithName:@"titleArr or subVCArr is nil" reason:@"标题数组和控制器数组不能为空" userInfo:nil];
        @throw exception;
    }
    if (titleArr.count != subVCArr.count) {
        NSException *exception = [[NSException alloc] initWithName:@"titleArr.count != subVCArr.count" reason:@"标题数组和控制器数组的内容数量不一致" userInfo:nil];
        @throw exception;
    }
    
    RMNestScrollview *nestView = [[RMNestScrollview alloc] initWithFrame:frame];
    nestView.titleArr   = titleArr;
    nestView.subVCArr   = subVCArr;
    [nestView setup];
    return nestView;
}

+ (instancetype)nestScrollviewWithTitleArr:(NSArray<NSString*> *)titleArr
                                  SubVCArr:(NSArray<RMNestBaseController *> *)subVCArr
                                     Frame:(CGRect)frame
                             CustomNavView:(UIView *)customNavView {
    RMNestScrollview *nestView = [self nestScrollviewWithTitleArr:titleArr SubVCArr:subVCArr Frame:frame];
    nestView.isCustomNavBar = YES;
    nestView.customNavView = customNavView;
    [nestView addSubview:customNavView];
    customNavView.alpha = 0;
    return nestView;
}


- (void)setup {
    // 容器
    [self addSubview:self.contentScrollview];
    // 子控制器
    [self setupChildVc];
    // 头部
    [self addSubview:self.contentHeadView];
    // 标题视图
    [self.contentHeadView addSubview:self.titleView];
    
//    __weak RMNestScrollview *weakSelf = self;
//    [self.contentScrollview addRefreshHeaderWithHandle:^{
//        for (RMNestBaseController *vc in weakSelf.subVCArr) {
//            [vc refreshHandle];
//        }
//    }];
    [self.contentHeadView addSubview:self.contentScrollview.header];
    self.contentScrollview.header.subVCArr = _subVCArr;
    self.contentScrollview.header.scrollView = _subVCArr.firstObject.tableView;
    for (RMNestBaseController *vc in _subVCArr) {
        [vc.tableView addObserver:self.contentScrollview.header forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        vc.noUseScrollview = self.contentScrollview;
    }
}

#pragma mark - private methods
// 刷新最大OffsetY，让三个tableView同步
- (void)reloadMaxOffsetY {
    
    // 计算出最大偏移量
    CGFloat maxOffsetY = 0;
    for (RMNestBaseController *vc in _subVCArr) {
        if (vc.tableView.contentOffset.y > maxOffsetY) {
            maxOffsetY = vc.tableView.contentOffset.y;
        }
    }
    
    CGFloat compareValue = _headViewH;
    if (_isCustomNavBar) {
        compareValue -= (iPhoneX ? 88:64);
    }

    // 如果最大偏移量大于headViewH，那么其余的tableview都应该自动滑到顶
    if (maxOffsetY >= compareValue) {
        for (RMNestBaseController *vc in _subVCArr) {
            if (vc.tableView.contentOffset.y < compareValue) {
                vc.tableView.contentOffset = CGPointMake(0, compareValue);
            }
        }
    }
}

- (void)setupChildVc {
    NSUInteger index = 0;
    for (RMNestBaseController *vc in _subVCArr) {
        [self.contentScrollview addSubview:vc.view];
        vc.view.frame = CGRectMake(index*selfW, 0, selfW, selfH);
        
//        vc.tableView.tableHeaderView.frame = CGRectMake(0, 0, selfW, _headViewH+_titleViewH);
        
        // 适配ios9.0
        UIView *view = vc.tableView.tableHeaderView;
        view.frame = CGRectMake(0, 0, selfW, _headViewH+_titleViewH);
        vc.tableView.tableHeaderView = view;
        
        index ++;
    }
    index = 0;
    for (RMNestBaseController *vc in _subVCArr) {
//        __weak RMNestScrollview *weakSelf = self;
//        vc.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//            weakSelf.contentScrollview.scrollEnabled = NO;
//            weakSelf.titleView.userInteractionEnabled = NO;
//        }];
//        [vc.tableView.mj_header endRefreshingWithCompletionBlock:^{
//            weakSelf.contentScrollview.scrollEnabled = YES;
//            weakSelf.titleView.userInteractionEnabled = YES;
//        }];
        // 监听tableView的contentOffset变化
        [vc.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionInitial context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    
    if ([keyPath isEqualToString:@"contentOffset"]) {
        UITableView *tableView = object;
        CGFloat contentOffsetY = tableView.contentOffset.y;
        
        for (RMNestBaseController *vc in _subVCArr) {
            if (vc.isPushing == YES && contentOffsetY > 0) {//防止自动偏移以及headview位移
                return;
            }
        }
        
        // 有点tableivew的cell不够，contentInset来凑
        if (tableView.contentSize.height < selfH+_contentHeadViewH) {
            UIEdgeInsets insets = tableView.contentInset;
            insets.bottom = selfH+_contentHeadViewH-tableView.contentSize.height+iPhoneX;
            tableView.contentInset = insets;
        }else {
            UIEdgeInsets insets = tableView.contentInset;
            insets.bottom = 0;
            tableView.contentInset = insets;
        }
        
        CGFloat compareValue = _headViewH;
        if (_isCustomNavBar) {
            compareValue -= (iPhoneX ? 88:64);
        }
        
        // 如果滑动没有超过headViewH
        if (contentOffsetY < compareValue) {
            // 让这三个tableView的偏移量相等
            for (RMNestBaseController *vc in _subVCArr) {
                if (vc.tableView.contentOffset.y != tableView.contentOffset.y) {
                    vc.tableView.contentOffset = tableView.contentOffset;
                }
            }
            CGFloat headerY = -tableView.contentOffset.y;// 上正下负
            
            // 改变headerView的y值
            [self.contentHeadView changeY:headerY];
//            CGRect titleViewframe = self.titleView.frame;
//            titleViewframe.origin.y = headerY + _headViewH;
//            self.titleView.frame = titleViewframe;
            
            if (_isCustomNavBar) {
                _customNavView.alpha = contentOffsetY/compareValue;
            }
            
            // 一旦大于等于headViewH了，让headerView的y值等于-headViewH，就停留在上边了
        } else if (contentOffsetY >= compareValue) {
            
            if (_isCustomNavBar) {
                _customNavView.alpha = 1;
            }
            // headView停留
            [self.contentHeadView changeY:-compareValue];

            // titleView停留
//            CGRect titleViewframe = self.titleView.frame;
//            titleViewframe.origin.y = 0;
//            self.titleView.frame = titleViewframe;
            
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.contentScrollview) {
        // 改变segmentdControl
        if (_titleViewButtonWidth > 0) {
            [self.titleView setContentOffset:(CGPoint){scrollView.contentOffset.x * _titleViewButtonWidth/self.titleView.frame.size.width, 0}];
        }else {
            [self.titleView setContentOffset:(CGPoint){scrollView.contentOffset.x / _titleArr.count, 0}];
        }
        self.contentScrollview.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
    }
//    for (RMNestBaseController *vc in _subVCArr) {
//        [vc.tableView addGestureRecognizer:vc.tableView.panGestureRecognizer];
//        break;
//    }
    // 接下来的做法可以利用- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event或者别的方法来判断手势是否触摸到headview上，接着[self.contentHeadView addGestureRecognizer:vc.tableView.panGestureRecognizer];，手势动作结束就[vc.tableView addGestureRecognizer:vc.tableView.panGestureRecognizer];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = (NSInteger)fabs(scrollView.contentOffset.x / selfW);
    self.contentHeadView.currentIndex = index;
    self.contentScrollview.header.scrollView = _subVCArr[index].tableView;
    
}

// 开始拖拽
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // 刷新最大OffsetY
    [self reloadMaxOffsetY];
}

#pragma mark - setters and getters
- (RMBaseScrollview *)contentScrollview {
    if (_contentScrollview == nil) {
        _contentScrollview = [[RMBaseScrollview alloc] initWithFrame:self.bounds];
        _contentScrollview.backgroundColor = [UIColor clearColor];
        _contentScrollview.delegate = self;
        _contentScrollview.pagingEnabled = YES;
        _contentScrollview.showsHorizontalScrollIndicator = NO;
        _contentScrollview.contentSize = CGSizeMake(self.bounds.size.width*_titleArr.count, 0);
    }
    return  _contentScrollview;
}

- (RMHeadView *)contentHeadView {
    if (_contentHeadView == nil) {
        _contentHeadView = [[RMHeadView alloc] initWithFrame:CGRectMake(0, 0, selfW, _contentHeadViewH)];
        _contentHeadView.backgroundColor = [UIColor colorWithWhite:0.998 alpha:1];
        _contentHeadView.subVCArr = self.subVCArr;
        _contentHeadView.currentIndex = 0;
        _contentHeadView.clipsToBounds = NO;
    }
    return _contentHeadView;
}

- (RMSegmentedControl *)titleView {
    if (_titleView == nil) {
        __weak RMNestScrollview *weakSelf = self;
        _titleView = [RMSegmentedControl segmentWithFrame:(CGRect){0, _headViewH, selfW, _titleViewH} titles:_titleArr tClick:^(NSInteger index) {
            // 改变scrollView的contentOffset
            weakSelf.contentScrollview.contentOffset = CGPointMake(index * selfW, 0);
            weakSelf.contentScrollview.header.scrollView = weakSelf.subVCArr[index].tableView;
            // 刷新最大OffsetY
            [weakSelf reloadMaxOffsetY];
            weakSelf.currentIndex = index;
            weakSelf.contentHeadView.currentIndex = index;
        }];
        if (_titleViewBgColor != nil) {
            _titleView.backgroundColor = _titleViewBgColor;
        }else {
            _titleView.backgroundColor = [UIColor colorWithWhite:0.998 alpha:1];
        }
        // 设置其他颜色
        [_titleView setNormalColor:[UIColor blackColor] selectColor:[UIColor redColor] sliderColor:[UIColor redColor] edgingColor:[UIColor clearColor] edgingWidth:0];
        
        // 去除圆角
        _titleView.layer.cornerRadius = _titleView.backgroundView.layer.cornerRadius = .0f;
        
        // 调下滑块的frame
        _titleView.sliderHeight = _sliderH;
    }
    return _titleView;
}


- (void)setHeadViewH:(CGFloat)headViewH {
    _headViewH = headViewH;
    _contentHeadViewH = _headViewH + _titleViewH;
    
    CGRect frame = self.contentHeadView.frame;
    frame.size.height = _contentHeadViewH;
    self.contentHeadView.frame = frame;
    
    frame.origin.y = _headViewH;
    frame.size.height = _titleViewH;
    self.titleView.frame = frame;  
    
    for (RMNestBaseController *vc in _subVCArr) {
//        vc.tableView.tableHeaderView.frame = CGRectMake(0, 0, selfW, _contentHeadViewH);
        
        // 适配ios9.0
        UIView *view = vc.tableView.tableHeaderView;
        view.frame = CGRectMake(0, 0, selfW, _contentHeadViewH);
        vc.tableView.tableHeaderView = view;
    }
}

- (void)setTitleViewH:(CGFloat)titleViewH {
    _titleViewH = titleViewH;
    _contentHeadViewH = _headViewH + _titleViewH;
    
    CGRect frame = self.contentHeadView.frame;
    frame.size.height = _contentHeadViewH;
    self.contentHeadView.frame = frame;
    
    frame.origin.y = _headViewH;
    frame.size.height = _titleViewH;
    self.titleView.frame = frame;
    
    for (RMNestBaseController *vc in _subVCArr) {
//        vc.tableView.tableHeaderView.frame = CGRectMake(0, 0, selfW, _contentHeadViewH);
        
        // 适配ios9.0
        UIView *view = vc.tableView.tableHeaderView;
        view.frame = CGRectMake(0, 0, selfW, _contentHeadViewH);
        vc.tableView.tableHeaderView = view;
    }
}

- (void)setSliderW:(CGFloat)sliderW {
    _sliderW = sliderW;
    self.titleView.sliderWidth = _sliderW;
}

- (void)setSliderH:(CGFloat)sliderH {
    _sliderH = sliderH;
    self.titleView.sliderHeight = _sliderH;
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    self.titleView.titleFont = _titleFont;
}

- (void)setTitleColorNormal:(UIColor *)titleColorNormal {
    _titleColorNormal = titleColorNormal;
    self.titleView.normalColor = _titleColorNormal;
}

- (void)setTitleColorSelected:(UIColor *)titleColorSelected {
    _titleColorSelected = titleColorSelected;
    self.titleView.selectColor = _titleColorSelected;
}

- (void)setSliderColor:(UIColor *)sliderColor {
    _sliderColor = sliderColor;
    self.titleView.sliderColor = _sliderColor;
}

- (void)setTitleViewBgColor:(UIColor *)titleViewBgColor {
    _titleViewBgColor = titleViewBgColor;
    self.titleView.backgroundColor = titleViewBgColor;
//    self.titleView.buttonBgColor = titleViewBgColor;
}
    
- (void)setTitleViewButtonColor:(UIColor *)titleViewButtonColor {
    _titleViewButtonColor = titleViewButtonColor;
    self.titleView.buttonBgColor = titleViewButtonColor;
}

- (void)setTitleViewButtonWidth:(CGFloat)titleViewButtonWidth {
    _titleViewButtonWidth = titleViewButtonWidth;
    self.titleView.buttonWidth = titleViewButtonWidth;
}

- (UIView *)headView {
    return self.contentHeadView;
}
    
- (void)removeTwoLinesFromSuperView {
    [self.titleView removeTwoLinesFromSuperView];
}

@end
