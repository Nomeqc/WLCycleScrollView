//
//  MyCycleScrollView.m
//  WLCycleScrollView_Example
//
//  Created by Fallrainy on 2018/11/12.
//  Copyright © 2018 Fallrainy. All rights reserved.
//

#import "WLCycleScrollView.h"

@interface WLCycleScrollView ()<UIScrollViewDelegate>

@property (nonatomic, readwrite) UIScrollView *scrollView;

@property (nonatomic, readwrite) UIView *accessoryView;

@property (nonatomic, readwrite) NSUInteger currentPageIndex;

@property (nonatomic) NSMutableDictionary<NSNumber *, UIView *> *pageViewCache;
@property (nonatomic) NSMutableDictionary<NSNumber *, UIView *> *extraPageViewCache;

@property (nonatomic) BOOL stopScroll;

@end


@implementation WLCycleScrollView {
    NSTimer *_timer;
    NSUInteger _numberOfPages;
}

- (void)dealloc {
    [self invalidateTimer];
    _scrollView.delegate = nil;
    _delegate = nil;
    _dataSource = nil;
    _accessoryProvider = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    _autoScrollEnabled = YES;
    _hidesAccessoryViewForSinglePage = YES;
    _autoScrollInterval = 4.f;
    _pageViewCache = [NSMutableDictionary dictionary];
    _extraPageViewCache = [NSMutableDictionary dictionary];
    UIScrollView *scrollView = ({
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.pagingEnabled = YES;
        scrollView.delegate = self;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView;
    });
    [self addSubview:scrollView];
    _scrollView = scrollView;
    
    [self adjustScrollViewContentSize];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    return self;
}

- (void)setDataSource:(id<WLCycleScrollViewDataSource>)dataSource {
    _dataSource = dataSource;
    [self reloadData];
}

- (void)setAccessoryProvider:(id<WLCycleScrollViewAccessoryProvider>)accessoryProvider {
    _accessoryProvider = accessoryProvider;
    [self reloadData];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _scrollView.frame = self.bounds;
    [self adjustScrollViewContentSize];
    [self updateAccessoryView];
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    if (_autoScrollEnabled) {
        [self setStopScroll:(BOOL)!newWindow];
    }
}

- (void)adjustScrollViewContentSize {
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) * (_numberOfPages > 1? 3 : 1), CGRectGetHeight(self.bounds));
    CGFloat contentOffsetX = 0.f;
    if (_numberOfPages > 1) {
        contentOffsetX = CGRectGetWidth(self.bounds);
    }
    [_scrollView setContentOffset:CGPointMake(contentOffsetX, 0.f)];
}

- (void)updateAccessoryView {
    [self notifyUpdateAccessoryView:_accessoryView currentPageIndex:_currentPageIndex numberOfPages:_numberOfPages];
    [self notifyLayoutAccessoryView:_accessoryView containerBounds:self.bounds];
}


- (void)setAutoScrollEnabled:(BOOL)autoScrollEnabled {
    _autoScrollEnabled = autoScrollEnabled;
    [self setStopScroll:!autoScrollEnabled];
}

- (void)setStopScroll:(BOOL)stopScroll {
    _stopScroll = stopScroll;
    [self invalidateTimer];
    
    if (!stopScroll && _numberOfPages >= 2) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:_autoScrollInterval target:self selector:@selector(autoScroll) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

- (void)invalidateTimer {
    if (_timer) {
        if ([_timer isValid]) {
            [_timer invalidate];
        }
        _timer = nil;
    }
}

- (void)autoScroll {
    if (_scrollView.contentOffset.x != CGRectGetWidth(self.bounds)) {
        [_scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.bounds), 0)];
    }
    [_scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.bounds) * 2, 0) animated:YES];
}


- (void)loadData {
    ///先移除所有view
    [self.pageViewCache.objectEnumerator.allObjects enumerateObjectsUsingBlock:^(UIView * _Nonnull pageView, NSUInteger idx, BOOL * _Nonnull stop) {
        [pageView removeFromSuperview];
    }];
    
    [self.extraPageViewCache.objectEnumerator.allObjects enumerateObjectsUsingBlock:^(UIView * _Nonnull pageView, NSUInteger idx, BOOL * _Nonnull stop) {
        [pageView removeFromSuperview];
    }];

    CGFloat contentOffsetX = 0;
    NSArray<NSNumber *> *pageIndexes = nil;
    if (_numberOfPages > 1) {
        _scrollView.scrollEnabled = YES;
        contentOffsetX = CGRectGetWidth(self.bounds);
        if (_numberOfPages == 2) {
            pageIndexes = @[@([self previousPageIndex]), @(_currentPageIndex)];
        } else {
            pageIndexes = @[@([self previousPageIndex]), @(_currentPageIndex), @([self nextPageIndex])];
        }
    } else {
        _scrollView.scrollEnabled = NO;
        contentOffsetX = 0;
        if (_numberOfPages == 1) {
            pageIndexes = @[@(0)];
        }
    }
    NSMutableArray<UIView *> *pageViews = [NSMutableArray array];

    [pageIndexes enumerateObjectsUsingBlock:^(NSNumber *indexNumber, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *pageView = self.pageViewCache[indexNumber];
        if (!pageView) {
            pageView = [self dataSourcePageViewAtIndex:[indexNumber unsignedIntegerValue]];
            self.pageViewCache[indexNumber] = pageView;
        }
        [pageViews addObject:pageView];
    }];
    //只有两页时,当前页和上一页可以冲缓存里获取,因为上一页和下一页实际页码一致，所以下一页 要另外处理
    if (_numberOfPages == 2) {
        NSNumber *nextPageKey = @([self nextPageIndex]);
        UIView *nextPageView = _extraPageViewCache[nextPageKey];
        if (!nextPageView) {
            nextPageView = [self dataSourcePageViewAtIndex:[self nextPageIndex]];
            _extraPageViewCache[nextPageKey] = nextPageView;
        }
       [pageViews addObject:nextPageView];
    }
    [pageViews enumerateObjectsUsingBlock:^(UIView *pageView, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.scrollView addSubview:pageView];
        [self addGestureRecognizerForView:pageView];
        pageView.frame = ({
            CGRect frame = self.bounds;
            frame.origin.x = idx * CGRectGetWidth(self.bounds);
            frame;
        });
    }];
    
    ///只保留当前页, 上一页, 下一页pageView,其它的全部移除
    NSMutableArray<NSNumber *> *unusedKeys = [NSMutableArray array];
    [_pageViewCache enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, UIView * _Nonnull obj, BOOL * _Nonnull stop) {
        if (![pageIndexes containsObject:key]) {
            [unusedKeys addObject:key];
        }
    }];
    [_pageViewCache removeObjectsForKeys:unusedKeys];
    
    [self.scrollView setContentOffset:CGPointMake(contentOffsetX, 0.f)];
}

- (void)reloadData {
    [self invalidateTimer];
    _currentPageIndex = 0;
    _numberOfPages = [self dataSourceNumberOfPagesInCycleScrollView];
    
    {
        [_accessoryView removeFromSuperview];
        _accessoryView = [self accessoryProviderAccessoryView];
        [_accessoryView removeFromSuperview];
        [self addSubview:_accessoryView];
        _accessoryView.hidden = (_hidesAccessoryViewForSinglePage && _numberOfPages == 1);
    }
    
    [self adjustScrollViewContentSize];
    [self updateAccessoryView];
    
    [_pageViewCache.objectEnumerator.allObjects enumerateObjectsUsingBlock:^(UIView * _Nonnull pageView, NSUInteger idx, BOOL * _Nonnull stop) {
        [pageView removeFromSuperview];
    }];
    [_pageViewCache removeAllObjects];
    
    [_extraPageViewCache.objectEnumerator.allObjects enumerateObjectsUsingBlock:^(UIView * _Nonnull pageView, NSUInteger idx, BOOL * _Nonnull stop) {
        [pageView removeFromSuperview];
    }];
    [_extraPageViewCache removeAllObjects];
    
    [self loadData];
    [self setStopScroll:!_autoScrollEnabled];
}

// MARK: Notification Handler
- (void)appWillResignActive {
    [self setStopScroll:YES];
}

- (void)appWillEnterForeground {
    if (self.window && _autoScrollEnabled) {
        [self setStopScroll:NO];
    }
}

// MARK: UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    if (offsetX >= 2 * CGRectGetWidth(self.bounds)) {
        _currentPageIndex = [self nextPageIndex];
    } else  {
        if (offsetX > 0 * CGRectGetWidth(self.bounds)) {
            return;
        }
        _currentPageIndex = [self previousPageIndex];
    }
    [self loadData];
    [self updateAccessoryView];
    [self notifyDidScrollToPageAtIndex:_currentPageIndex];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.bounds), 0)];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (_autoScrollEnabled) {
        [self setStopScroll:YES];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (_autoScrollEnabled) {
        [self setStopScroll:NO];
    }
}

// MARK: GestureRecognizer Handler
- (void)didTapPageView {
    [self notifyDidTapPageAtIndex:_currentPageIndex];
}

// MARK: Helper
- (void)addGestureRecognizerForView:(UIView *)view {
    view.userInteractionEnabled = YES;
    NSArray<UIGestureRecognizer *> *gestureRecognizers = view.gestureRecognizers;
    [gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [view removeGestureRecognizer:obj];
    }];
    [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapPageView)]];
}

// MARK: Accessory
- (NSUInteger)previousPageIndex {
    if (_currentPageIndex > 0) {
        return _currentPageIndex - 1;
    }
    return _numberOfPages - 1;
}

- (NSUInteger)nextPageIndex {
   return (_currentPageIndex + 1) % _numberOfPages;
}

- (NSUInteger)dataSourceNumberOfPagesInCycleScrollView {
    if (_dataSource) {
        NSString *reason = [NSString stringWithFormat:@"%@必须实现WLCycleScrollViewDataSource协议方法numberOfPagesInCycleScrollView:",_dataSource];
        NSAssert([self.dataSource respondsToSelector:@selector(numberOfPagesInCycleScrollView:)], reason);
        return [self.dataSource numberOfPagesInCycleScrollView:self];
    }
    return 0;
}

- (UIView *)dataSourcePageViewAtIndex:(NSUInteger)index {
    if (_dataSource) {
        NSString *reason = [NSString stringWithFormat:@"%@必须实现WLCycleScrollViewDataSource协议方法cycleScrollView:pageViewAtIndex:",_dataSource];
        NSAssert([self.dataSource respondsToSelector:@selector(cycleScrollView:pageViewAtIndex:)], reason);
        UIView *view = [self.dataSource cycleScrollView:self pageViewAtIndex:index];
        reason = [NSString stringWithFormat:@"[%@ cycleScrollView:pageViewAtIndex:] 不能返回nil", NSStringFromClass([_dataSource class])];
        NSAssert(view, reason);
        reason = [NSString stringWithFormat:@"[%@ cycleScrollView:pageViewAtIndex:] 返回值类型不属于UIView", NSStringFromClass([_dataSource class])];
        NSAssert([view isKindOfClass:[UIView class]], reason);
        return view;
    }
    return nil;
}

- (UIView *)accessoryProviderAccessoryView {
    if (_accessoryProvider) {
        NSString *reason = [NSString stringWithFormat:@"%@必须实现WLCycleScrollViewAccessoryProvider协议方法accessoryView",_accessoryProvider];
        NSAssert([_accessoryProvider respondsToSelector:@selector(accessoryView)], reason);
        return [_accessoryProvider accessoryView];
    }
    return nil;
}

- (void)notifyUpdateAccessoryView:(UIView *)accessoryView currentPageIndex:(NSUInteger)index numberOfPages:(NSUInteger)numberOfPages {
    if (_accessoryProvider) {
        NSString *reason = [NSString stringWithFormat:@"%@必须实现WLCycleScrollViewAccessoryProvider协议方法updateAccessoryView:currentPageIndex:numberOfPages:",_accessoryProvider];
        NSAssert([_accessoryProvider respondsToSelector:@selector(updateAccessoryView:currentPageIndex:numberOfPages:)], reason);
        [_accessoryProvider updateAccessoryView:accessoryView currentPageIndex:index numberOfPages:numberOfPages];
    }
}

- (void)notifyLayoutAccessoryView:(UIView *)accessoryView containerBounds:(CGRect)bounds {
    if (_accessoryProvider) {
        NSString *reason = [NSString stringWithFormat:@"%@必须实现WLCycleScrollViewAccessoryProvider协议方法layoutAccessoryView:containerBounds:",_accessoryProvider];
        NSAssert([_accessoryProvider respondsToSelector:@selector(layoutAccessoryView:containerBounds:)], reason);
        [_accessoryProvider layoutAccessoryView:accessoryView containerBounds:bounds];
    }
}

- (void)notifyDidScrollToPageAtIndex:(NSUInteger)index {
    if ([self.delegate respondsToSelector:@selector(cycleScrollView:didScrollToPageAtIndex:)]) {
        [self.delegate cycleScrollView:self didScrollToPageAtIndex:index];
    }
}

- (void)notifyDidTapPageAtIndex:(NSUInteger)index {
    if ([self.delegate respondsToSelector:@selector(cycleScrollView:didTapPageAtIndex:)]) {
        [self.delegate cycleScrollView:self didTapPageAtIndex:index];
    }
}

@end
