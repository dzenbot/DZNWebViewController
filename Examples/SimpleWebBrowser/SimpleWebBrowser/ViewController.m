//
//  ViewController.m
//  SimpleWebBrowser
//
//  Created by Ignacio on 9/26/12.
//  Copyright (c) 2012 DZen Interaktiv. All rights reserved.
//  Licence: MIT-Licence
//

#import "ViewController.h"

@interface ViewController ()
@end

@implementation ViewController

- (IBAction)openBrowser:(id)sender
{
    NSURL *URL = [NSURL URLWithString:_textField.text];
    
    DZWebBrowser *webBrowser = [[DZWebBrowser alloc] initWebBrowserWithURL:URL];
    webBrowser.showProgress = NO;
    webBrowser.allowSharing = NO;
//    webBrowser.resourceBundleName = @"custom-controls";

    UINavigationController *webBrowserNC = [[UINavigationController alloc] initWithRootViewController:webBrowser];
    [self presentViewController:webBrowserNC animated:YES completion:NULL];
}

@end
