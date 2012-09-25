
//  DZWebBrowser.m
//  SimpleWebBrowser
//
//  Created by Ignacio Romero Zurbuchen on 5/25/12.
//  Copyright (c) 2011 DZen Interaktiv.
//  Licence: MIT-Licence
//

#import "DZWebBrowser.h"

#define LOADING_TITLE NSLocalizedString(@"Loading...",nil)
#define CLOSE_BTN_TITLE NSLocalizedString(@"Close",nil)
#define CANCEL_ACTIONSHEET_TITLE NSLocalizedString(@"Cancel",nil)

@interface DZWebBrowser ()
{
    UIBarButtonItem *stopButton;
	UIBarButtonItem *backButton;
	UIBarButtonItem *forwardButton;
    UIBarButtonItem *shareButton;
    
    BOOL hasConnectivity;
}

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation DZWebBrowser
@synthesize webView = _webView;
@synthesize navBarBkgdImage = _navBarBkgdImage;
@synthesize toolBarBkgdImage = _toolBarBkgdImage;
@synthesize currentURL = _currentURL;
@synthesize activityIndicator = _activityIndicator;
@synthesize netReach = _netReach;

- (id)initWebBrowserWithURL:(NSURL *)URL
{
    self = [super init];
    if (self) 
    {
        _currentURL = URL;
        
        //Init Internet Reachability
        _netReach = [Reachability reachabilityForInternetConnection];
        [_netReach startNotifier];
    }
    
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    [self.navigationController.toolbar setTintColor:[UIColor blackColor]];
    [self.navigationController setToolbarHidden:NO];
    [self setToolbarItems:self.items animated:NO];
    
    [self.navigationItem setLeftBarButtonItem:self.closeButton animated:NO];
    
    UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:_activityIndicator];
    [self.navigationItem setRightBarButtonItem:activityItem];
    
    backButton.enabled = NO;
	forwardButton.enabled = NO;
    shareButton.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.view addSubview:self.webView];
    [_webView loadRequest:[NSURLRequest requestWithURL:_currentURL]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


#pragma mark Getter Methods

- (UIWebView *)webView
{
    if (!_webView)
    {
        _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _webView.delegate = self;
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _webView.scalesPageToFit = YES;
    }
    return _webView;
}

- (UIActivityIndicatorView *)activityIndicator
{
    if (_activityIndicator)
    {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityIndicator.hidesWhenStopped = YES;
        _activityIndicator.color = [UIColor whiteColor];
        [_activityIndicator startAnimating];
        
        NSLog(@"_activityIndicator : %@",_activityIndicator.description);
    }
    return _activityIndicator;
}

- (UIBarButtonItem *)closeButton
{
    return [[UIBarButtonItem alloc] initWithTitle:CLOSE_BTN_TITLE style:UIBarButtonItemStyleDone target:self action:@selector(closeAction:)];
}

- (NSArray *)items
{
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    stopButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"webStopButton"] style:UIBarButtonItemStylePlain target:self action:@selector(stopAction:)];
    backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"webPrevButton"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"webNextButton"] style:UIBarButtonItemStylePlain target:self action:@selector(forwardAction:)];
    shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareAction:)];
    
    return [[NSArray alloc] initWithObjects:stopButton, space, backButton, space, forwardButton, space, shareButton, nil];
}


#pragma mark Setter Methods

- (void)setNavBarBkgdImage:(UIImage *)navBarBkgdImage
{
    [self.navigationController.navigationBar setBackgroundImage:navBarBkgdImage forBarMetrics:UIBarMetricsDefault];
}

- (void)setToolBarBkgdImage:(UIImage *)toolBarBkgdImage
{
    [self.navigationController.toolbar setBackgroundImage:toolBarBkgdImage forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
}


#pragma mark -
#pragma mark WebViewController Methods

- (void)stopAction:(id)sender
{
	[_webView stopLoading];
}

- (void)backAction:(id)sender
{
	[_webView goBack];
}

- (void)forwardAction:(id)sender
{
	[_webView goForward];
}

- (void)shareAction:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:CANCEL_ACTIONSHEET_TITLE destructiveButtonTitle:nil otherButtonTitles:nil];
    [actionSheet showFromToolbar:self.navigationController.toolbar];
}

- (void)setActivityIndicatorVisible:(BOOL)visible
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = visible;
    
    if (visible) [_activityIndicator startAnimating];
    else [_activityIndicator stopAnimating];
}

- (void)closeAction:(id)sender
{
    [self browserWillClose];
    [self dismissModalViewControllerAnimated:YES];
}


- (void)browserWillClose
{
    [self setActivityIndicatorVisible:NO];

    [_webView stopLoading];
    _webView.delegate = nil;
    _webView = nil;
}


#pragma mark -
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webview shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //Little timer to avoid loading lags
    NSTimer *webTimer = [NSTimer timerWithTimeInterval:1.0 target:self
                                              selector:@selector(reachabilityChanged)
                                              userInfo:nil
                                               repeats:NO];
    
    [[NSRunLoop mainRunLoop] addTimer:webTimer forMode:NSDefaultRunLoopMode];
    
    self.currentURL = request.URL;
    
    stopButton.enabled = YES;
    
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webview
{
	self.navigationItem.title = LOADING_TITLE;
    
	[self setActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webview
{
	self.navigationItem.title = [webview stringByEvaluatingJavaScriptFromString:@"document.title"];
    
	[self setActivityIndicatorVisible:NO];
    
    stopButton.enabled = NO;
    backButton.enabled = [webview canGoBack];
    forwardButton.enabled = [webview canGoForward];
    shareButton.enabled = YES;
}

- (void)webView:(UIWebView *)webview didFailLoadWithError:(NSError *)error
{
	[self webViewDidFinishLoad:webview];
}


#pragma mark -
#pragma mark Reachability Notification

- (void)reachabilityChanged
{
    if (![self networkReachable])
    {
        //self.navigationItem.title = @"";
        
        [_webView stopLoading];
        
        stopButton.enabled = NO;
        backButton.enabled = NO;
        forwardButton.enabled = NO;
        shareButton.enabled = NO;
        
        UIAlertView *alertNoInternet = [[UIAlertView alloc] initWithTitle:@"Internet Error"
                                                                  message:@"No Internet detected. Please check your connection settings."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
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
    [_webView removeFromSuperview];
    _webView.delegate = nil;
    _webView = nil;
    
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    [sharedCache removeAllCachedResponses];
    sharedCache = nil;
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    [super viewWillUnload];
}

- (void)viewDidUnload
{
    _webView.delegate = nil;
    _webView = nil;
    
    [super viewDidUnload];
}

#pragma mark - View Auto-Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
