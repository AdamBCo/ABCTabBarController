// The MIT License (MIT)
//
//  Created by Adam Cooper on 8/29/15.
//  Copyright (c) 2015 Adam Cooper. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ABCTabBarController.h"
#import "ExampleViewController.h"
#import "NewTabBar.h"
#import "UIView+Frame.h"

@interface ABCTabBarController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIScrollViewDelegate, ABCTabBarDelegate>

@property (nonatomic, strong) UIPageViewController *pageController;
@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, strong) NewTabBar *tabBar;

@property (nonatomic, assign) CGFloat lastContentOffset;


@end

@implementation ABCTabBarController {
    NSUInteger _lastIndex;
    BOOL disableDragging;
}

- (void)viewDidLoad {
  [super viewDidLoad];
    
    self.lastContentOffset = 0;

  [self.view addSubview:self.pageController.view];
  [self.view addSubview:self.tabBar];
    
    NSArray *viewControllers = [NSArray arrayWithObject:[self.viewControllers objectAtIndex:0]];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self addChildViewController:self.pageController];
    [self.pageController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma Public functions
- (void)setItems:(NSArray *)items {
//  [self.tabBar setItems:items];
}

#pragma PageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSInteger index = [self.viewControllers indexOfObject: viewController];
    if(index == 0)
        return nil;
    else {
        return  index == 0  ?  [self.viewControllers lastObject]  :  self.viewControllers[index - 1];
    }
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [self.viewControllers indexOfObject: viewController];
    if(index == self.viewControllers.count - 1)
        return nil;
    else
        return self.viewControllers[(index + 1) % self.viewControllers.count];
    
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    return self.viewControllers.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return 0;
}


-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    NSUInteger index = [self.viewControllers indexOfObject: [pageViewController.viewControllers lastObject]];
    
    NSLog(@"INDEX: %lu",(unsigned long)index);

    disableDragging = YES;
    [UIView animateWithDuration:.2f
                     animations:^{
                         self.tabBar.indicatorView.left = self.view.width/3 * index;
                     }completion:^(BOOL finished) {
                         self.lastContentOffset = self.tabBar.indicatorView.left;
                         self.tabBar.selectedIndex = @(index).intValue;
                         disableDragging = NO;
                     }];
}





#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    float xDriff = scrollView.contentOffset.x - scrollView.width;
    
    if (!disableDragging) {

        switch (scrollView.panGestureRecognizer.state) {
                
            case UIGestureRecognizerStateBegan:
                
                // User began dragging
                break;
                
            case UIGestureRecognizerStateChanged: {
                
                
                if (scrollView.contentOffset.x < scrollView.width) {
                    
                    if (self.tabBar.selectedIndex == 0) {
                        return;
                    }
                    
                    if (self.tabBar.indicatorView.left <= 0) {
                        return;
                    }
                    
                    self.tabBar.indicatorView.left = (self.view.width/3 * self.tabBar.selectedIndex) + xDriff / scrollView.width * (scrollView.width/3);
                } else {
                 
                    if (self.tabBar.selectedIndex >= 2) {
                        return;
                    }
                    
                    if (self.tabBar.indicatorView.right >= self.view.width) {
                        return;
                    }
                    
                    self.tabBar.indicatorView.left = (self.view.width/3 * self.tabBar.selectedIndex) + xDriff / scrollView.width * (scrollView.width/3);

                }

                
            }
                
                
                break;
                
            case UIGestureRecognizerStatePossible:
                
                self.tabBar.indicatorView.left = (self.view.width/3 * self.tabBar.selectedIndex) + xDriff / scrollView.width * (scrollView.width/3);

                break;
                
            default:
                break;
        }
    }
}


-(NewTabBar *)tabBar {
    if (!_tabBar) {
        _tabBar = [[NewTabBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 48, [UIScreen mainScreen].applicationFrame.size.width, 48)];
        [_tabBar setDelegate:self];
        [_tabBar setTabBarDelegate:self];
    }
    return _tabBar;
}

#pragma mark - ABCTabBar Delegate Methods

-(void)tabBar:(NewTabBar *)tabBar pressedForIndex:(int)index {
    
    UIViewController *viewController = [self.viewControllers objectAtIndex:index];
    
    if (!viewController) {
        viewController = [self.delegate tabBarViewController:self viewControllerAtIndex:index];
    }
    
            UIPageViewControllerNavigationDirection animateDirection;
    
            if (index > _lastIndex) {
                animateDirection = UIPageViewControllerNavigationDirectionForward;
            } else {
                animateDirection = UIPageViewControllerNavigationDirectionReverse;
            }
    
    __unsafe_unretained typeof(self) weakSelf = self;
    disableDragging = YES;
    [self.pageController.view setUserInteractionEnabled:NO];
    [self.pageController setViewControllers:@[ viewController ]
                                  direction:animateDirection
                                   animated:YES
                                 completion:^(BOOL finished) {
                                     [weakSelf.pageController.view setUserInteractionEnabled:YES];
                                     weakSelf->disableDragging = NO;
                                      weakSelf->_lastIndex = index;
                                     
                                     if ([weakSelf->_delegate respondsToSelector:@selector(tabBarViewController:didMoveToIndex:)]) {
                                         [weakSelf->_delegate tabBarViewController:weakSelf didMoveToIndex:index];
                                     }
                                 }];
    
}


-(UIPageViewController *)pageController {
    if (!_pageController) {
        _pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:nil];
        [_pageController setDelegate:self];
        [_pageController setDataSource:self];
        [_pageController.view setBackgroundColor:[UIColor whiteColor]];
        
        for (UIView *view in _pageController.view.subviews) {
            if ([view isKindOfClass:[UIScrollView class]]) {
                [(UIScrollView *)view setDelegate:self];
            }
        }
    }
    return _pageController;
}

-(NSArray *)viewControllers {
    if (!_viewControllers) {
        
        ExampleViewController *childViewControllerOne = [[ExampleViewController alloc] init];
        [childViewControllerOne setIndex:1];
        UINavigationController *navigationOne = [[UINavigationController alloc] initWithRootViewController:childViewControllerOne];
        [navigationOne.navigationBar setBarTintColor:[UIColor blackColor]];
        
        ExampleViewController *childViewControllerTwo = [[ExampleViewController alloc] init];
        [childViewControllerTwo setIndex:2];
        UINavigationController *navigationTwo = [[UINavigationController alloc] initWithRootViewController:childViewControllerTwo];
        [navigationTwo.navigationBar setBarTintColor:[UIColor blackColor]];
        
        ExampleViewController *childViewControllerThree = [[ExampleViewController alloc] init];
        [childViewControllerThree setIndex:3];

        _viewControllers = @[navigationOne, navigationTwo, childViewControllerThree];
    }
    return _viewControllers;
}

- (ExampleViewController *)viewControllerAtIndex:(NSUInteger)index {
    
//    APPChildViewController *childViewController = [[APPChildViewController alloc]init];
//    childViewController.index = index;
    
    return [self.viewControllers objectAtIndex:index];
    
}

@end
