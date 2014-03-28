//
//  AppDelegate.m
//  Sample
//
//  Created by Ignacio on 3/27/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

+ (void)initialize
{
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15.0],
                                                           NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    NSURL *URL = [NSURL URLWithString:@"https://github.com/"];
    self.webViewController = [[DZNWebViewController alloc] initWithURL:URL];
    self.webViewController.loadingStyle = DZNWebViewControllerLoadingStyleProgressView;
    self.webViewController.supportedActions = DZNWebViewControllerActionShareLink;
    
    self.webViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:nil action:NULL];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.webViewController];
    self.window.rootViewController = navigationController;
    self.window.tintColor = [UIColor orangeColor];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
