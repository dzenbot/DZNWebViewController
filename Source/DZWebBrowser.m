
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

@interface DZWebBrowser ()
{
    UIBarButtonItem *stopButton;
	UIBarButtonItem *backButton;
	UIBarButtonItem *forwardButton;
    UIBarButtonItem *shareButton;
}

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

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
    
    backButton.enabled = NO;
	forwardButton.enabled = NO;
    shareButton.enabled = NO;
    
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


#pragma mark Getter Methods

- (UIWebView *)webView
{
    if (!_webView)
    {
        _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _webView.delegate = self;
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _webView.scalesPageToFit = YES;
        
#ifndef __IPHONE_6_0
        _webView.suppressesIncrementalRendering = YES;
#endif
    }
    return _webView;
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
    
    return [[NSArray alloc] initWithObjects:space, stopButton, space, backButton, space, forwardButton, space, shareButton, space, nil];
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

- (void)setRightButtonIndicator:(BOOL)show
{
    if (show)
    {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicator.color = [UIColor whiteColor];
        [activityIndicator startAnimating];
        
        UIBarButtonItem *indicatorButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
        [self.navigationItem setRightBarButtonItem:indicatorButton animated:YES];
    }
    else [self.navigationItem setRightBarButtonItem:nil animated:YES];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = show;
}


#pragma mark -
#pragma mark WebViewController Methods

- (void)stopAction:(id)sender
{
	[_webView stopLoading];
    [self setRightButtonIndicator:NO];
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
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:CANCEL_ACTIONSHEET_TITLE destructiveButtonTitle:nil otherButtonTitles:ACTIONSHEET_TWITTER_BTN_TITLE, ACTIONSHEET_FACEBOOK_BTN_TITLE, ACTIONSHEET_MAIL_BTN_TITLE, ACTIONSHEET_COPY_BTN_TITLE, nil];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [actionSheet showFromBarButtonItem:sender animated:YES];
    }
    else {
        [actionSheet showFromToolbar:self.navigationController.toolbar];
    }
}

/**
 * Renders a graphic context form the browser's webview.
 * Scale factor and offset are taken in consideration.
 *
 * @params view The view from which to render the graphic context.
 * @returns An image from the graphic context of the specified view.
*/
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
            
            //// Renders the viewport snapshot
            image = UIGraphicsGetImageFromCurrentImageContext();
        }
    }
    UIGraphicsEndImageContext();
    return image;
}

- (void)closeAction:(id)sender
{
    [self browserWillClose];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)browserWillClose
{
    [self setRightButtonIndicator:NO];

    [_webView stopLoading];
    _webView.delegate = nil;
    _webView = nil;
}


#pragma mark -
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webview shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //Little timer to avoid loading lags
    NSTimer *webTimer = [NSTimer timerWithTimeInterval:kWebLoadingTimout target:self
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
    
	[self setRightButtonIndicator:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webview
{
	self.navigationItem.title = [webview stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    stopButton.enabled = NO;
    backButton.enabled = [webview canGoBack];
    forwardButton.enabled = [webview canGoForward];
    shareButton.enabled = YES;
    
    [self setRightButtonIndicator:NO];
}

- (void)webView:(UIWebView *)webview didFailLoadWithError:(NSError *)error
{
	[self webViewDidFinishLoad:webview];
    
    [self setRightButtonIndicator:NO];
}


#pragma mark UIActionSheetDelegate Methods

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
            [mailComposeVC setSubject:self.navigationItem.title];
            [mailComposeVC setMessageBody:_webView.request.URL.absoluteString isHTML:YES];
            
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
            [socialComposeVC setInitialText:[NSString stringWithFormat:@"%@\n%@",self.navigationItem.title,_webView.request.URL.absoluteString]];
            [socialComposeVC addImage:[self getThumbnailFromWebView]];
            [self.navigationController presentViewController:socialComposeVC animated:YES completion:NULL];
        }
    }
}

#pragma mark MFMailComposeViewControllerDelegate Methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark -
#pragma mark Reachability Notification

- (void)reachabilityChanged
{
    if (![self networkReachable])
    {
        [_webView stopLoading];
        
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
