//
//  DZNWebViewController.m
//  DZNWebViewController
//
//  Created by Ignacio on 10/25/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//

#import "DZNWebViewController.h"
#import "DZNPolyActivity.h"

#import <NJKWebViewProgress/NJKWebViewProgressView.h>
#import <NJKWebViewProgress/NJKWebViewProgress.h>

#import "UIBarButtonItem+SystemGlyph.h"

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
        _toolbarBackgroundColor = [UIColor blackColor];
        _toolbarTintColor = [UIColor whiteColor];
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.supportedActions > 0) {
        _actionBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(presentActivityController:)];
        [self.navigationItem setRightBarButtonItem:_actionBarItem];
    }
    
    self.toolbarItems = self.navigationItems;
    
    self.view = self.webView;
    self.automaticallyAdjustsScrollViewInsets = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:NO];

    self.navigationController.toolbar.barTintColor = _toolbarBackgroundColor;
    self.navigationController.toolbar.tintColor = [UIColor whiteColor];

    self.navigationController.view.backgroundColor = [UIColor whiteColor];
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
        _webView.backgroundColor = [UIColor whiteColor];
        
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
        _activityIndicatorView.color = _toolbarTintColor;
    }
    return _activityIndicatorView;
}

- (NSArray *)navigationItems
{
    _backwardBarItem = [[UIBarButtonItem alloc] initWithBarButtonPrivateItem:UIBarButtonSystemGlyphBackward target:self action:@selector(goBack:)];
    _backwardBarItem.enabled = NO;
    
    _forwardBarItem = [[UIBarButtonItem alloc] initWithBarButtonPrivateItem:UIBarButtonSystemGlyphForward target:self action:@selector(goForward:)];
    _forwardBarItem.enabled = NO;
    
    if (_loadingStyle == DZNWebViewControllerLoadingStyleActivityIndicator) {
        _loadingBarItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicatorView];
    }
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
    fixedSpace.width = 20.0;
    
    NSMutableArray *items = [NSMutableArray arrayWithArray:@[_backwardBarItem,fixedSpace,_forwardBarItem,flexibleSpace]];
    if (_loadingBarItem) {
        [items addObject:_loadingBarItem];
    }
    
    return items;
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
    
    if (_loadingStyle != DZNWebViewControllerLoadingStyleActivityIndicator) {
        return;
    }
    
    if (visible) [_activityIndicatorView startAnimating];
    else [_activityIndicatorView stopAnimating];
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

- (NSArray *)excludedActivityTypes
{
    NSMutableArray *types = [NSMutableArray arrayWithArray:@[UIActivityTypePrint, UIActivityTypeAssignToContact,
                                                             UIActivityTypeSaveToCameraRoll, UIActivityTypePostToVimeo,
                                                             UIActivityTypePostToFlickr, UIActivityTypeCopyToPasteboard]];
    
    if ((_supportedActions & DZNWebViewControllerActionShareLink) == 0) {
        [types addObjectsFromArray:@[UIActivityTypeMail, UIActivityTypeMessage,
                                     UIActivityTypePostToFacebook, UIActivityTypePostToTwitter,
                                     UIActivityTypePostToWeibo, UIActivityTypePostToTencentWeibo,
                                     UIActivityTypeAirDrop]];
    }
    if ((_supportedActions & DZNWebViewControllerActionReadLater) == 0) {
        [types addObject:UIActivityTypeAddToReadingList];
    }

    return types;
}

- (NSArray *)applicationActivities
{
    NSMutableArray *activities = [NSMutableArray new];
    
    if ((_supportedActions & DZNWebViewControllerActionCopyLink) > 0) {
        [activities addObject:[DZNPolyActivity activityWithType:DZNPolyActivityTypeCopyLink]];
    }
    if ((_supportedActions & DZNWebViewControllerActionOpenSafari) > 0) {
        [activities addObject:[DZNPolyActivity activityWithType:DZNPolyActivityTypeSafari]];
    }
    if ((_supportedActions & DZNWebViewControllerActionOpenChrome) > 0) {
        [activities addObject:[DZNPolyActivity activityWithType:DZNPolyActivityTypeChrome]];
    }
    
    NSLog(@"activities : %@", activities);
    
    return activities;
}

- (void)presentActivityController:(id)sender
{
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[[self URL]] applicationActivities:[self applicationActivities]];
    
    controller.excludedActivityTypes = [self excludedActivityTypes];
    [controller setValue:[self title] forKey:@"subject"];
    
    [self presentViewController:controller animated:YES completion:nil];
    
    controller.completionHandler = ^(NSString *activityType, BOOL completed) {
        NSLog(@"completed dialog - activity: %@ - finished flag: %d", activityType, completed);
    };
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
        [self setActivityIndicatorsVisible:YES];
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
        [self setActivityIndicatorsVisible:NO];
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
