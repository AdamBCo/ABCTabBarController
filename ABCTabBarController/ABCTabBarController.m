// The MIT License (MIT)
//
// Copyright (c) 2015 FPT Software
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
#import "APPChildViewController.h"

@interface ABCTabBarController () <ABCTabBarDelegate, UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) UIPageViewController *pageController;
@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, strong) UIViewController *currentViewController;

@end

@implementation ABCTabBarController {
  NSUInteger lastIndex;
  BOOL disableDragging;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  [self.view addSubview:self.pageController.view];
  [self.view addSubview:self.tabBar];
    
    NSArray *viewControllers = [NSArray arrayWithObject:[self.viewControllers objectAtIndex:0]];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self addChildViewController:self.pageController];
    [self.pageController didMoveToParentViewController:self];

//  // first view controller
//  id viewController =[self.delegate tabBarViewController:self viewControllerAtIndex:self.tabBar.selectedIndex];
////  [self.viewControllers
////      setObject:viewController
////         forKey:[NSNumber numberWithInteger:self.tabBar.selectedIndex]];
//
//  __unsafe_unretained typeof(self) weakSelf = self;
//  [self.pageController
//      setViewControllers:viewControllers
//               direction:UIPageViewControllerNavigationDirectionForward
//                animated:NO
//              completion:^(BOOL finished) {
//                if ([weakSelf->_delegate
//                        respondsToSelector:@selector(tabBarViewController:
//                                                           didMoveToIndex:)]) {
//                  [weakSelf->_delegate
//                      tabBarViewController:weakSelf
//                            didMoveToIndex:weakSelf->_tabBar.selectedIndex];
//                }
//              }];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma Public functions
- (void)setItems:(NSArray *)items {
  [self.tabBar setItems:items];
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
    [self.tabBar setSelectedIndex:index];
    
    // call delegate
    if ([self.delegate
         respondsToSelector:@selector(tabBarViewController:didMoveToIndex:)]) {
        [self.delegate tabBarViewController:self
                             didMoveToIndex:_tabBar.selectedIndex];
    }

}


#pragma mark - MDTabBar Delegate
- (void)tabBar:(ABCTabBar *)tabBar didChangeSelectedIndex:(NSUInteger)selectedIndex {

  UIViewController *viewController = [self.viewControllers objectAtIndex:selectedIndex];
    
    if (!viewController) {
        viewController = [self.delegate tabBarViewController:self viewControllerAtIndex:selectedIndex];
    }

    
    UIPageViewControllerNavigationDirection animateDirection;
    
    if (selectedIndex > lastIndex) {
        animateDirection = UIPageViewControllerNavigationDirectionForward;
    } else {
        animateDirection = UIPageViewControllerNavigationDirectionReverse;
    }
    
    __unsafe_unretained typeof(self) weakSelf = self;
    disableDragging = YES;
    self.pageController.view.userInteractionEnabled = NO;
    [self.pageController setViewControllers:@[ viewController ]
                                  direction:animateDirection
                                   animated:YES
                                 completion:^(BOOL finished) {
                                     weakSelf.pageController.view.userInteractionEnabled = YES;
                                     weakSelf->disableDragging = NO;
                                     weakSelf->lastIndex = selectedIndex;
                                     
                                     if ([weakSelf->_delegate respondsToSelector:@selector(tabBarViewController:didMoveToIndex:)]) {
                                         [weakSelf->_delegate tabBarViewController:weakSelf didMoveToIndex:selectedIndex];
                                     }
                                 }];
    
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

  CGPoint offset = scrollView.contentOffset;

  CGFloat scrollViewWidth = scrollView.frame.size.width;

  int selectedIndex = (int)_tabBar.selectedIndex;

  if (!disableDragging) {
    float xDriff = offset.x - scrollViewWidth;
    UIView *selectedTab = (UIView *)[_tabBar tabs][selectedIndex];

      
      float widthDiff;
      float newOriginX;
      float newWidth;
            
      
    if (offset.x < scrollViewWidth) {
      if (self.tabBar.selectedIndex == 0)
        return;

      UIView *leftTab = (UIView *)[self.tabBar tabs][selectedIndex - 1];

      widthDiff = selectedTab.frame.size.width - leftTab.frame.size.width;

      newOriginX = selectedTab.frame.origin.x +
                         xDriff / scrollViewWidth * leftTab.frame.size.width;

      newWidth = selectedTab.frame.size.width + xDriff / scrollViewWidth * widthDiff;
    }
    else {
      if (selectedIndex + 1 >= _tabBar.numberOfItems)
        return;

      UIView *rightTab = (UIView *)[self.tabBar tabs][selectedIndex + 1];

    widthDiff = rightTab.frame.size.width - selectedTab.frame.size.width;

    newOriginX = selectedTab.frame.origin.x + xDriff / scrollViewWidth * selectedTab.frame.size.width;

    newWidth = selectedTab.frame.size.width + xDriff / scrollViewWidth * widthDiff;
    }
      
      CGRect frame = CGRectMake(newOriginX, kMDTabBarHeight - kMDIndicatorHeight, newWidth, kMDIndicatorHeight);
      [self.tabBar moveIndicatorToFrame:frame withAnimated:NO];
  }
}


-(ABCTabBar *)tabBar {
    if (!_tabBar) {
        _tabBar = [[ABCTabBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 48, [UIScreen mainScreen].applicationFrame.size.width, 40)];
        [_tabBar setBackgroundColor:[UIColor blueColor]];
        
        NSArray *names = @[
                           @"HOME",
                           @"TRENDING",
                           @"FAVORITES",
                           @"SETTINGS"
                           ];
        [_tabBar setItems:names];
        [_tabBar setDelegate:self];
    }
    return _tabBar;
}

-(UIPageViewController *)pageController {
    if (!_pageController) {
        _pageController = [[UIPageViewController alloc]
                          initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                          navigationOrientation:
                          UIPageViewControllerNavigationOrientationHorizontal
                          options:nil];
        [_pageController setDelegate:self];
        [_pageController setDataSource:self];
        [_pageController.view setBackgroundColor:[UIColor redColor]];
        
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
        
        APPChildViewController *childViewControllerOne = [[APPChildViewController alloc] init];
        [childViewControllerOne setIndex:0];
        UINavigationController *navigationOne = [[UINavigationController alloc] initWithRootViewController:childViewControllerOne];
        
        APPChildViewController *childViewControllerTwo = [[APPChildViewController alloc] init];
        [childViewControllerTwo setIndex:1];
        UINavigationController *navigationTwo = [[UINavigationController alloc] initWithRootViewController:childViewControllerTwo];

        
        APPChildViewController *childViewControllerThree = [[APPChildViewController alloc] init];
        [childViewControllerThree setIndex:2];
        
        APPChildViewController *childViewControllerFour = [[APPChildViewController alloc] init];
        [childViewControllerThree setIndex:3];
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:childViewControllerFour];


        _viewControllers = @[navigationOne, navigationTwo, childViewControllerThree, navigation];
    }
    return _viewControllers;
}

- (APPChildViewController *)viewControllerAtIndex:(NSUInteger)index {
    
//    APPChildViewController *childViewController = [[APPChildViewController alloc]init];
//    childViewController.index = index;
    
    return [self.viewControllers objectAtIndex:index];
    
}

@end
