//
//  ViewController.m
//  Sample
//
//  Created by Ignacio on 3/29/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIScrollViewDelegate>
@end

@implementation ViewController

- (void)loadView
{
    [super loadView];
    
    self.supportedWebActions = DZNWebActionAll;
    self.supportedWebNavigationTools = DZNWebNavigationToolAll;
    self.loadingStyle = DZNWebLoadingStyleProgressView;
    self.hideBarsWithGestures = YES;
    self.allowHistory = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
//    
//    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
//    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//    
//    self.navigationController.toolbar.barTintColor = [UIColor blackColor];
//    self.navigationController.toolbar.tintColor = [UIColor whiteColor];
}

@end
