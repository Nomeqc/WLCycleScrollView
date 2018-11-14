//
//  MyCycleScrollView.h
//  WLCycleScrollView_Example
//
//  Created by Fallrainy on 2018/11/12.
//  Copyright © 2018 Fallrainy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLCycleScrollView;

@protocol WLCycleScrollViewDataSource <NSObject>

@required

- (UIView * _Nonnull )cycleScrollView:(WLCycleScrollView *)cycleScrollView pageViewAtIndex:(NSInteger)index;

- (NSUInteger)numberOfPagesInCycleScrollView:(WLCycleScrollView *)cycleScrollView;

@end

@protocol WLCycleScrollViewDelegate <NSObject>

@optional

- (void)cycleScrollView:(WLCycleScrollView  *)cycleScrollView didScrollToPageAtIndex:(NSUInteger)index;

- (void)cycleScrollView:(WLCycleScrollView  *)cycleScrollView didTapPageAtIndex:(NSUInteger)index;

@end

@protocol WLCycleScrollViewAccessoryProvider <NSObject>

@required

- (UIView * _Nonnull )accessoryView;

- (void)updateAccessoryView:(UIView *)accessoryView currentPageIndex:(NSUInteger)index numberOfPages:(NSUInteger)numberOfPages;

- (void)layoutAccessoryView:(UIView *)accessoryView containerBounds:(CGRect)bounds;

@end

@interface WLCycleScrollView : UIView

@property (nonatomic, readonly) UIScrollView *scrollView;

///附加视图 可以实现WLCycleScrollViewAccessoryProvider协议自定义视图
@property (nonatomic, readonly) UIView *accessoryView;

///当前页面索引
@property (nonatomic, readonly) NSUInteger currentPageIndex;

///自动滚动间隔时间，默认为4s
@property (nonatomic) NSTimeInterval autoScrollInterval;

///启动自动滚动，默认为YES
@property (nonatomic) BOOL autoScrollEnabled;

///只有一页的时候 是否隐藏AccessoryView, 默认为YES
@property (nonatomic) BOOL hidesAccessoryViewForSinglePage;

@property (nonatomic, weak) id<WLCycleScrollViewDelegate> delegate;
@property (nonatomic, weak) id<WLCycleScrollViewDataSource> dataSource;
@property (nonatomic, weak) id<WLCycleScrollViewAccessoryProvider> accessoryProvider;

///刷新数据
- (void)reloadData;

@end
