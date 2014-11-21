//
//  ViewController.m
//  Sample
//
//  Created by Ignacio on 3/29/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)loadView
{
    [super loadView];
    
    self.supportedActions = DZNWebViewControllerActionAll;
    self.supportedNavigationTools = DZNWebViewControllerNavigationToolAll;
    self.loadingStyle = DZNWebViewControllerLoadingStyleActivityIndicator;
    self.allowHistory = YES;
}

@end
