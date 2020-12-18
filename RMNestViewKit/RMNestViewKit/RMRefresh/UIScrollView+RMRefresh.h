//
//  UIScrollView+RMRefresh.h
//  CircleProgressView
//
//  Created by RMNestViewKit on 16/7/5.
//  Copyright © 2016年 RMNestViewKit. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RMRefreshHeader;
@interface UIScrollView (RMRefresh)

@property (nonatomic, weak, readonly) RMRefreshHeader * header;

- (void)addRefreshHeaderWithHandle:(void (^)(void))handle;

@end
