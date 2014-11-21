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
#import <WebKit/WebKit.h>

#import "DZNWebView.h"

/**
 Types of network loading style.
 */
typedef NS_OPTIONS(NSUInteger, DZNWebViewControllerLoadingStyle) {
    DZNWebViewControllerLoadingStyleNone,
    DZNWebViewControllerLoadingStyleProgressView,
    DZNWebViewControllerLoadingStyleActivityIndicator
};

/**
 Types of supported navigation tools.
 */
typedef NS_OPTIONS(NSUInteger, DZNWebViewControllerNavigationTools) {
    DZNWebViewControllerNavigationToolAll = -1,
    DZNWebViewControllerNavigationToolNone = 0,
    DZNWebViewControllerNavigationToolBackward = (1 << 0),
    DZNWebViewControllerNavigationToolForward = (1 << 1),
    DZNWebViewControllerNavigationToolStopRefresh = (1 << 2),
};

/**
 Types of supported actions (i.e. Share & Copy link, Add to Reading List, Open in Safari/Chrome/Opera/Dolphin).
 */
typedef NS_OPTIONS(NSUInteger, DZNWebViewControllerActions) {
    DZNWebViewControllerActionAll = -1,
    DZNWebViewControllerActionNone = 0,
    DZNWebViewControllerActionShareLink = (1 << 0),
    DZNWebViewControllerActionCopyLink = (1 << 1),
    DZNWebViewControllerActionReadLater = (1 << 2),
    DZNWebViewControllerActionOpenSafari = (1 << 3),
    DZNWebViewControllerActionOpenChrome = (1 << 4),
    DZNWebViewControllerActionOpenOperaMini = (1 << 5),
    DZNWebViewControllerActionOpenDolphin = (1 << 6),
};

/**
 A very simple web browser with useful navigation and exportation tools.
 */
@interface DZNWebViewController : UIViewController <DZNNavigationDelegate, WKUIDelegate>

/** The web view that the controller manages. */
@property (nonatomic, strong) DZNWebView *webView;
/** The URL identifying the location of the content to load. */
@property (nonatomic, readwrite) NSURL *URL;
/** The loading visual style, using a progress bar or a network activity indicator. Default is DZNWebViewControllerLoadingStyleProgressView. */
@property (nonatomic, readwrite) DZNWebViewControllerLoadingStyle loadingStyle;
/** The supported navigation tool bar items. Default is DZNWebViewControllerNavigationToolAll. */
@property (nonatomic, readwrite) DZNWebViewControllerNavigationTools supportedNavigationTools;
/** The supported actions like sharing and copy link, add to reading list, open in Safari, etc. Default is DZNWebViewControllerActionAll. */
@property (nonatomic, readwrite) DZNWebViewControllerActions supportedActions;
/** YES if long pressing the backward and forward buttons the navigation history is displayed. Default is YES. */
@property (nonatomic) BOOL allowHistory;

@property (nonatomic, assign) UIImage *backwardButtonImage UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) UIImage *backwardButtonLandscapeImage UI_APPEARANCE_SELECTOR;

@property (nonatomic, assign) UIImage *forwardButtonImage UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) UIImage *forwardButtonLandscapeImage UI_APPEARANCE_SELECTOR;

@property (nonatomic, assign) UIImage *stopButtonImage UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) UIImage *stopButtonLandscapeImage UI_APPEARANCE_SELECTOR;

@property (nonatomic, assign) UIImage *reloadButtonImage UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) UIImage *reloadButtonLandscapeImage UI_APPEARANCE_SELECTOR;

@property (nonatomic, assign) UIImage *actionButtonImage UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) UIImage *actionButtonLandscapeImage UI_APPEARANCE_SELECTOR;

///------------------------------------------------
/// @name Initialization
///------------------------------------------------

/**
 Initializes and returns a newly created webview controller with an initial HTTP URL to be requested as soon as the view appears.
 
 @param URL The HTTP URL to be requested.
 @returns The initialized webview controller.
 */
- (instancetype)initWithURL:(NSURL *)URL;

/**
 Initializes and returns a newly created webview controller for local HTML navigation.
 
 @param URL The file URL of the main html.
 @returns The initialized webview controller.
 */
- (instancetype)initWithFileURL:(NSURL *)URL;


///------------------------------------------------
/// @name Delegate Methods Requiring Super
///------------------------------------------------

- (void)startRequestWithURL:(NSURL *)URL NS_REQUIRES_SUPER;

@end
