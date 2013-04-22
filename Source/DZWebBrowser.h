
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

#define OS_SUPERIOR_OR_EQUAL_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:@"6.0" options:NSNumericSearch] == NSOrderedDescending || NSOrderedSame)

#define LOADING_TITLE NSLocalizedString(@"Loading...",@"Loading...")
#define CLOSE_BTN_TITLE NSLocalizedString(@"Close",@"Close")
#define CANCEL_ACTIONSHEET_TITLE NSLocalizedString(@"Cancel",@"Cancel")

#define ACTIONSHEET_TWITTER_BTN_TITLE NSLocalizedString(@"Tweet to Twitter",@"Tweet to Twitter")
#define ACTIONSHEET_FACEBOOK_BTN_TITLE NSLocalizedString(@"Post to Facebook",@"Post to Facebook")
#define ACTIONSHEET_MAIL_BTN_TITLE NSLocalizedString(@"Send link by Email",@"Send link by Email")
#define ACTIONSHEET_COPY_BTN_TITLE NSLocalizedString(@"Copy link",@"Copy link")

#define ALERT_NO_INTERNET_TITLE NSLocalizedString(@"Internet Error",@"Internet Error")
#define ALERT_NO_INTERNET_MESSAGE NSLocalizedString(@"No Internet detected. Please check your connection settings.",@"No Internet detected. Please check your connection settings.")
#define ALERT_OK NSLocalizedString(@"OK",@"OK")


/** A simple iPhone/iPad web browser control.
 */
@interface DZWebBrowser : UIViewController <UIWebViewDelegate, NJKWebViewProgressDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

/** The WebView control rendering the web contents. */
@property (nonatomic, strong) UIWebView *webView;
/** The current URL showed by the webView. */
@property(nonatomic, strong) NSURL *currentURL;
/** If YES, when loading, the navigationBar will show a ProgressView with the loading progress. No private API: AppStore Safe. */
@property(nonatomic) BOOL showProgress;

/**
 *
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

/** Sets custom toolbar images for the web browser controls.
 * Duplicate DZWebBrowser.bundle file into your project files, and replace its content keeping the same file names. You should also rename the *.bundle file.
 * If no custom images are set, the default ones will be applied.
 *
 * @param bundle The NSBundle object that represents the location the custom web browser control resources.
 */
- (void)setWebControlsBundle:(NSBundle *)bundle;

@end
