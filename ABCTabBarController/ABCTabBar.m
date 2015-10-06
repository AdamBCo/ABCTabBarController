//
//  NewTabBar.m
//  ABCTabBarController
//
//  Created by Adam Cooper on 9/27/15.
//  Copyright © 2015 Adam Cooper. All rights reserved.
//

#import "ABCTabBar.h"
#import "UIView+Frame.h"

@interface ABCTabBar ()


@end

@implementation ABCTabBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor blueColor]];
        [self addSubview:self.buttonOne];
        [self addSubview:self.buttonTwo];
        [self addSubview:self.buttonThree];
        [self addSubview:self.indicatorView];
    }
    return self;
}

#pragma mark - Actions

- (void)moveIndicatorToFirstButton{
    
    [self.tabBarDelegate tabBar:self pressedForIndex:0];

    [UIView animateWithDuration:.2f
                     animations:^{
                         self.indicatorView.frame = CGRectMake(self.buttonOne.left,self.indicatorView.top, self.indicatorView.width, self.indicatorView.height);
                     } completion:^(BOOL finished) {
                         self.selectedIndex = 0;
                     }];
    
}

- (void)moveIndicatorToSecondButton{
    
    [self.tabBarDelegate tabBar:self pressedForIndex:1];
    
    [UIView animateWithDuration:.2f
                     animations:^{
                         self.indicatorView.frame = CGRectMake(self.buttonTwo.left,self.indicatorView.top, self.indicatorView.width, self.indicatorView.height);
                     }completion:^(BOOL finished) {
                         self.selectedIndex = 1;
                     }];
    
}

- (void)moveIndicatorToThirdButton{
    
    [self.tabBarDelegate tabBar:self pressedForIndex:2];

    [UIView animateWithDuration:.2f
                     animations:^{
                         self.indicatorView.frame = CGRectMake(self.buttonThree.left,self.indicatorView.top, self.indicatorView.width, self.indicatorView.height);
                     } completion:^(BOOL finished) {
                         self.selectedIndex = 2;
                     }];
    
}


#pragma mark - Properties

-(UIButton *)buttonOne {
    if (!_buttonOne) {
        _buttonOne = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/3, self.frame.size.height)];
        [_buttonOne setBackgroundColor:[UIColor blackColor]];
        [_buttonOne addTarget:self action:@selector(moveIndicatorToFirstButton) forControlEvents:UIControlEventTouchUpInside];

    }
    return _buttonOne;
}

-(UIButton *)buttonTwo {
    if (!_buttonTwo) {
        _buttonTwo = [[UIButton alloc] initWithFrame:CGRectMake(self.buttonOne.right, 0, self.frame.size.width/3, self.frame.size.height)];
        [_buttonTwo setBackgroundColor:[UIColor blackColor]];
        [_buttonTwo setTitle:@"TWO" forState:UIControlStateNormal];
        [_buttonTwo addTarget:self action:@selector(moveIndicatorToSecondButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonTwo;
}

-(UIButton *)buttonThree {
    if (!_buttonThree) {
        _buttonThree = [[UIButton alloc] initWithFrame:CGRectMake(self.buttonTwo.right, 0, self.frame.size.width/3, self.frame.size.height)];
        [_buttonThree setBackgroundColor:[UIColor blackColor]];
        [_buttonThree setImage:[UIImage imageNamed:@"pin56"] forState:UIControlStateNormal];
        [_buttonThree setTintColor:[UIColor whiteColor]];
        [_buttonThree addTarget:self action:@selector(moveIndicatorToThirdButton) forControlEvents:UIControlEventTouchUpInside];

    }
    return _buttonThree;
}

-(UIView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIButton alloc] initWithFrame:CGRectMake(0, self.height - 4, self.frame.size.width/3, 4)];
        [_indicatorView setBackgroundColor:[UIColor blueColor]];

    }
    return _indicatorView;
}

@end
