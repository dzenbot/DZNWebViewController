//
//  DZNWebViewController.h
//  DZNWebViewController
//  https://github.com/dzenbot/DZNWebViewController
//
//  Created by Ignacio Romero Zurbuchen on 10/25/13.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, DZNWebViewControllerActions) {
    DZNWebViewControllerActionAll = -1,
    DZNWebViewControllerActionNone = 0,
    DZNWebViewControllerActionShareLink = (1 << 0),
    DZNWebViewControllerActionCopyLink = (1 << 1),
    DZNWebViewControllerActionReadLater = (1 << 2),
    DZNWebViewControllerActionOpenSafari = (1 << 3),
    DZNWebViewControllerActionOpenChrome = (1 << 4),
    DZNWebViewControllerActionOpenOperaMini = (1 << 5)
};

typedef NS_OPTIONS(NSUInteger, DZNWebViewControllerLoadingStyle) {
    DZNWebViewControllerLoadingStyleNone,
    DZNWebViewControllerLoadingStyleProgressView,
    DZNWebViewControllerLoadingStyleActivityIndicator
};

/**
 * A very simple web browser with useful navigation and exportation tools.
 */
@interface DZNWebViewController : UIViewController

/** The main web view. */
@property (nonatomic, strong) UIWebView *webView;
/** The URL identifying the location of the content to load. */
@property (nonatomic, readonly) NSURL *URL;
/**  */
@property (nonatomic) DZNWebViewControllerLoadingStyle loadingStyle;
/** The application's name to be used for promotion when sending link by email. */
@property (nonatomic, copy) NSString *applicationName;
/** The application's store url to be used for promotion when sending link by email. */
@property (nonatomic, copy) NSString *applicationUrl;
/**  */
@property (nonatomic) DZNWebViewControllerActions supportedActions;
/**  */
@property (nonatomic, strong) UIColor *toolbarBackgroundColor;
/**  */
@property (nonatomic, strong) UIColor *toolbarTintColor;

/**
 * Initializes and returns a newly created webview controller with an initial URL to be requested as soon as the view appears.
 *
 * @param URL The URL to be requested.
 * @returns The initialized webview controller.
 */
- (id)initWithURL:(NSURL *)URL;

@end
