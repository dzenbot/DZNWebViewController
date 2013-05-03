
//  DZWebBrowser.h
//  SimpleWebBrowser
//
//  Created by Ignacio Romero Zurbuchen on 5/25/12.
//  Copyright (c) 2011 DZen Interaktiv.
//  Licence: MIT-Licence
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "Reachability.h"
#import "NJKWebViewProgress.h"

/** A simple iPhone/iPad web browser controller.
 */
@interface DZWebBrowser : UIViewController <UIWebViewDelegate, NJKWebViewProgressDelegate,
UISearchBarDelegate, UISearchDisplayDelegate,
UIActionSheetDelegate, MFMailComposeViewControllerDelegate,
UIGestureRecognizerDelegate>

/** The WebView control rendering the web contents. */
@property (nonatomic, strong) UIWebView *webView;
/** The current URL showed by the webView. */
@property (nonatomic, strong) NSURL *currentURL;
/** If YES, when loading, the navigationBar will show a ProgressView with the loading progress. No private API: AppStore Safe. */
@property (nonatomic, assign) BOOL showProgress;
/** If YES, the export icon will show on the ToolBar with sharing options (Tweet to Twitter, Post to Facebook, etc.) */
@property (nonatomic, assign) BOOL allowSharing;
/** If YES, a search icon is placed on the right top corner inside the navigation bar, so the user can search for a specific URL address. */
@property (nonatomic, assign) BOOL allowSearch;
/** The custom resource bundle name.
 * Duplicate DZWebBrowser.bundle file into your project files, and replace its contents (images and localized strings) keeping the same file names or keys.
 * You should also rename the *.bundle file.
 * If no custom resource bundle name is set, the default one will be applied.
 */
@property (nonatomic, strong) NSString *resourceBundleName;
/** Set this value to YES, if the browser is pushed inside a UINavigationController stack. */
@property (nonatomic, getter=isPushed) BOOL pushed;

/* Returns a DZWebBrowser instanced initialized with a specific URL.
 *
 * @param URL An NSURL object.
 * @returns The new instance.
 */
- (id)initWebBrowserWithURL:(NSURL *)URL;

/**
 * Sets the navigationBar Bar background image of the web browser.
 * If a generic UIAppearance has been applied, this will take no effect.
 *
 * @param image The image to be applied.
 */
- (void)setNavBarBkgdImage:(UIImage *)image;

/**
 * Sets the toolBar background image of the web browser.
 * If a generic UIAppearance has been applied, this will take no effect.
 *
 * @param image The image to be applied.
 */
- (void)setToolBarBkgdImage:(UIImage *)image;

@end
