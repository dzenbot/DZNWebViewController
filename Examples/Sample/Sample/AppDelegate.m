//
//  AppDelegate.m
//  Sample
//
//  Created by Ignacio on 3/27/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    NSURL *URL = [NSURL URLWithString:@"https://github.com/"];
    self.webViewController = [[DZNWebViewController alloc] initWithURL:URL];
    self.webViewController.loadingStyle = DZNWebViewControllerLoadingStyleNone;
    self.webViewController.supportedActions = DZNWebViewControllerActionShareLink;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.webViewController];
    self.window.rootViewController = navigationController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
