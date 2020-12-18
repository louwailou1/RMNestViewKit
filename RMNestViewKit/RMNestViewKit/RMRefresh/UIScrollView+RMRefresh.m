//
//  UIScrollView+RMRefresh.m
//  CircleProgressView
//
//  Created by RMNestViewKit on 16/7/5.
//  Copyright © 2016年 RMNestViewKit. All rights reserved.
//

#import "UIScrollView+RMRefresh.h"
#import <objc/runtime.h>
#import "RMRefreshHeader.h"

@implementation UIScrollView (RMRefresh)

- (void)addRefreshHeaderWithHandle:(void (^)(void))handle {
    RMRefreshHeader * header = [[RMRefreshHeader alloc]init];
    header.handle = handle;
    self.header = header;
//    [self insertSubview:header atIndex:1];
}

#pragma mark - Associate
- (void)setHeader:(RMRefreshHeader *)header {
    objc_setAssociatedObject(self, @selector(header), header, OBJC_ASSOCIATION_ASSIGN);
}

- (RMRefreshHeader *)header {
    return objc_getAssociatedObject(self, @selector(header));
}

#pragma mark - Swizzle
+ (void)load {
    Method originalMethod = class_getInstanceMethod([self class], NSSelectorFromString(@"dealloc"));
    Method swizzleMethod = class_getInstanceMethod([self class], NSSelectorFromString(@"su_dealloc"));
    method_exchangeImplementations(originalMethod, swizzleMethod);
}

- (void)su_dealloc {
    self.header = nil;
    [self su_dealloc];
}

@end
