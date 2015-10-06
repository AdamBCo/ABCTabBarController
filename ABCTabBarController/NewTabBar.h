//
//  NewTabBar.h
//  ABCTabBarController
//
//  Created by Adam Cooper on 9/27/15.
//  Copyright © 2015 Adam Cooper. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NewTabBar;

@protocol ABCTabBarDelegate <NSObject>

-(void)tabBar:(NewTabBar *)tabBar pressedForIndex:(int)index;


@end

@interface NewTabBar : UIScrollView

@property (nonatomic, strong) UIButton *buttonOne;
@property (nonatomic, strong) UIButton *buttonTwo;
@property (nonatomic, strong) UIButton *buttonThree;
@property (nonatomic, strong) UIView *indicatorView;

@property (nonatomic) int selectedIndex;

@property (weak, nonatomic) id<ABCTabBarDelegate> tabBarDelegate;

@end
