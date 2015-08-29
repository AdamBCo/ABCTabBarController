//
//  ABCSegmentedControl.m
//  ABCTabBarController
//
//  Created by Adam Cooper on 8/29/15.
//  Copyright (c) 2015 Adam Cooper. All rights reserved.
//

#import "ABCSegmentedControl.h"
#import "MDRippleLayer.h"
#import "ABCTabBar.h"

@implementation ABCSegmentedControl {
    UIView *beingTouchedView;
    UIFont *font;
}

- (instancetype)initWithTabBar:(ABCTabBar *)bar {
    if (self = [super init]) {
        _tabBar = bar;
        _tabs = [NSMutableArray array];
        self.indicatorView = [[UIView alloc]initWithFrame:CGRectMake(0, kMDTabBarHeight - kMDIndicatorHeight, 0,kMDIndicatorHeight)];
        self.indicatorView.tag = NSIntegerMax;
        [self addSubview:self.indicatorView];
        [self addTarget:self
                 action:@selector(selectionChanged:)
       forControlEvents:UIControlEventValueChanged];    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    [newSuperview addObserver:self forKeyPath:@"frame" options:0 context:nil];
}

- (void)removeFromSuperview {
    [self.superview removeObserver:self forKeyPath:@"frame"];
    [super removeFromSuperview];
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex {
    [super setSelectedSegmentIndex:selectedSegmentIndex];
    [self moveIndicatorToSelectedIndexWithAnimated:YES];
}

- (void)selectionChanged:(id)sender {
    [self moveIndicatorToSelectedIndexWithAnimated:YES];
//    [self.tabBar updateSelectedIndex:self.selectedSegmentIndex];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (object == self.superview && [keyPath isEqualToString:@"frame"]) {
        [self resizeItems];
        [self moveIndicatorToSelectedIndexWithAnimated:NO];
    }
}

#pragma mark Override Methods

- (void)insertSegmentWithImage:(UIImage *)image
                       atIndex:(NSUInteger)segment
                      animated:(BOOL)animated {
    [super insertSegmentWithImage:image atIndex:segment animated:animated];
    [self resizeItems];
    [self updateSegmentsList];
    [self addRippleLayers];
    [self performSelector:@selector(moveIndicatorToSelectedIndexWithAnimated:)
               withObject:[NSNumber numberWithBool:animated]
               afterDelay:.001f];
}

- (void)insertSegmentWithTitle:(NSString *)title
                       atIndex:(NSUInteger)segment
                      animated:(BOOL)animated {
    [super insertSegmentWithTitle:title atIndex:segment animated:animated];
    [self resizeItems];
    [self updateSegmentsList];
    [self addRippleLayers];
    [self performSelector:@selector(moveIndicatorToSelectedIndexWithAnimated:)
               withObject:[NSNumber numberWithBool:animated]
               afterDelay:.001f];
}

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment {
    [super setTitle:title forSegmentAtIndex:segment];
    [self resizeItems];
    [self performSelector:@selector(moveIndicatorToSelectedIndexWithAnimated:)
               withObject:[NSNumber numberWithBool:YES]
               afterDelay:.001f];
}

- (void)setImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)segment {
    [super setImage:image forSegmentAtIndex:segment];
    [self resizeItems];
    [self performSelector:@selector(moveIndicatorToSelectedIndexWithAnimated:)
               withObject:[NSNumber numberWithBool:YES]
               afterDelay:.001f];
}

- (void)removeSegmentAtIndex:(NSUInteger)segment animated:(BOOL)animated {
    [super removeSegmentAtIndex:segment animated:animated];
    [self updateSegmentsList];
    [self resizeItems];
    [self performSelector:@selector(moveIndicatorToSelectedIndexWithAnimated:)
               withObject:[NSNumber numberWithBool:animated]
               afterDelay:.001f];
}

#pragma mark Setter
- (void)setIndicatorColor:(UIColor *)color {
    _indicatorColor = color;
    [self.indicatorView setBackgroundColor:color];
}

- (void)setRippleColor:(UIColor *)rippleColor {
    _rippleColor = rippleColor;
    for (UIView *view in self.subviews) {
        for (CALayer *layer in view.layer.sublayers) {
            if ([layer isKindOfClass:[MDRippleLayer class]]) {
                [((MDRippleLayer *)layer)setEffectColor:_rippleColor
                                        withRippleAlpha:.1f
                                        backgroundAlpha:.1f];
                return;
            }
        }
    }
}

#pragma mark Public Methods

- (CGRect)getSelectedSegmentFrame {
    if (self.selectedSegmentIndex >= 0) {
        return ((UIView *)_tabs[self.selectedSegmentIndex]).frame;
    }
    return CGRectZero;
}

- (void)setTextFont:(UIFont *)textFont withColor:(UIColor *)textColor {
    font = textFont;
    [self setTitleTextAttributes:@{
                                   NSForegroundColorAttributeName :
                                       [textColor colorWithAlphaComponent:0.6],
                                   NSFontAttributeName : textFont
                                   } forState:UIControlStateNormal];
    [self setTitleTextAttributes:@{
                                   NSForegroundColorAttributeName : textColor,
                                   NSFontAttributeName : textFont
                                   } forState:UIControlStateSelected];
}

- (void)moveIndicatorToFrame:(CGRect)frame withAnimated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:.2f
                         animations:^{
                             self.indicatorView.frame = CGRectMake(frame.origin.x, self.bounds.size.height - kMDIndicatorHeight, frame.size.width, kMDIndicatorHeight);
                         }];
    } else {
        self.indicatorView.frame = CGRectMake(frame.origin.x, self.bounds.size.height - kMDIndicatorHeight,frame.size.width, kMDIndicatorHeight);
    }
}

#pragma mark Private Methods
- (void)resizeItems {
    if (self.numberOfSegments <= 0)
        return;
    CGFloat maxItemSize = 0;
    CGFloat segmentedControlWidth = 0;
    
    for (int i = 0; i < self.numberOfSegments; i++) {
        [self setWidth:[UIScreen mainScreen].applicationFrame.size.width/5 forSegmentAtIndex:i];
    }
    
    CGFloat holderWidth =
    self.superview.bounds.size.width - 8 * 2;
    if (segmentedControlWidth < holderWidth) {
        if (self.numberOfSegments * maxItemSize < holderWidth) {
            maxItemSize = holderWidth / self.numberOfSegments;
        }
        
        segmentedControlWidth = 0;
        for (int i = 0; i < self.numberOfSegments; i++) {
            [self setWidth:maxItemSize forSegmentAtIndex:i];
            segmentedControlWidth += (maxItemSize);
        }
    }
    
    self.frame = CGRectMake(0, 0, segmentedControlWidth, kMDTabBarHeight);
}

- (NSArray *)getSegmentList {
    // WARNING: This function gets frame from UISegment objects, undocumented
    // subviews of UISegmentedControl.
    // May break in iOS updates.
    
    NSMutableArray *segments =
    [NSMutableArray arrayWithCapacity:self.numberOfSegments];
    for (UIView *view in self.subviews) {
        if ([NSStringFromClass([view class]) isEqualToString:@"UISegment"]) {
            [segments addObject:view];
        }
    }
    
    NSArray *sortedSegments = [segments
                               sortedArrayUsingComparator:^NSComparisonResult(UIView *a, UIView *b) {
                                   if (a.frame.origin.x < b.frame.origin.x) {
                                       return NSOrderedAscending;
                                   } else if (a.frame.origin.x > b.frame.origin.x) {
                                       return NSOrderedDescending;
                                   }
                                   return NSOrderedSame;
                               }];
    
    return sortedSegments;
}

- (void)moveIndicatorToSelectedIndexWithAnimated:(BOOL)animated {
    if (self.selectedSegmentIndex < 0 && self.numberOfSegments > 0) {
        self.selectedSegmentIndex = 0;
    }
    NSInteger index = self.selectedSegmentIndex;
    
    CGRect frame = CGRectZero;
    
    if (index >= 0) {
        if ((index >= self.numberOfSegments) || (index >= _tabs.count)) {
            return;
        }
        frame = ((UIView *)_tabs[index]).frame;
    }
    
    [self moveIndicatorToFrame:frame withAnimated:animated];
}

- (void)addRippleLayers {
    for (UIView *view in _tabs) {
        if (view.tag != NSIntegerMax) {
            BOOL hasRipple = NO;
            for (CALayer *layer in view.layer.sublayers) {
                if ([layer isKindOfClass:[MDRippleLayer class]]) {
                    hasRipple = YES;
                    break;
                }
            }
            
            if (!hasRipple) {
                MDRippleLayer *layer = [[MDRippleLayer alloc] initWithSuperView:view];
                [layer setEffectColor:_rippleColor
                      withRippleAlpha:.1f
                      backgroundAlpha:.1f];
                layer.enableElevation = NO;
                layer.rippleScaleRatio = 1;
            }
        }
    }
}

- (void)updateSegmentsList {
    _tabs = [self getSegmentList].mutableCopy;
}

#pragma mark Touch event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (beingTouchedView)
        return;
    CGPoint point = [touches.allObjects[0] locationInView:self];
    for (UIView *view in self.subviews) {
        if (view.tag != NSIntegerMax && CGRectContainsPoint(view.frame, point)) {
            beingTouchedView = view;
            for (CALayer *layer in view.layer.sublayers) {
                if ([layer isKindOfClass:[MDRippleLayer class]]) {
                    [((MDRippleLayer *)layer)
                     startEffectsAtLocation:[view convertPoint:point fromView:self]];
                    return;
                }
            }
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    if (beingTouchedView) {
        for (CALayer *layer in beingTouchedView.layer.sublayers) {
            if ([layer isKindOfClass:[MDRippleLayer class]]) {
                [((MDRippleLayer *)layer)stopEffects];
            }
        }
        
        beingTouchedView = nil;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (beingTouchedView) {
        for (CALayer *layer in beingTouchedView.layer.sublayers) {
            if ([layer isKindOfClass:[MDRippleLayer class]]) {
                [((MDRippleLayer *)layer)stopEffects];
            }
        }
        
        beingTouchedView = nil;
    }
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"bounds"];
}

@end
