//
//  RMSegmentedControl.m
//  RMSegmentedControl
//
//  Created by RMNestViewKit on 2016/11/8.
//  Copyright © 2016年 RMNestViewKit. All rights reserved.
//

#import "RMSegmentedControl.h"

#define WZBButtonTag 9999
// view圆角
#define ViewBorderRadius(View, Radius, Width, Color)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES];\
[View.layer setBorderWidth:(Width)];\
[View.layer setBorderColor:[Color CGColor]]

// rgb
#define WZBColor(r, g, b) [UIColor colorWithRed:(r) / 255.0f green:(g) / 255.0f blue:(b) / 255.0f alpha:1.0]

// 根据颜色拿到RGB数值
void getRGBValue(CGFloat colorArr[3], UIColor *color) {
    unsigned char data[4];
    // 宽,高,内存中像素的每个组件的位数（RGB应该为32）,bitmap的每一行在内存所占的比特数
    size_t width = 1, height = 1, bitsPerComponent = 8, bytesPerRow = 4;
    // bitmap上下文使用的颜色空间
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    // 指定bitmap是否包含alpha通道
    uint32_t bitmapInfo = 1;
    // 创建一个位图上下文。当你向上下文中绘制信息时，Quartz把你要绘制的信息作为位图数据绘制到指定的内存块。一个新的位图上下文的像素格式由三个参数决定：每个组件的位数，颜色空间，alpha选项。alpha值决定了绘制像素的透明性
    CGContextRef context = CGBitmapContextCreate(&data, width, height, bitsPerComponent, bytesPerRow, space, bitmapInfo);
    // 设置当前上下文中填充颜色
    CGContextSetFillColorWithColor(context, [color CGColor]);
    // 在此区域内填入当前填充颜色
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextRelease(context);
    CGColorSpaceRelease(space);
    for (NSInteger i = 0; i < 3; i++) {
        colorArr[i] = data[i];
    }
}

@interface RMSegmentedControl ()
// 所有button
@property (nonatomic, strong) NSMutableArray *allButtons;
// 上一次选中的下标
@property (nonatomic, assign) NSInteger lastIndex;

@property (nonatomic, strong) NSMutableArray *twoLines;

@end

@implementation RMSegmentedControl {
    UIColor *_selectColor;
    UIColor *_sliderColor;
    UIColor *_normalColor;
}

#pragma mark - lazy -- 默认颜色
- (UIColor *)normalColor {
    if (!_normalColor) {
        _normalColor = [UIColor blackColor];
    }
    return _normalColor;
}

- (void)setNormalColor:(UIColor *)normalColor {
    _normalColor = normalColor;
    for (UIButton *button in self.allButtons) {
        [button setTitleColor:normalColor forState:UIControlStateNormal];
    }
}

- (UIColor *)selectColor {
    if (!_selectColor) {
        _selectColor = [UIColor redColor];
    }
    return _selectColor;
}

- (void)setSelectColor:(UIColor *)selectColor {
    _selectColor = selectColor;
    [_selectButton setTitleColor:selectColor forState:UIControlStateNormal];
}

- (void)setButtonBgColor:(UIColor *)buttonBgColor {
    _buttonBgColor = buttonBgColor;
    for (UIButton *button in self.allButtons) {
        [button setBackgroundColor:_buttonBgColor];
    }
    
}

- (void)setButtonWidth:(CGFloat)buttonWidth {
    if (buttonWidth > self.frame.size.width/self.allButtons.count) {return;}
    
    _buttonWidth = buttonWidth;
    
    _backgroundView.center = CGPointMake((self.frame.size.width - _buttonWidth*self.titles.count + _buttonWidth)/2, 0);
    _backgroundView.bounds = (CGRect){0, 0, _buttonWidth, _sliderHeight};
    
    NSInteger i = 0;
    
    CGFloat buttonFirstX = (self.frame.size.width - buttonWidth*self.allButtons.count)/2;
    
    for (UIButton *button in self.allButtons) {
        CGFloat x = i * buttonWidth + buttonFirstX;
        CGFloat y = 0;
        CGFloat w = buttonWidth;
        CGFloat h = self.frame.size.height;
        button.frame = CGRectMake(x, y, w, h);
        i++;
    }
    
}

- (UIColor *)sliderColor {
    if (!_sliderColor) {
        _sliderColor = [UIColor whiteColor];
    }
    return _sliderColor;
}

- (void)setSliderColor:(UIColor *)sliderColor {
    _sliderColor = sliderColor;
    _backgroundView.backgroundColor = sliderColor;
}

- (UIColor *)edgingColor {
    if (!_edgingColor) {
        _edgingColor = [UIColor whiteColor];
    }
    return _edgingColor;
}

- (NSMutableArray *)allButtons {
    if (!_allButtons) {
        _allButtons = [NSMutableArray array];
    }
    return _allButtons;
}

+ (instancetype)segmentWithFrame:(CGRect)frame titles:(NSArray *)titles tClick:(void(^)(NSInteger index))tClick {
    return [[self alloc] initWithFrame:frame titles:titles tClick:tClick];
}

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles tClick:(void(^)(NSInteger index))tClick {
    if (self = [super initWithFrame:frame]) {
        _titles = titles;
        self.tClick = tClick;
        // 设置其他基本属性
        [self setupBase];
    }
    return self;
}

/* 初始化方法，block回调中带有选中的button */
+ (instancetype)segmentWithFrame:(CGRect)frame titles:(NSArray *)titles titleClick:(void(^)(NSInteger index, UIButton *selectButton))titleClick {
    return [[self alloc] initWithFrame:frame titles:titles titleClick:titleClick];
}

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles titleClick:(void(^)(NSInteger index, UIButton *selectButton))titleClick {
    if (self = [super initWithFrame:frame]) {
        _titles = titles;
        self.titleClick = titleClick;
        // 设置其他基本属性
        [self setupBase];
    }
    return self;
}

- (void)layoutSubviews {
    for (UIButton *button in self.allButtons) {
        CGRect frame = button.frame;
        frame.size.height = self.frame.size.height;
        button.frame = frame;
    }
    CGRect bounds = self.backgroundView.bounds;
    CGPoint center = self.backgroundView.center;
    center.y = self.frame.size.height - bounds.size.height - 0.5 + bounds.size.height/2.0;
    self.backgroundView.center = center;
    
    NSInteger index = 0;
    for (UIView *line in self.twoLines) {
        line.frame = CGRectMake(0, (self.frame.size.height-0.5) * index, self.frame.size.width, 0.5);
        index ++;
    }
}

- (void)setupBackgroundView {
    UIView *backgroundView = [[UIView alloc] init];
    
    if (_buttonWidth > 0) {
        backgroundView.center = CGPointMake((self.frame.size.width - _buttonWidth*self.titles.count + _buttonWidth)/2, 0);
        backgroundView.bounds = (CGRect){0, 0, _buttonWidth, self.frame.size.height};
    }else {
        backgroundView.center = CGPointMake(self.frame.size.width / self.titles.count / 2.0, 0);
        backgroundView.bounds = (CGRect){0, 0, self.frame.size.width / self.titles.count, self.frame.size.height};
    }
    
    [self addSubview:backgroundView];
    backgroundView.backgroundColor = self.edgingColor;
    _backgroundView = backgroundView;
}

- (void)setupAllButton {
    NSInteger count = self.titles.count;
    for (NSInteger i = 0; i < count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:button];
        CGFloat x = i * self.frame.size.width / count;
        CGFloat y = 0;
        CGFloat w = self.frame.size.width / count;
        CGFloat h = self.frame.size.height;
        button.frame = CGRectMake(x, y, w, h);
        [button setTitle:self.titles[i] forState:UIControlStateNormal];
        [button setTitleColor:self.normalColor forState:UIControlStateNormal];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        button.backgroundColor = [UIColor clearColor];
        button.tag = WZBButtonTag + i;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [button setAdjustsImageWhenHighlighted:NO];
        // 添加到数组中
        [self.allButtons addObject:button];
    }
}

- (void)showTopBottomLine {
    if (self.twoLines.count == 2) {return;}
    // 加两条线
    for (NSInteger i = 0; i < 2; i++) {
        UIView *line = [UIView new];
        line.backgroundColor = WZBColor(228, 227, 230);
        line.frame = CGRectMake(0, (self.frame.size.height-0.5) * i, self.frame.size.width, 0.5);
        [self addSubview:line];
        [self.twoLines addObject:line];
    }
}

- (void)removeTopBottomLine {
    for (UIView *line in self.twoLines) {
        [line removeFromSuperview];
    }
}

- (void)setupBase {
    // 默认有1的边框
    self.edgingWidth = 1.0f;
    // 创建底部白色滑块
    [self setupBackgroundView];
    // 添加了两条线
    [self showTopBottomLine];
    // 创建所有按钮
    [self setupAllButton];
    // 先调一下这个方法，默认选择第一个按钮
    [self buttonClick:[self viewWithTag:WZBButtonTag]];
    // 监听这两个属性，因为它们有可能在外界被用户更改，而内部不知道，就会导致bug
    [self.layer addObserver:self forKeyPath:@"borderWidth" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self.layer addObserver:self forKeyPath:@"borderColor" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    // 设置圆角
    ViewBorderRadius(self, self.frame.size.height / 2, self.edgingWidth, self.edgingColor);
    ViewBorderRadius(self.backgroundView, self.frame.size.height / 2, 0, [UIColor clearColor]);
}

- (void)buttonClick:(UIButton *)button {
    [self.selectButton setTitleColor:self.normalColor forState:UIControlStateNormal];
    [button setTitleColor:self.selectColor forState:UIControlStateNormal];
    _selectButton = button;
    
    if (_buttonWidth > 0) {
        [self setContentOffset:(CGPoint){(button.tag - WZBButtonTag) * _buttonWidth, 0}];
    }else {
        [self setContentOffset:(CGPoint){(button.tag - WZBButtonTag) * (self.frame.size.width) / self.titles.count, 0}];
    }
    
    
    NSInteger selectIndex = button.tag - WZBButtonTag;
    // 调用代理和block
    if (self.titleClick) {
        self.titleClick(selectIndex, self.selectButton);
    }
    if (self.tClick) {
        self.tClick(selectIndex);
    }
    if ([self.delegate respondsToSelector:@selector(segmentedValueDidChange:selectIndex:)]) {
        [self.delegate segmentedValueDidChange:self selectIndex:selectIndex];
    }
    if ([self.delegate respondsToSelector:@selector(segmentedValueDidChange:selectIndex:fromeIndex:)]) {
        [self.delegate segmentedValueDidChange:self selectIndex:selectIndex fromeIndex:self.lastIndex];
    }
    if ([self.delegate respondsToSelector:@selector(segmentedValueDidChange:selectIndex:fromeIndex:selectButton:)]) {
        [self.delegate segmentedValueDidChange:self selectIndex:selectIndex fromeIndex:self.lastIndex selectButton:button];
    }
    if ([self.delegate respondsToSelector:@selector(segmentedValueDidChange:selectIndex:fromeIndex:selectButton:allButtons:)]) {
        [self.delegate segmentedValueDidChange:self selectIndex:selectIndex fromeIndex:self.lastIndex selectButton:button allButtons:self.allButtons];
    }
    // 给最后一个下标赋值
    self.lastIndex = selectIndex;
}

- (void)setNormalColor:(UIColor *)normalColor selectColor:(UIColor *)selectColor {
    self.normalColor = normalColor;
    self.selectColor = selectColor;
    [self setAllColors];
}

- (void)setAllColors {
    // 设置所有button的颜色
    for (NSInteger i = 0; i < self.titles.count; i++) {
        UIButton *button = [self viewWithTag:i + WZBButtonTag];
        [button setTitleColor:self.normalColor forState:UIControlStateNormal];
    }
    [self.selectButton setTitleColor:self.selectColor forState:UIControlStateNormal];
    // 设置滑块的颜色
    self.backgroundView.backgroundColor = self.sliderColor;
    // 设置边框颜色
    self.layer.borderColor = self.edgingColor.CGColor;
    self.layer.borderWidth = self.edgingWidth;
}

- (void)setContentOffset:(CGPoint)contentOffset {
    // 改变底部滑块的x值
    CGPoint center = self.backgroundView.center;
    if (_buttonWidth > 0) {
        center.x = contentOffset.x + (self.frame.size.width - _buttonWidth*self.titles.count + _buttonWidth)/2;
    }else {
        center.x = contentOffset.x + self.frame.size.width/self.titles.count/2.0;
    }
    
    self.backgroundView.center = center;
    // 找出要操作的两个button设置颜色
    NSMutableArray *buttonArr = [NSMutableArray array];
    for (UIButton *button in self.allButtons) {
        CGRect frame = self.backgroundView.frame;
        frame.size.width = button.frame.size.width;
        frame.origin.x -= (button.frame.size.width - self.backgroundView.frame.size.width)/2.0;
        CGFloat overLapWidth = CGRectIntersection(button.frame, frame).size.width;
//        CGFloat overLapWidth = CGRectIntersection(button.frame, self.backgroundView.frame).size.width;
        if (overLapWidth > 0) {
            [buttonArr addObject:button];
        }
    }
    
    // 切换的时候
    if (buttonArr.count > 1) {
        UIButton *leftButton = buttonArr.firstObject;
        UIButton *rightButton = buttonArr.lastObject;
        // 设置要渐变的两个button颜色
        [rightButton setTitleColor:WZBColor([self getRGBValueWithIndex:0 button:rightButton], [self getRGBValueWithIndex:1 button:rightButton], [self getRGBValueWithIndex:2 button:rightButton]) forState:UIControlStateNormal];
        [leftButton setTitleColor:WZBColor([self getRGBValueWithIndex:0 button:leftButton], [self getRGBValueWithIndex:1 button:leftButton], [self getRGBValueWithIndex:2 button:leftButton]) forState:UIControlStateNormal];
    }
    
    // 重新设置选中的button
    _selectButton = [self viewWithTag:(NSInteger)(WZBButtonTag + self.backgroundView.center.x / (self.frame.size.width / self.titles.count))];
}

// 根据button拿到当前button的RGB数值 index:0为R，1为G，2为B，button:是当前button
- (CGFloat)getRGBValueWithIndex:(NSInteger)index button:(UIButton *)button {
    // 创建两个数组接收颜色的RGB
    CGFloat leftRGB[3];
    CGFloat rightRGB[3];
    getRGBValue(leftRGB, self.normalColor);
    getRGBValue(rightRGB, self.selectColor);
    // 计算当前button和滑块的交叉区域宽度
    CGRect frame = self.backgroundView.frame;
    frame.size.width = button.frame.size.width;
    frame.origin.x -= (button.frame.size.width - self.backgroundView.frame.size.width)/2.0;
    CGFloat overLapWidth = CGRectIntersection(button.frame, frame).size.width;
    CGFloat value = overLapWidth / button.frame.size.width;
    // 返回RGB值
    if ([button isEqual:self.selectButton]) {
        return leftRGB[index] + value * (rightRGB[index] - leftRGB[index]);
    } else {
        return rightRGB[index] + (1 - value) * (leftRGB[index] - rightRGB[index]);
    }
}

// 设置部分颜色
- (void)setNormalColor:(UIColor *)normalColor selectColor:(UIColor *)selectColor edgingColor:(UIColor *)edgingColor {
    self.normalColor = normalColor;
    self.selectColor = selectColor;
    self.edgingColor = edgingColor;
    [self setAllColors];
}

// 设置所有颜色
- (void)setNormalColor:(UIColor *)normalColor selectColor:(UIColor *)selectColor sliderColor:(UIColor *)sliderColor edgingColor:(UIColor *)edgingColor {
    self.normalColor = normalColor;
    self.selectColor = selectColor;
    self.sliderColor = sliderColor;
    self.edgingColor = edgingColor;
    [self setAllColors];
}

// 设置所有属性
- (void)setNormalColor:(UIColor *)normalColor selectColor:(UIColor *)selectColor sliderColor:(UIColor *)sliderColor edgingColor:(UIColor *)edgingColor edgingWidth:(CGFloat)edgingWidth {
    self.normalColor = normalColor;
    self.selectColor = selectColor;
    self.sliderColor = sliderColor;
    self.edgingColor = edgingColor;
    self.edgingWidth = edgingWidth;
    [self setAllColors];
}

// 设置滑块高度
- (void)setSliderHeight:(CGFloat)sliderHeight {
    _sliderHeight = sliderHeight;
    
    CGRect bounds = self.backgroundView.bounds;
    CGPoint center = self.backgroundView.center;
    center.y = self.frame.size.height - _sliderHeight - 0.5 + _sliderHeight/2.0;
    bounds.size.height = _sliderHeight;
    self.backgroundView.center = center;
    self.backgroundView.bounds = bounds;
}

- (void)setSliderWidth:(CGFloat)sliderWidth {
    _sliderWidth = sliderWidth;
    CGRect bounds = self.backgroundView.bounds;
    bounds.size.width = _sliderWidth;
    self.backgroundView.bounds = bounds;
}

// 设置button字体大小
- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    for (UIButton *button in self.allButtons) {
        button.titleLabel.font = _titleFont;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"borderWidth"] || [keyPath isEqualToString:@"borderColor"]) {
        self.edgingColor = [UIColor colorWithCGColor:self.layer.borderColor];
        self.edgingWidth = self.layer.borderWidth;
    }
}
// 移除观察者
- (void)dealloc {
    [self removeObserver:self forKeyPath:@"borderWidth"];
    [self removeObserver:self forKeyPath:@"borderColor"];
}

#pragma mark - setters and getters
- (NSMutableArray *)twoLines {
    if (_twoLines == nil) {
        _twoLines = [NSMutableArray array];
    }
    return _twoLines;
}

- (void)removeTwoLinesFromSuperView {
    for (int i = 0; i < _twoLines.count; i++) {
        if ([_twoLines[i] isKindOfClass:[UIView class]]) {
            [((UIView *)_twoLines[i]) removeFromSuperview];
        }
    }
}
    
@end
