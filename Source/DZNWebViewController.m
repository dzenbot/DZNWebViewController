//
//  DZNWebViewController.m
//  DZNWebViewController
//
//  Created by Ignacio on 10/25/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//

#import "DZNWebViewController.h"

#import <NJKWebViewProgress/NJKWebViewProgressView.h>
#import <NJKWebViewProgress/NJKWebViewProgress.h>

//#import <UIBarButtonItem-SystemItem/UIBarButtonItem+SystemItem.h>
//#import <iOSBlocks/iOSBlocks.h>

@interface DZNWebViewController () <UIWebViewDelegate, NJKWebViewProgressDelegate>
{
    NJKWebViewProgress *_progressProxy;
    
    UIBarButtonItem *_actionBarItem;
    UIBarButtonItem *_backwardBarItem;
    UIBarButtonItem *_forwardBarItem;
    UIBarButtonItem *_loadingBarItem;
    
    int _loadBalance;
    BOOL _didLoadContent;
}
@property (nonatomic, strong) NJKWebViewProgressView *progressView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@end

@implementation DZNWebViewController
@synthesize URL = _URL;

- (id)initWithURL:(NSURL *)URL
{
    NSParameterAssert(URL);
    
    self = [super init];
    if (self) {
        _URL = URL;
    }
    return self;
}


#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    
    self.view = self.webView;
    self.automaticallyAdjustsScrollViewInsets = YES;
    
//    [UIApplication sharedApplication].keyWindow.tintColor = [UIColor whiteColor];
    self.toolbarItems = self.controlItems;
//    [UIApplication sharedApplication].keyWindow.tintColor = [UIColor windowTintColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.supportedActions > 0) {
        _actionBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(presentActivityController:)];
        [self.navigationItem setRightBarButtonItem:_actionBarItem];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:NO];
    
//    UIImage *toolbarBkgd = [UIImage imageWithColor:[UIColor colorWithWhite:0.1 alpha:1.0] andSize:CGSizeMake(44.0, 44.0)];
//    [self.navigationController.toolbar setBackgroundImage:toolbarBkgd forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!_didLoadContent) {
        [self startRequestWithURL:_URL];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
    [self.navigationController setToolbarHidden:YES animated:animated];
    [self cleanProgressViewAnimated:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    
    [self stopLoading];
}


#pragma mark - Getter methods

- (UIWebView *)webView
{
    if (!_webView)
    {
        _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _webView.suppressesIncrementalRendering = NO;
        _webView.paginationBreakingMode = UIWebPaginationBreakingModePage;
        _webView.scalesPageToFit = YES;
        _webView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        if (_loadingStyle == DZNWebViewControllerLoadingStyleProgressView)
        {
            _progressProxy = [[NJKWebViewProgress alloc] init];
            _webView.delegate = _progressProxy;
            _progressProxy.webViewProxyDelegate = self;
            _progressProxy.progressDelegate = self;
        }
        else {
            _webView.delegate = self;
        }
    }
    return _webView;
}

- (NJKWebViewProgressView *)progressView
{
    if (!_progressView && _loadingStyle == DZNWebViewControllerLoadingStyleProgressView)
    {
        CGFloat progressBarHeight = 2.5f;
        CGSize navigationBarSize = self.navigationController.navigationBar.bounds.size;
        CGRect barFrame = CGRectMake(0, navigationBarSize.height - progressBarHeight, navigationBarSize.width, progressBarHeight);
        _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
        
        [self.navigationController.navigationBar addSubview:_progressView];
    }
    return _progressView;
}

- (UIActivityIndicatorView *)activityIndicatorView
{
    if (!_activityIndicatorView)
    {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityIndicatorView.hidesWhenStopped = YES;
    }
    return _activityIndicatorView;
}

- (NSArray *)controlItems
{
//    _backwardBarItem = [[UIBarButtonItem alloc] initWithBarButtonPrivateItem:UIBarButtonSystemItemBackward target:self action:@selector(goBack:)];
//    _backwardBarItem.enabled = NO;
//    
//    _forwardBarItem = [[UIBarButtonItem alloc] initWithBarButtonPrivateItem:UIBarButtonSystemItemForward target:self action:@selector(goForward:)];
//    _forwardBarItem.enabled = NO;
//    
//    _loadingBarItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicatorView];
//    
//    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
//    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
//    fixedSpace.width = kMarginMedium;
//    
//    return @[_backwardBarItem,fixedSpace,_forwardBarItem,flexibleSpace,_loadingBarItem];
    
    return nil;
}

- (NSURL *)URL
{
    return _webView.request.URL;
}


#pragma mark - Setter methods

- (NSString *)title
{
    NSString *js = @"document.body.style.webkitTouchCallout = 'none'; document.getElementsByTagName('title')[0].textContent;";
    return [_webView stringByEvaluatingJavaScriptFromString:js];
}

- (void)setURL:(NSURL *)URL
{
    [self startRequestWithURL:URL];
}

- (void)setViewTitle:(NSString *)title
{
    UILabel *label = (UILabel *)self.navigationItem.titleView;
    
    if (!label || ![label isKindOfClass:[UILabel class]]) {
        label = [UILabel new];
        label.numberOfLines = 2;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [[UINavigationBar appearance].titleTextAttributes objectForKey:NSFontAttributeName];
        label.textColor = [[UINavigationBar appearance].titleTextAttributes objectForKey:NSForegroundColorAttributeName];
        self.navigationItem.titleView = label;
    }
    
    if (title) {
        label.text = title;
        CGSize barSize = self.navigationController.navigationBar.frame.size;
        label.frame = CGRectMake(0, 0, roundf(barSize.width/2), barSize.height);
    }
}

/*
 * Sets the request errors with an alert view.
 */
- (void)setLoadingError:(NSError *)error
{
    switch (error.code) {
        case NSURLErrorTimedOut:
        case NSURLErrorUnknown:
        case NSURLErrorCancelled:
            return;
    }
    
    [self setActivityIndicatorsVisible:NO];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
    [alert show];
}

/*
 * Toggles the activity indicators on the status bar & footer view.
 */
- (void)setActivityIndicatorsVisible:(BOOL)visible
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = visible;
    
    if (visible) {
        [_activityIndicatorView startAnimating];
    }
    else {
        [_activityIndicatorView stopAnimating];
    }
}


#pragma mark - DZNWebViewController methods

- (void)startRequestWithURL:(NSURL *)URL
{
    _loadBalance = 0;
    [_webView loadRequest:[[NSURLRequest alloc] initWithURL:URL]];
}

- (void)goBack:(id)sender
{
    if ([_webView canGoBack]) {
        [_webView goBack];
    }
}

- (void)goForward:(id)sender
{
    if ([_webView canGoForward]) {
        [_webView goForward];
    }
}

- (void)presentActivityController:(id)sender
{
//    NSMutableArray *titles = [[NSMutableArray alloc] initWithObjects:NSLocalizedString(@"Mail Link", nil), NSLocalizedString(@"Copy Link", nil),NSLocalizedString(@"Open in Safari", nil), nil];
//    
//    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"googlechrome://"]]) {
//        [titles addObject:NSLocalizedString(@"Open in Chrome", nil)];
//    }
//
//    [UIActionSheet actionSheetWithTitle:nil buttonTitles:titles
//                             showInView:self.navigationController.toolbar
//                              onDismiss:^(int buttonIndex, NSString *buttonTitle) {
//                                  if (buttonIndex == 0) [self mailLink];
//                                  else if (buttonIndex == 1) [self copyLink];
//                                  else if (buttonIndex == 2) [self openInSafari];
//                                  else if (buttonIndex == 3) [self openInChrome];
//                              }];
}

- (void)mailLink
{
//    NSMutableString *message = [NSMutableString stringWithFormat:@"<a href=%@>%@</a>", [self.URL absoluteString], [self.URL absoluteString]];
//    
//    if (_applicationUrl.length > 0) {
//        [message appendString:@"</br></br>"];
//        [message appendFormat:NSLocalizedString(@"Download the official %@ app <a href=%@>here</a>", nil), _applicationName, _applicationUrl];
//    }
//    
//    NSString *subject = (_applicationName.length > 0) ? [NSString stringWithFormat:NSLocalizedString(@"Link from %@", nil), _applicationName] : @"";
//    
//    [MFMailComposeViewController mailWithSubject:subject
//                                         message:message
//                                      recipients:nil
//                                      onCreation:^(UIViewController *controller) {
//                                          [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:controller animated:YES completion:NULL];
//                                      } onFinish:^(UIViewController *controller, NSError *error) {
//                                          [controller dismissViewControllerAnimated:YES completion:NULL];
//                                      }];
}

- (void)copyLink
{
    if (self.URL) {
        [[UIPasteboard generalPasteboard] setURL:self.URL];
    }
}

- (void)openInSafari
{
    if ([[UIApplication sharedApplication] canOpenURL:self.URL]) {
        [[UIApplication sharedApplication] openURL:self.URL];
    }
}

- (void)openInChrome
{
    NSString *scheme = self.URL.scheme;
    
    // Replace the URL Scheme with the Chrome equivalent.
    NSString *chromeScheme = nil;
    if ([scheme isEqualToString:@"http"]) chromeScheme = @"googlechrome";
    else if ([scheme isEqualToString:@"https"]) chromeScheme = @"googlechromes";
    
    // Proceed only if a valid Google Chrome URI Scheme is available.
    if (chromeScheme) {
        NSString *absoluteString = [self.URL absoluteString];
        NSRange rangeForScheme = [absoluteString rangeOfString:@":"];
        NSString *urlNoScheme = [absoluteString substringFromIndex:rangeForScheme.location];
        NSString *chromeURLString = [chromeScheme stringByAppendingString:urlNoScheme];
        NSURL *chromeURL = [NSURL URLWithString:chromeURLString];
        
        // Open the URL with Chrome.
        [[UIApplication sharedApplication] openURL:chromeURL];
    }
}

- (void)cleanProgressViewAnimated:(BOOL)animated
{
    if (!_progressView) {
        return;
    }
    
    [UIView animateWithDuration:animated ? 0.25 : 0.0
                     animations:^{
                         _progressView.alpha = 0;
                     } completion:^(BOOL finished) {
                         [_progressView removeFromSuperview];
                     }];
}

- (void)stopLoading
{
    [self.webView stopLoading];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


#pragma mark - UIWebViewDelegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (request.URL) {
        return YES;
    }
    
    return NO;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    // load balance is use to see if the load was completed end of the site
    _loadBalance++;
    
    if (_loadBalance == 1) {
        [_activityIndicatorView startAnimating];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
    
    _backwardBarItem.enabled = [_webView canGoBack];
    _forwardBarItem.enabled = [_webView canGoForward];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (_loadBalance >= 1) _loadBalance--;
    else if (_loadBalance < 0) _loadBalance = 0;

    if (_loadBalance == 0) {
        _didLoadContent = YES;
        [_activityIndicatorView stopAnimating];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    
    _backwardBarItem.enabled = [_webView canGoBack];
    _forwardBarItem.enabled = [_webView canGoForward];
    
    [self setViewTitle:[self title]];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    _loadBalance = 0;
    [self setLoadingError:error];
}


#pragma mark - View lifeterm

- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [self.progressView setProgress:progress animated:YES];
}


#pragma mark - View lifeterm

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)dealloc
{
    _actionBarItem = nil;
    _backwardBarItem = nil;
    _forwardBarItem = nil;
    _loadingBarItem = nil;

    _activityIndicatorView = nil;
    
    _webView = nil;
    _URL = nil;
}


#pragma mark - View Auto-Rotation

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end
