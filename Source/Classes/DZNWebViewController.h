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
typedef NS_OPTIONS(NSUInteger, DZNWebLoadingStyle) {
    DZNWebLoadingStyleNone,
    DZNWebLoadingStyleProgressView,
    DZNWebLoadingStyleActivityIndicator
};

/**
 Types of supported navigation tools.
 */
typedef NS_OPTIONS(NSUInteger, DZNWebNavigationTools) {
    DZNWebNavigationToolAll = -1,
    DZNWebNavigationToolNone = 0,
    DZNWebNavigationToolBackward = (1 << 0),
    DZNWebNavigationToolForward = (1 << 1),
    DZNWebNavigationToolStopReload = (1 << 2),
};

/**
 Types of supported actions (i.e. Share & Copy link, Add to Reading List, Open in Safari/Chrome/Opera/Dolphin).
 */
typedef NS_OPTIONS(NSUInteger, DZNsupportedWebActions) {
    DZNWebActionAll = -1,
    DZNWebActionNone = 0,
    DZNsupportedWebActionshareLink = (1 << 0),
    DZNWebActionCopyLink = (1 << 1),
    DZNWebActionReadLater = (1 << 2),
    DZNWebActionOpenSafari = (1 << 3),
    DZNWebActionOpenChrome = (1 << 4),
    DZNWebActionOpenOperaMini = (1 << 5),
    DZNWebActionOpenDolphin = (1 << 6),
};

/**
 A very simple web browser with useful navigation and tooling features.
 */
@interface DZNWebViewController : UIViewController <DZNNavigationDelegate, WKUIDelegate, UITableViewDataSource, UITableViewDelegate>

/** The web view that the controller manages. */
@property (nonatomic, strong) DZNWebView *webView;
/** The URL identifying the location of the content to load. */
@property (nonatomic, readwrite) NSURL *URL;
/** The loading visual style, using a progress bar or a network activity indicator. Default is DZNWebLoadingStyleProgressView. */
@property (nonatomic, readwrite) DZNWebLoadingStyle loadingStyle;
/** The supported navigation tool bar items. Default is DZNWebNavigationToolAll. */
@property (nonatomic, readwrite) DZNWebNavigationTools supportedWebNavigationTools;
/** The supported actions like sharing and copy link, add to reading list, open in Safari, etc. Default is DZNWebActionAll. */
@property (nonatomic, readwrite) DZNsupportedWebActions supportedWebActions;
/** YES if long pressing the backward and forward buttons the navigation history is displayed. Default is YES. */
@property (nonatomic) BOOL allowHistory;
/** YES if both, the navigation and tool bars should hide when panning vertically. Default is YES. */
@property (nonatomic) BOOL hideBarsWithGestures;

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

/**
 Starts loading a new request. Useful to programatically update the web content.
 
 @param URL The HTTP or file URL to be requested.
 */
- (void)startRequestWithURL:(NSURL *)URL NS_REQUIRES_SUPER;


///------------------------------------------------
/// @name Appearance customisation
///------------------------------------------------

// The back button displayed on the tool bar (requieres DZNWebNavigationToolBackward)
@property (nonatomic, assign) UIImage *backwardButtonImage UI_APPEARANCE_SELECTOR;
// The forward button displayed on the tool bar (requieres DZNWebNavigationToolForward)
@property (nonatomic, assign) UIImage *forwardButtonImage UI_APPEARANCE_SELECTOR;
// The stop button displayed on the tool bar (requieres DZNWebNavigationToolStopReload)
@property (nonatomic, assign) UIImage *stopButtonImage UI_APPEARANCE_SELECTOR;
// The reload button displayed on the tool bar (requieres DZNWebNavigationToolStopReload)
@property (nonatomic, assign) UIImage *reloadButtonImage UI_APPEARANCE_SELECTOR;
// The action button displayed on the navigation bar (requieres at least 1 DZNsupportedWebActions value)
@property (nonatomic, assign) UIImage *actionButtonImage UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) UIImage *actionButtonLandscapeImage UI_APPEARANCE_SELECTOR;


///------------------------------------------------
/// @name Delegate Methods Requiring Super
///------------------------------------------------

// DZNNavigationDelegate
- (void)webView:(DZNWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation NS_REQUIRES_SUPER;
- (void)webView:(DZNWebView *)webView didCommitNavigation:(WKNavigation *)navigation NS_REQUIRES_SUPER;
- (void)webView:(DZNWebView *)webView didUpdateProgress:(CGFloat)progress NS_REQUIRES_SUPER;
- (void)webView:(DZNWebView *)webView didFinishNavigation:(WKNavigation *)navigation NS_REQUIRES_SUPER;
- (void)webView:(DZNWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error NS_REQUIRES_SUPER;

// WKUIDelegate
- (DZNWebView *)webView:(DZNWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures NS_REQUIRES_SUPER;

// UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView NS_REQUIRES_SUPER;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section NS_REQUIRES_SUPER;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath NS_REQUIRES_SUPER;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath NS_REQUIRES_SUPER;

// UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath NS_REQUIRES_SUPER;

@end
