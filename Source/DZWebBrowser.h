
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

#define LOADING_TITLE NSLocalizedString(@"Loading...",@"Loading...")
#define CLOSE_BTN_TITLE NSLocalizedString(@"Close",@"Close")
#define CANCEL_ACTIONSHEET_TITLE NSLocalizedString(@"Cancel",@"Cancel")

#define ACTIONSHEET_TWITTER_BTN_TITLE NSLocalizedString(@"Tweet to Twitter",@"Tweet to Twitter")
#define ACTIONSHEET_FACEBOOK_BTN_TITLE NSLocalizedString(@"Post to Facebook",@"Post to Facebook")
#define ACTIONSHEET_MAIL_BTN_TITLE NSLocalizedString(@"Send link by Email",@"Send link by Email")
#define ACTIONSHEET_COPY_BTN_TITLE NSLocalizedString(@"Copy link",@"Copy link")

/**  */
@interface DZWebBrowser : UIViewController <UIWebViewDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

/**  */
@property (nonatomic, strong) UIWebView *webView;
/**  */
@property (nonatomic, strong) Reachability *netReach;
/**  */
@property(nonatomic, strong) NSURL *currentURL;
/**  */
@property(nonatomic, strong) NSString *stringURL;
/**  */
@property(nonatomic, strong) UIImage *navBarBkgdImage;
/**  */
@property(nonatomic, strong) UIImage *toolBarBkgdImage;

/**
 *
*/
- (id)initWebBrowserWithURL:(NSURL *)URL;

@end
