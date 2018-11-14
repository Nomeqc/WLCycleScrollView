//
//  MyCycleScrollView.h
//  WLCycleScrollView_Example
//
//  Created by Fallrainy on 2018/11/12.
//  Copyright © 2018 Fallrainy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLCycleScrollView : UIView

@property (nonatomic) BOOL stopScroll;
@property (nonatomic) BOOL autoScrollEnabled;

@property (nonatomic, weak) id delegate;
@property (nonatomic, weak) id dataSource;


@end
