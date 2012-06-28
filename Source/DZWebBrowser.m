
//  DZWebBrowser.m
//  SimpleWebBrowser
//
//  Created by Ignacio Romero Zurbuchen on 5/25/12.
//  Copyright (c) 2011 DZen Interaktiv.
//  Licence: MIT-Licence
//

#import "DZWebBrowser.h"

#define LOADING_MSSG @"Loading..."
#define CLOSE_BTN_TITLE @"Close"

@interface DZWebBrowser ()
@end

@implementation DZWebBrowser
@synthesize webView;
@synthesize netReach, loadingURL, stringURL, currentURL;
@synthesize navBarBkgdImage, toolBarBkgdImage;

- (id)initBrowserWithURL:(NSURL *)URL
{
    self = [super init];
    if (self) 
    {
        //Init Internet Reachability
        self.netReach = [Reachability reachabilityForInternetConnection];
        [netReach startNotifier];
        startingRequest = [NSMutableURLRequest requestWithURL:URL];
    }
    
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:navBarBkgdImage forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:CLOSE_BTN_TITLE style:UIBarButtonItemStyleDone target:self action:@selector(closeAction:)];
    [self.navigationItem setLeftBarButtonItem:closeButton animated:NO];
    
    [toolBar setBackgroundImage:toolBarBkgdImage forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
    [toolBar setBackgroundColor:[UIColor blackColor]];
    
    webView.delegate = self;
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webView.scalesPageToFit = YES;
    webView.scrollView.delegate = self;
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [spinner startAnimating];
    activityItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    [webView loadRequest:startingRequest];
}

- (void)viewWillAppear:(BOOL)animated
{
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    
}


#pragma mark -
#pragma mark WebViewController Methods


- (IBAction)stopAction:(id)sender
{
	[webView stopLoading];
}

- (IBAction)backAction:(id)sender
{
	[webView goBack];
}

- (IBAction)forwardAction:(id)sender
{
	[webView goForward];
}

- (IBAction)shareAction:(id)sender
{
    NSLog(@"%s",__FUNCTION__);
}

- (void)closeAction:(id)sender
{
    [self browserWillClose];
    [self dismissModalViewControllerAnimated:YES];
}


- (void)browserWillClose
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [webView stopLoading];
    webView.delegate = nil;
    webView = nil;
}


#pragma mark -
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView*)_webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    //Little timer to avoid loading lags
    NSTimer *webTimer = [NSTimer timerWithTimeInterval:1.0 target:self
                                              selector:@selector(reachabilityChanged)
                                              userInfo:nil
                                               repeats:NO];
    
    [[NSRunLoop mainRunLoop] addTimer:webTimer forMode:NSDefaultRunLoopMode];
    
    self.currentURL = request.URL;
	loadingURL = request.URL;
    stopButton.enabled = YES;
	backButton.enabled = [_webView canGoBack];
	forwardButton.enabled = [_webView canGoForward];
    actionButton.enabled = YES;
    
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView*)_webView
{
	self.navigationItem.title = LOADING_MSSG;
	if (!self.navigationItem.rightBarButtonItem) {
		[self.navigationItem setRightBarButtonItem:activityItem animated:YES];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}
    
    stopButton.enabled = YES;
	backButton.enabled = [_webView canGoBack];
	forwardButton.enabled = [_webView canGoForward];
    actionButton.enabled = YES;
}

- (void)webViewDidFinishLoad:(UIWebView*)_webView
{
	self.navigationItem.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
	if (self.navigationItem.rightBarButtonItem == activityItem) {
		[self.navigationItem setRightBarButtonItem:nil animated:NO];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
    
    stopButton.enabled = NO;
    backButton.enabled = [_webView canGoBack];
    forwardButton.enabled = [_webView canGoForward];
    actionButton.enabled = YES;
}

- (void)webView:(UIWebView*)_webView didFailLoadWithError:(NSError*)error
{
	[self webViewDidFinishLoad:_webView];
}

- (NSURL *)URL
{
	return loadingURL ? loadingURL : webView.request.URL;
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    
}


#pragma mark -
#pragma mark Reachability Notification

- (void)reachabilityChanged
{
    if(![self networkReachable])
    {
        hasConnectivity = false;
        //self.navigationItem.title = @"";
        
        [webView stopLoading];
        stopButton.enabled = NO;
        backButton.enabled = NO;
        forwardButton.enabled = NO;
        actionButton.enabled = NO;
        
        webView.delegate = nil;
        
        
        if (self.navigationItem.rightBarButtonItem == activityItem)
        {
            [self.navigationItem setRightBarButtonItem:nil animated:NO];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
        
        UIAlertView *alertNoInternet = [[UIAlertView alloc] initWithTitle:@"Internet Error"
                                                                  message:@"No Internet detected."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
        [alertNoInternet show];
    }
    else
    {
        hasConnectivity = true;
    }    
}

- (BOOL)networkReachable
{
	NetworkStatus netStatus = [self.netReach currentReachabilityStatus];
	BOOL connectionRequired = [self.netReach connectionRequired];
	
	if (((netStatus == ReachableViaWiFi) || (netStatus == ReachableViaWWAN)) && (!connectionRequired))
    {
		return YES;
	}
	return NO;
}

#pragma mark - View lifeterm

- (void)didReceiveMemoryWarning
{
    webView.delegate = nil;
    webView = nil;
    
    [super didReceiveMemoryWarning];
}

- (void)viewWillUnload
{
    [webView removeFromSuperview];
    webView.delegate = nil;
    webView = nil;
    
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    [sharedCache removeAllCachedResponses];
    sharedCache = nil;
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    [super viewWillUnload];
}

- (void)viewDidUnload
{
    webView.delegate = nil;
    webView = nil;
    
    [super viewDidUnload];
}

#pragma mark - View Auto-Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
