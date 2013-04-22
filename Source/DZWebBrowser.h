
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


/**  */
@interface DZWebBrowser : UIViewController <UIWebViewDelegate, NJKWebViewProgressDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
/**  */
@property (nonatomic, strong) UIWebView *webView;
/**  */
@property(nonatomic, strong) NSURL *currentURL;
/**  */
@property(nonatomic) BOOL showProgress;

/**
 *
*/
- (id)initWebBrowserWithURL:(NSURL *)URL;

/**
 *
 */
- (void)setNavBarBkgdImage:(UIImage *)navBarBkgdImage;

/**
 *
 */
- (void)setToolBarBkgdImage:(UIImage *)toolBarBkgdImage;

/**
 *
 */
- (void)setWebControlsBundle:(NSBundle *)bundle;

@end
