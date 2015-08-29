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

#import "ABCTabBar.h"
#import "MDRippleLayer.h"
#import <uiKit/UISegmentedControl.h>
#import <Foundation/Foundation.h>
#import "ABCSegmentedControl.h"

#define kMDContentHorizontalPaddingIPad 24
#define kMDContentHorizontalPaddingIPhone 12
#define kMDTabBarHorizontalInset 8

#pragma mark MDTabBar
@implementation ABCTabBar

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  if (self = [super initWithCoder:aDecoder]) {
    [self initContent];
  }
  return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self initContent];
  }
  return self;
}

- (instancetype)initWithItems:(NSArray *)items delegate:(id)delegate {
  if (self = [super init]) {
    [self initContent];
    _delegate = delegate;
    [self setItems:items];
  }

  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.scrollView.frame = CGRectMake(0, 0, self.bounds.size.width, kMDTabBarHeight);
  [self.scrollView setContentInset:UIEdgeInsetsMake(0, kMDTabBarHorizontalInset, 0, kMDTabBarHorizontalInset)];
  [self.scrollView setContentSize:self.segmentedControl.bounds.size];
}

#pragma mark Private methods
- (void)initContent {
    self.segmentedControl = [[ABCSegmentedControl alloc] initWithTabBar:self];
    [self.segmentedControl setTintColor:[UIColor clearColor]];
    [self addSubview:self.scrollView];
    
    [self.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.layer setShadowRadius:1];
    [self.layer setShadowOpacity:0.5];
    [self.layer setShadowOffset:CGSizeMake(0, 1.5)];

    [self setTextColor:[UIColor whiteColor]];
    [self setTextFont:[UIFont systemFontOfSize:12]];
    [self setIndicatorColor:[UIColor whiteColor]];
    [self setRippleColor:[UIColor whiteColor]];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
  [super willMoveToSuperview:newSuperview];
  if (newSuperview) {
      [self.segmentedControl addObserver:self forKeyPath:@"frame" options:0 context:nil];
  }
}

- (void)removeFromSuperview {
  [self.segmentedControl removeObserver:self forKeyPath:@"frame"];
  [super removeFromSuperview];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.segmentedControl && [keyPath isEqualToString:@"frame"]) {
        [self.scrollView setContentSize:self.segmentedControl.bounds.size];
    }
}

- (void)updateItemAppearance {
    if (_textColor && _textFont) {
        [self.segmentedControl setTextFont:_textFont withColor:_textColor];
    }
}

- (void)scrollToSelectedIndex {
    CGRect frame = [self.segmentedControl getSelectedSegmentFrame];
    CGFloat contentOffset = frame.origin.x + kMDTabBarHorizontalInset - (self.frame.size.width - frame.size.width) / 2;
    
    if (contentOffset > self.scrollView.contentSize.width + kMDTabBarHorizontalInset - self.frame.size.width) {
        contentOffset = self.scrollView.contentSize.width + kMDTabBarHorizontalInset -self.frame.size.width;
    } else if (contentOffset < -kMDTabBarHorizontalInset) {
        contentOffset = -kMDTabBarHorizontalInset;
    }
    
    [self.scrollView setContentOffset:CGPointMake(contentOffset, 0) animated:YES];
}

#pragma mark - Public methods

- (void)updateSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    [self scrollToSelectedIndex];
    
    if (_delegate) {
        [_delegate tabBar:self didChangeSelectedIndex:_selectedIndex];
    }
}

- (void)setItems:(NSArray *)items {
    [self.segmentedControl removeAllSegments];
    NSUInteger index = 0;
    for (id item in items) {
        [self insertItem:item atIndex:index animated:NO];
        index++;
    }
    
    self.selectedIndex = 0;
}

- (void)insertItem:(id)item atIndex:(NSUInteger)index animated:(BOOL)animated {
  if ([item isKindOfClass:[NSString class]]) {
    [self.segmentedControl insertSegmentWithTitle:item
                                     atIndex:index
                                    animated:animated];
  } else if ([item isKindOfClass:[UIImage class]]) {
    [self.segmentedControl insertSegmentWithImage:item
                                     atIndex:index
                                    animated:animated];
  }
}

- (void)removeItemAtIndex:(NSUInteger)index animated:(BOOL)animated {
  [self.segmentedControl removeSegmentAtIndex:index animated:animated];
}

- (void)replaceItem:(id)item atIndex:(NSUInteger)index {
  if ([item isKindOfClass:[NSString class]]) {
    [self.segmentedControl setTitle:item forSegmentAtIndex:index];

  } else if ([item isKindOfClass:[UIImage class]]) {
    [self.segmentedControl setImage:item forSegmentAtIndex:index];
  }
}

- (void)moveIndicatorToFrame:(CGRect)frame withAnimated:(BOOL)animated {
  [self.segmentedControl moveIndicatorToFrame:frame withAnimated:animated];
}

#pragma mark Setters

- (void)setBackgroundColor:(UIColor *)backgroundColor {
  _backgroundColor = backgroundColor;
  [self.scrollView setBackgroundColor:backgroundColor];
}

- (void)setTextColor:(UIColor *)textColor {
  _textColor = textColor;
  [self updateItemAppearance];
}

- (void)setIndicatorColor:(UIColor *)indicatorColor {
  _indicatorColor = indicatorColor;
  [self.segmentedControl setIndicatorColor:_indicatorColor];
}

- (void)setRippleColor:(UIColor *)rippleColor {
  _rippleColor = rippleColor;
  [self.segmentedControl setRippleColor:_rippleColor];
}

- (void)setTextFont:(UIFont *)textFont {
  _textFont = textFont;
  [self updateItemAppearance];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
  if (selectedIndex < self.segmentedControl.numberOfSegments) {
    _selectedIndex = selectedIndex;
    if (self.segmentedControl.selectedSegmentIndex != _selectedIndex) {
      [self.segmentedControl setSelectedSegmentIndex:_selectedIndex];
      [self scrollToSelectedIndex];
    }
  }
}

- (NSInteger)numberOfItems {
  return self.segmentedControl.numberOfSegments;
}

- (NSMutableArray *)tabs {
  return self.segmentedControl.tabs;
}

#pragma mark - Lazy Instantiation

-(UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [_scrollView setShowsVerticalScrollIndicator:NO];
        [_scrollView setBounces:NO];
        [_scrollView addSubview:self.segmentedControl];
    }
    return _scrollView;
}


@end
