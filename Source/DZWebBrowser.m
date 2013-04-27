
//  DZWebBrowser.m
//  SimpleWebBrowser
//
//  Created by Ignacio Romero Zurbuchen on 5/25/12.
//  Copyright (c) 2011 DZen Interaktiv.
//  Licence: MIT-Licence
//

#import "DZWebBrowser.h"
#import <QuartzCore/QuartzCore.h>

#define kWebLoadingTimout 10.0
#define kDefaultControlsBundleName @"default-controls"

@interface DZWebBrowser ()
{
    UIBarButtonItem *_stopButton;
	UIBarButtonItem *_previousButton;
	UIBarButtonItem *_nextButton;
    UIBarButtonItem *_shareButton;
    
    UILabel *_titleLabel;
    UILabel *_urlLabel;
    
    UIActivityIndicatorView *_activityIndicator;
    UIProgressView *_progressView;
    
    NJKWebViewProgress *_progressProxy;
}
/**  */
@property(nonatomic, strong) UIImage *navBarBkgdImage;
/**  */
@property(nonatomic, strong) UIImage *toolBarBkgdImage;
/**  */
@property (nonatomic, strong) Reachability *netReach;
@end

@implementation DZWebBrowser
@synthesize webView = _webView;
@synthesize navBarBkgdImage = _navBarBkgdImage;
@synthesize toolBarBkgdImage = _toolBarBkgdImage;
@synthesize currentURL = _currentURL;
@synthesize netReach = _netReach;

- (id)initWebBrowserWithURL:(NSURL *)URL
{
    self = [super init];
    if (self) 
    {
        //Init Internet Reachability
        _netReach = [Reachability reachabilityForInternetConnection];
        [_netReach startNotifier];
        
        _currentURL = URL;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    [self.navigationController.toolbar setTintColor:[UIColor blackColor]];
    [self.navigationController setToolbarHidden:NO];
    [self setToolbarItems:self.items animated:NO];
    
    [self.navigationItem setLeftBarButtonItem:self.closeButton animated:NO];
    
    UIBarButtonItem *indicatorButton = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    [self.navigationItem setRightBarButtonItem:indicatorButton animated:YES];
    
    _previousButton.enabled = NO;
	_nextButton.enabled = NO;
    _shareButton.enabled = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_showProgress) {
        _progressProxy = [[NJKWebViewProgress alloc] init];
        _webView.delegate = _progressProxy;
        _progressProxy.webViewProxyDelegate = self;
        _progressProxy.progressDelegate = self;
    }
    else {
        [self.navigationItem setTitleView:self.titleView];
    }
    
    [self.view addSubview:self.webView];
    [_webView loadRequest:[NSURLRequest requestWithURL:_currentURL]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


#pragma mark - Getter Methods

- (NSString *)title
{
    return [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (NSString *)url
{
    return [_webView stringByEvaluatingJavaScriptFromString:@"document.URL"];
}

- (UIWebView *)webView
{
    if (!_webView)
    {
        _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _webView.delegate = self;
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _webView.scalesPageToFit = YES;
        
        if (OS_SUPERIOR_OR_EQUAL_THAN(@"6.0")) {
            _webView.suppressesIncrementalRendering = YES;
        }
    }
    return _webView;
}

- (UIActivityIndicatorView *)activityIndicator
{
    if (!_activityIndicator)
    {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityIndicator.color = [UIColor whiteColor];
        _activityIndicator.hidesWhenStopped = YES;
    }
    return _activityIndicator;
}

- (UIView *)titleView
{
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 188.0, 44.0)];
    
    [titleView addSubview:self.titleLabel];
    [titleView addSubview:self.urlLabel];
    
    return titleView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel)
    {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2.0, 188.0, 20.0)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        _titleLabel.minimumScaleFactor = 3;
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.shadowColor = [UIColor blackColor];
        _titleLabel.shadowOffset = CGSizeMake(0, -1);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _titleLabel;
}

- (UILabel *)urlLabel
{
    if (!_urlLabel)
    {
        _urlLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20.0, 188.0, 20.0)];
        _urlLabel.backgroundColor = [UIColor clearColor];
        _urlLabel.font = [UIFont systemFontOfSize:14.0];
        _urlLabel.textColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        _urlLabel.shadowColor = [UIColor blackColor];
        _urlLabel.shadowOffset = CGSizeMake(0, -1);
        _urlLabel.textAlignment = NSTextAlignmentCenter;
        _urlLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _urlLabel;
}

- (UIProgressView *)progressView
{
    if (!_progressView)
    {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        _progressView.progressTintColor = [UIColor lightGrayColor];
        _progressView.trackTintColor = [UIColor darkGrayColor];
        [self.navigationItem setTitleView:_progressView];
    }
    return _progressView;
}

- (UIBarButtonItem *)closeButton
{
    return [[UIBarButtonItem alloc] initWithTitle:CLOSE_BTN_TITLE style:UIBarButtonItemStyleDone target:self action:@selector(closeAction:)];
}

- (NSArray *)items
{
    if (!_controlsBundleName) {
        _controlsBundleName = kDefaultControlsBundleName;
    }
    
    UIBarButtonItem *flexibleMargin = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *innerMargin = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    innerMargin.width = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 100.0 : 30.0;
    
    UIBarButtonItem *outerMargin = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    outerMargin.width = innerMargin.width/2;
    
    UIImage *stopImg = [self imageNamed:@"stopButton" forBundleNamed:_controlsBundleName];
    UIImage *nextImg = [self imageNamed:@"nextButton" forBundleNamed:_controlsBundleName];
    UIImage *previousdImg = [self imageNamed:@"previousButton" forBundleNamed:_controlsBundleName];
    
    _stopButton = [[UIBarButtonItem alloc] initWithImage:stopImg style:UIBarButtonItemStylePlain target:self action:@selector(stopAction:)];
    _previousButton = [[UIBarButtonItem alloc] initWithImage:previousdImg style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    _nextButton = [[UIBarButtonItem alloc] initWithImage:nextImg style:UIBarButtonItemStylePlain target:self action:@selector(forwardAction:)];
    
    NSMutableArray *items = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? [NSMutableArray arrayWithObjects:outerMargin, _stopButton, flexibleMargin, _previousButton, flexibleMargin, _nextButton, flexibleMargin, nil] : [NSMutableArray arrayWithObjects:outerMargin, _stopButton, flexibleMargin, _previousButton, innerMargin, _nextButton, flexibleMargin, nil];

    if (_allowSharing) {
        _shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareAction:)];
        [items addObject:_shareButton];
        [items addObject:outerMargin];
    }
    
    return items;
}

- (UIImage *)imageNamed:(NSString *)imgName forBundleNamed:(NSString *)bundleName
{
    NSString *path = [NSString stringWithFormat:@"%@.bundle/images/%@",bundleName,imgName];
    return [UIImage imageNamed:path];
}

- (UIImage *)getThumbnailFromWebView
{
    UIImage *image = nil;
    UIGraphicsBeginImageContextWithOptions(_webView.frame.size,NO,0.0);
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, 0, 0);
        for (UIView *subview in _webView.scrollView.subviews)
        {
            [subview.layer renderInContext:context];
            image = UIGraphicsGetImageFromCurrentImageContext();
        }
    }
    UIGraphicsEndImageContext();
    return image;
}


#pragma mark - Setter Methods

- (void)setNavBarBkgdImage:(UIImage *)image
{
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
}

- (void)setToolBarBkgdImage:(UIImage *)image
{
    [self.navigationController.toolbar setBackgroundImage:image forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
}

- (void)setLoadingTitle
{
    _titleLabel.text = LOADING_TITLE;
    
    CGRect rect = _titleLabel.frame;
    rect.origin.y = 12.0;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         _titleLabel.frame = rect;
                         _urlLabel.alpha = 0;
                     }
                     completion:NULL];
}

- (void)setDocumentTitle
{
    _titleLabel.text = [self title];
    _urlLabel.text = [self url];
    
    CGRect rect = _titleLabel.frame;
    rect.origin.y = 2.0;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         _titleLabel.frame = rect;
                         _urlLabel.alpha = 1.0;
                     }
                     completion:NULL];
}

- (void)showLoadingIndicator:(BOOL)show
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = show;
    
    if (!_showProgress) {
        if (show) {
            [self setLoadingTitle];
            [_activityIndicator startAnimating];
        }
        else {
            [self setDocumentTitle];
            [_activityIndicator stopAnimating];
        }
    }
}


#pragma mark - WebViewController Methods

- (void)stopAction:(id)sender
{
	[_webView stopLoading];
    [self showLoadingIndicator:NO];
}

- (void)backAction:(id)sender
{
    NSLog(@"%s",__FUNCTION__);
    
    if ([_webView canGoBack]) {
        [_webView goBack];
    }
}

- (void)forwardAction:(id)sender
{
    NSLog(@"%s",__FUNCTION__);
    
    if ([_webView canGoForward]) {
        [_webView goForward];
    }
}

- (void)shareAction:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:CANCEL_ACTIONSHEET_TITLE destructiveButtonTitle:nil otherButtonTitles:ACTIONSHEET_TWITTER_BTN_TITLE, ACTIONSHEET_FACEBOOK_BTN_TITLE, ACTIONSHEET_COPY_BTN_TITLE, ACTIONSHEET_MAIL_BTN_TITLE, ACTIONSHEET_SAFARI_BTN_TITLE, nil];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [actionSheet showFromBarButtonItem:sender animated:YES];
    }
    else {
        [actionSheet showFromToolbar:self.navigationController.toolbar];
    }
}

- (void)closeAction:(id)sender
{
    [self browserWillClose];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)browserWillClose
{
    [self showLoadingIndicator:NO];
    
    [_webView stopLoading];
    _webView.delegate = nil;
    _webView = nil;
}


#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webview shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //Little timer to avoid loading lags
    NSTimer *webTimer = [NSTimer timerWithTimeInterval:kWebLoadingTimout target:self
                                              selector:@selector(reachabilityChanged)
                                              userInfo:nil
                                               repeats:NO];
    
    [[NSRunLoop mainRunLoop] addTimer:webTimer forMode:NSDefaultRunLoopMode];
    
    self.currentURL = request.URL;
    _stopButton.enabled = YES;
    
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webview
{
	[self showLoadingIndicator:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webview
{
    _stopButton.enabled = NO;
    _previousButton.enabled = [webview canGoBack];
    _nextButton.enabled = [webview canGoForward];
    _shareButton.enabled = YES;
    
    [self showLoadingIndicator:NO];
}

- (void)webView:(UIWebView *)webview didFailLoadWithError:(NSError *)error
{
	[self webViewDidFinishLoad:webview];
    [self showLoadingIndicator:NO];
}


#pragma mark - NJKWebViewProgressDelegate

-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [self.progressView setProgress:progress animated:NO];
    
    if (progress == 1.0) {
        _progressView = nil;
        [self.navigationItem setTitleView:self.titleLabel];
        _titleLabel.text = [self title];
    }
}


#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:ACTIONSHEET_MAIL_BTN_TITLE])
    {
        if ([MFMailComposeViewController canSendMail])
        {
            MFMailComposeViewController *mailComposeVC = [[MFMailComposeViewController alloc] init];
            mailComposeVC.mailComposeDelegate = self;
            mailComposeVC.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
            [mailComposeVC setSubject:[self title]];
            [mailComposeVC setMessageBody:[self url] isHTML:YES];
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                mailComposeVC.modalPresentationStyle = UIModalPresentationFormSheet;
            }
            
            mailComposeVC.modalPresentationStyle = UIModalPresentationFormSheet;
            [self.navigationController presentViewController:mailComposeVC animated:YES completion:NULL];
        }
    }
    else if ([buttonTitle isEqualToString:ACTIONSHEET_COPY_BTN_TITLE])
    {
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        [pasteBoard setString:_webView.request.URL.absoluteString];
    }
    else if ([buttonTitle isEqualToString:ACTIONSHEET_SAFARI_BTN_TITLE])
    {
        [[UIApplication sharedApplication] openURL:_currentURL];
    }
    else
    {
        NSString *ServiceType = nil;
        
        if ([buttonTitle isEqualToString:ACTIONSHEET_TWITTER_BTN_TITLE])
        {
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
                ServiceType = SLServiceTypeTwitter;
            }
        }
        else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:ACTIONSHEET_FACEBOOK_BTN_TITLE])
        {
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
                ServiceType = SLServiceTypeFacebook;
            }
        }
        
        if (ServiceType) {
            SLComposeViewController *socialComposeVC = [SLComposeViewController composeViewControllerForServiceType:ServiceType];
            [socialComposeVC setInitialText:[NSString stringWithFormat:@"%@\n%@",[self title],[self url]]];
            [socialComposeVC addImage:[self getThumbnailFromWebView]];
            [self.navigationController presentViewController:socialComposeVC animated:YES completion:NULL];
        }
    }
}


#pragma mark - MFMailComposeViewControllerDelegate Methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - Reachability Notification

- (void)reachabilityChanged
{
    if (![self networkReachable])
    {
        [_webView stopLoading];
        
        _nextButton.enabled = NO;
        _shareButton.enabled = NO;
        
        UIAlertView *alertNoInternet = [[UIAlertView alloc] initWithTitle:ALERT_NO_INTERNET_TITLE
                                                                  message:ALERT_NO_INTERNET_MESSAGE
                                                                 delegate:nil
                                                        cancelButtonTitle:ALERT_OK
                                                        otherButtonTitles:nil];
        [alertNoInternet show];
    }
}

- (BOOL)networkReachable
{
	NetworkStatus netStatus = [self.netReach currentReachabilityStatus];
	BOOL connectionRequired = [self.netReach connectionRequired];
	
	if (((netStatus == ReachableViaWiFi) || (netStatus == ReachableViaWWAN)) && (!connectionRequired)) {
		return YES;
	}
	return NO;
}


#pragma mark - View lifeterm

- (void)didReceiveMemoryWarning
{
    _webView.delegate = nil;
    _webView = nil;
    
    [super didReceiveMemoryWarning];
}

- (void)viewWillUnload
{
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    [sharedCache removeAllCachedResponses];
    sharedCache = nil;
    
    [super viewWillUnload];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

@end
