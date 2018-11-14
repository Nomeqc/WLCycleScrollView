//
//  WLAppDelegate.m
//  WLCycleScrollView
//
//  Created by Fallrainy on 11/18/2017.
//  Copyright (c) 2017 Fallrainy. All rights reserved.
//

#import "WLAppDelegate.h"

@implementation WLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    for (NSInteger i = 0; i < 100; i++) {
//        NSUInteger j = i & 0xFFFFFFFFFFFFFFFELL;
//        NSLog(@"i:%@==>%@",@(i),@(j));
//        NSLog(@"more:%@", @(i - i % 2));
        
        NSInteger midIndex = [self currentViewMiddleIndexForCount:i];
        NSLog(@"count:%@,midIndex:%@", @(i), @(midIndex));
        NSLog(@"more:%@", @(MAX(0, (i / 2 + i % 2) - 1)));
    }
    NSInteger i = 0;
    
    
    NSNumber *n1 = @(1);
    NSNumber *n2 = @(2);
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:n1];
    [array addObject:n2];
    [array addObject:n1];
    [array addObject:n1];
    
    return YES;
}

- (NSInteger)currentViewMiddleIndexForCount:(NSUInteger)count {
    NSInteger currentViewCount = count;
    
    NSInteger v3 = currentViewCount;
    NSInteger v4 = 0;
    if (v3 >= 0) {
        v4 = v3;
    } else {
        v4 = v3 + 1;
    }
    NSInteger v5 = currentViewCount;
    NSInteger v6 = 0;
    if (v5 >= 0) {
        v6 = v5;
    } else {
        v6 = v5 + 1;
    }
    if (v5 - (v6 - v6 % 2) + v4 / 2 < 2) {
        return 0;
    }
    NSInteger v7 = currentViewCount;
    NSInteger v8 = 0;
    if (v7 >= 0) {
        v8 = v7;
    } else {
        v8 = v7 + 1;
    }
    NSInteger v9 = currentViewCount;
    NSInteger v10 = 0;
    if (v9 >= 0) {
        v10 = v9;
    } else {
        v10 = v9 + 1;
    }
    return v9 - (v10 - v10 % 2) + v8 / 2 - 1;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
