//
//  ViewController.m
//  Sample
//
//  Created by Ignacio on 3/29/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//

#import "ViewController.h"
#import "DZNWebViewController.h"

@interface ViewController () {
    DZNWebViewController *_controller;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"Open DZNWebViewController" forState:UIControlStateNormal];
    [button setFrame:[UIScreen mainScreen].bounds];
    [button addTarget:self action:@selector(presentWebViewController:) forControlEvents:UIControlEventTouchUpInside];
    [button setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.view addSubview:button];
}

- (void)presentWebViewController:(id)sender
{
    NSURL *URL = [NSURL URLWithString:@"http://thenextweb.com/"];
    
    _controller = [[DZNWebViewController alloc] initWithURL:URL];
    _controller.supportedActions = DZNWebViewControllerActionAll;
    _controller.supportedNavigationTools = DZNWebViewControllerNavigationToolAll;
    _controller.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissWebViewController:)];
    _controller.allowContextualMenu = YES;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:_controller];
    
    [self presentViewController:navigationController animated:YES completion:NULL];
}

- (void)dismissWebViewController:(id)sender
{
    [_controller dismissViewControllerAnimated:YES completion:^{
        _controller = nil;
    }];
}

@end
