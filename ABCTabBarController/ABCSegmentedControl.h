//
//  ABCSegmentedControl.h
//  ABCTabBarController
//
//  Created by Adam Cooper on 8/29/15.
//  Copyright (c) 2015 Adam Cooper. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ABCTabBar;

@interface ABCSegmentedControl : UISegmentedControl

@property(nonatomic) UIView *indicatorView;
@property(nonatomic) UIColor *rippleColor;
@property(nonatomic) UIColor *indicatorColor;
@property(nonatomic) NSMutableArray *tabs;
@property(strong, nonatomic) ABCTabBar *tabBar;

- (CGRect)getSelectedSegmentFrame;
- (void)setTextFont:(UIFont *)textFont withColor:(UIColor *)textColor;
- (void)moveIndicatorToFrame:(CGRect)frame withAnimated:(BOOL)animated;
- (instancetype)initWithTabBar:(ABCTabBar *)bar ;

@end
