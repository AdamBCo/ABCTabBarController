//
//  ABCSegmentedControl.h
//  ABCTabBarController
//
//  Created by Adam Cooper on 8/29/15.
//  Copyright (c) 2015 Adam Cooper. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MDTabBar;

@interface ABCSegmentedControl : UISegmentedControl

@property(nonatomic, strong) UIView *indicatorView;
@property(nonatomic) UIColor *rippleColor;
@property(nonatomic) UIColor *indicatorColor;
@property(nonatomic) NSMutableArray *tabs;
@property(strong, nonatomic) MDTabBar *tabBar;

- (CGRect)getSelectedSegmentFrame;
- (void)setTextFont:(UIFont *)textFont withColor:(UIColor *)textColor;
- (void)moveIndicatorToFrame:(CGRect)frame withAnimated:(BOOL)animated;
- (instancetype)initWithTabBar:(MDTabBar *)bar ;

@end
