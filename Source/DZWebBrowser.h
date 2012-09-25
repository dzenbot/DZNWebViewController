
//  DZWebBrowser.h
//  SimpleWebBrowser
//
//  Created by Ignacio Romero Zurbuchen on 5/25/12.
//  Copyright (c) 2011 DZen Interaktiv.
//  Licence: MIT-Licence
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

@interface DZWebBrowser : UIViewController <UIWebViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) Reachability *netReach;

@property(nonatomic, strong) NSURL *currentURL;
@property(nonatomic, strong) NSString *stringURL;

@property(nonatomic, strong) UIImage *navBarBkgdImage;
@property(nonatomic, strong) UIImage *toolBarBkgdImage;

- (id)initWebBrowserWithURL:(NSURL *)URL;

- (void)reachabilityChanged;
- (BOOL)networkReachable;

@end
