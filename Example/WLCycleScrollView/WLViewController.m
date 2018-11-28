//
//  WLViewController.m
//  WLCycleScrollView
//
//  Created by Fallrainy on 11/18/2017.
//  Copyright (c) 2017 Fallrainy. All rights reserved.
//

#import "WLViewController.h"
#import "WLCycleScrollView.h"
#import "UIImageView+WebCache.h"

@interface WLViewController () <WLCycleScrollViewDelegate, WLCycleScrollViewDataSource, WLCycleScrollViewAccessoryProvider>

@property (nonatomic, copy) NSArray<NSString *> *images;

@property (nonatomic, copy) NSArray<UIImageView *> *imageViews;

@end

@implementation WLViewController {
    WLCycleScrollView *_cycleScrollView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    self.images = [self dataArray];
    
    WLCycleScrollView *scrollView = [[WLCycleScrollView alloc] init];
    scrollView.frame = CGRectMake(0, 64, CGRectGetWidth(self.view.frame), roundf(CGRectGetWidth(self.view.frame) * (183/375.0)));
    scrollView.delegate = self;
    scrollView.dataSource = self;
    scrollView.accessoryProvider = self;
    [self.view addSubview:scrollView];
    _cycleScrollView = scrollView;
}

- (IBAction)didTapRandomBarButton:(UIBarButtonItem *)sender {
    NSArray *dataArray = [self dataArray];
    NSUInteger startIndex = arc4random_uniform((u_int32_t)dataArray.count);
    NSUInteger length = arc4random_uniform((u_int32_t)(dataArray.count - startIndex)) + 1;
    self.images = [dataArray subarrayWithRange:NSMakeRange(startIndex, length)];
    [_cycleScrollView reloadData];
    sender.title = [NSString stringWithFormat:@"随机数据(共%@条)", @(length)];
}

- (IBAction)didTapSwitchBarButton:(UIBarButtonItem *)sender {
    _cycleScrollView.autoScrollEnabled = !_cycleScrollView.autoScrollEnabled;
    if (_cycleScrollView.autoScrollEnabled) {
        sender.title = @"停止滚动";
    } else {
        sender.title = @"开始滚动";
    }
}

- (IBAction)didTapChangeFrameButton:(UIButton *)sender {
    sender.selected = !sender.selected;
    _cycleScrollView.frame = ({
        CGRect frame = _cycleScrollView.frame;
        if (sender.selected) {
            frame.size.height += 100;
        } else {
            frame.size.height -= 100;
        }
        frame;
    });
}

// MARK: WLCycleScrollViewAccessoryProvider
- (UIView * _Nonnull )accessoryView {
    return ({
        UIPageControl *pageControl = [[UIPageControl alloc] init];
        pageControl;
    });
}

- (void)updateAccessoryView:(UIView *)accessoryView currentPageIndex:(NSUInteger)index numberOfPages:(NSUInteger)numberOfPages {
    UIPageControl *pageControl = (id)accessoryView;
    pageControl.currentPage = index;
    pageControl.numberOfPages = numberOfPages;
}

- (void)layoutAccessoryView:(UIView *)accessoryView containerBounds:(CGRect)bounds {
    UIPageControl *pageControl = (id)accessoryView;
    pageControl.frame = ({
        CGRect frame = pageControl.frame;
        frame.size = [pageControl sizeForNumberOfPages:pageControl.numberOfPages];
        frame.origin.y = CGRectGetHeight(bounds) - CGRectGetHeight(frame);
        frame.origin.x = (CGRectGetWidth(bounds) - CGRectGetWidth(frame)) / 2;
        frame;
    });
}


// MARK: WLCycleScrollViewDataSource
- (UIView * _Nonnull )cycleScrollView:(WLCycleScrollView *)cycleScrollView pageViewAtIndex:(NSInteger)index  {
    NSString *imageUrl = _images[index];
    return ({
        UIImageView *view = [[UIImageView alloc] init];
        view.layer.masksToBounds = YES;
        view.contentMode =  UIViewContentModeScaleAspectFill;
        [view sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
        view;
    });
}

- (NSUInteger)numberOfPagesInCycleScrollView:(WLCycleScrollView *)cycleScrollView {
    return _images.count;
}

// MARK: WLCycleScrollViewDelegate
- (void)cycleScrollView:(WLCycleScrollView  *)cycleScrollView didScrollToPageAtIndex:(NSUInteger)index {
    NSLog(@"did scroll to page:%@",@(index));
}

- (void)cycleScrollView:(WLCycleScrollView  *)cycleScrollView didTapPageAtIndex:(NSUInteger)index {
    NSLog(@"did tap page:%@",@(index));
}

// MARK: Accessory
- (NSArray<NSString *> *)dataArray {
    return @[@"https://m.360buyimg.com/mobilecms/s750x366_jfs/t12985/248/517565276/115964/ad8c255b/5a0d336dNd939a71e.jpg!q70.jpg",
             @"https://img1.360buyimg.com/da/jfs/t12622/186/677692331/177932/a9fd9f72/5a11569eN80399975.jpg",
             @"https://img1.360buyimg.com/da/jfs/t7777/244/4340044018/98415/3a30866c/5a0cfc03N71fd5f78.jpg",
             @"https://m.360buyimg.com/mobilecms/s750x366_jfs/t11731/210/1988376159/47894/42dba539/5a0d3455N7c7de4c9.jpg!q70.jpg",
             @"https://img12.360buyimg.com/da/jfs/t11659/224/883716413/62915/c37e53be/59fad71dN1d3e780e.jpg",
             @"https://m.360buyimg.com/mobilecms/s750x366_jfs/t12298/308/556161595/197552/b934150d/5a0e98a9Nc89396a7.jpg",
             @"https://m.360buyimg.com/mobilecms/s750x366_jfs/t7606/339/4810472870/113292/42f8484b/5a0ab927N6f58c473.jpg!q70.jpg",
             @"https://m.360buyimg.com/mobilecms/s750x366_jfs/t12835/189/506715078/107308/2053ad16/5a0d4536Nb9281188.jpg!q70.jpg"];
}

@end
