//
//  AppDelegate.h
//  SQLiteTutorial
//
//  Created by Jenn on 5/2/13.
//  Copyright (c) 2013 Jenn. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) UITabBarController *tabController;
@end
