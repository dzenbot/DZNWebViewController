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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.supportedActions = DZNWebViewControllerActionAll;
    self.supportedNavigationTools = DZNWebViewControllerNavigationToolAll;
    self.allowContextualMenu = YES;
}

@end
