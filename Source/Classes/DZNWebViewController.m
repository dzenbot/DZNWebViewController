//
//  DZNWebViewController.m
//  DZNWebViewController
//  https://github.com/dzenbot/DZNWebViewController
//
//  Created by Ignacio Romero Zurbuchen on 10/25/13.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "DZNWebViewController.h"
#import "DZNPolyActivity.h"

#define kDZNWebViewControllerContentTypeImage @"image"
#define kDZNWebViewControllerContentTypeLink @"link"

@interface DZNLongPressGestureRecognizer : UILongPressGestureRecognizer
@end

@implementation DZNLongPressGestureRecognizer

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer {
    return NO;
}

@end


@interface DZNWebViewController () <UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate>
{
    BOOL _didLoadContent;
    BOOL _presentingActivities;
}

@property (nonatomic, strong) UIBarButtonItem *actionBarItem;
@property (nonatomic, strong) UIBarButtonItem *backwardBarItem;
@property (nonatomic, strong) UIBarButtonItem *forwardBarItem;
@property (nonatomic, strong) UIBarButtonItem *refreshBarItem;
@property (nonatomic, strong) UIBarButtonItem *loadingBarItem;

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation DZNWebViewController
@synthesize URL = _URL;

- (id)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithURL:(NSURL *)URL
{
    NSParameterAssert(URL);
    NSAssert(URL, @"Invalid URL");
    NSAssert(URL.scheme, @"URL has no scheme");

    self = [self init];
    if (self) {
        _URL = URL;
    }
    return self;
}

- (id)initWithFileURL:(NSURL *)URL
{
    return [self initWithURL:URL];
}

- (void)awakeFromNib
{
    [self commonInit];
}

- (void)commonInit
{
    _loadingStyle = DZNWebViewControllerLoadingStyleProgressView;
    _supportedNavigationTools = DZNWebViewControllerNavigationToolAll;
    _supportedActions = DZNWebViewControllerActionAll;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.supportedActions > 0) {
        _actionBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(presentActivityController:)];
        [self.navigationItem setRightBarButtonItem:_actionBarItem];
    }
    
    [self.view addSubview:self.webView];
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    [self setToolbarItems:[self navigationToolItems]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
     [UIView performWithoutAnimation:^{
         if (self.navigationController.toolbarHidden && self.toolbarItems.count > 0) {
             [self.navigationController setToolbarHidden:NO];
         }
     }];
    
    if (!self.webView.URL) {
        [self startRequestWithURL:self.URL];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
    [self clearProgressViewAnimated:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    
    [self stopLoading];
}


#pragma mark - Getter methods

- (DZNWebView *)webView
{
    if (!_webView)
    {
        DZNWebView *webView = [[DZNWebView alloc] initWithFrame:self.view.bounds configuration:[WKWebViewConfiguration new]];
        webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        webView.backgroundColor = [UIColor whiteColor];
        
        webView.allowsBackForwardNavigationGestures = YES;
        
        webView.navDelegate = self;
        webView.UIDelegate = self;
        
        _webView = webView;
        
        // Disabling contextual menu in iOS8.
        // TODO: Fix the inspector script in iOS8
//        if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
//            DZNLongPressGestureRecognizer *gesture = [[DZNLongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
//            gesture.delegate = self;
//            [_webView addGestureRecognizer:gesture];
//        }
    }
    return _webView;
}

- (UIProgressView *)progressView
{
    if (!_progressView && _loadingStyle == DZNWebViewControllerLoadingStyleProgressView)
    {
        CGFloat height = 2.5f;
        CGSize size = self.navigationController.navigationBar.bounds.size;
        CGRect frame = CGRectMake(0, size.height - height, size.width, height);
        
        UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:frame];
        progressView.trackTintColor = [UIColor clearColor];
        progressView.alpha = 0.0f;
        
        [self.navigationController.navigationBar addSubview:progressView];
        
        _progressView = progressView;
    }
    return _progressView;
}

- (UIBarButtonItem *)backwardBarItem
{
    if (!_backwardBarItem)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setImage:[UIImage imageNamed:@"dzn_icn_toolbar_backward"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(goBackward:) forControlEvents:UIControlEventTouchUpInside];
        [button sizeToFit];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showBackwardHistory:)];
        [button addGestureRecognizer:longPress];
        
        _backwardBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        _backwardBarItem.accessibilityLabel = NSLocalizedStringFromTable(@"Backward", @"DZNWebViewController", @"Accessibility label button title");
        _backwardBarItem.enabled = NO;
    }
    return _backwardBarItem;
}

- (UIBarButtonItem *)forwardBarItem
{
    if (!_forwardBarItem)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setImage:[UIImage imageNamed:@"dzn_icn_toolbar_forward"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(goForward:) forControlEvents:UIControlEventTouchUpInside];
        [button sizeToFit];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showForwardHistory:)];
        [button addGestureRecognizer:longPress];
        
        _forwardBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        _forwardBarItem.accessibilityLabel = NSLocalizedStringFromTable(@"Forward", @"DZNWebViewController", @"Accessibility label button title");
        _forwardBarItem.enabled = NO;
    }
    return _forwardBarItem;
}

- (UIBarButtonItem *)refreshBarItem
{
    if (!_refreshBarItem)
    {
        _refreshBarItem = [[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:nil action:nil];
        _refreshBarItem.accessibilityLabel = NSLocalizedStringFromTable(@"Reload", @"DZNWebViewController", @"Accessibility label button title");
        _refreshBarItem.enabled = NO;
    }
    return _refreshBarItem;
}

- (UIBarButtonItem *)loadingBarItem
{
    if (!_loadingBarItem)
    {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityIndicatorView.hidesWhenStopped = YES;
        
        _loadingBarItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicatorView];
    }
    return _loadingBarItem;
}

- (NSArray *)navigationToolItems
{
    NSMutableArray *items = [NSMutableArray new];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
    fixedSpace.width = 20.0;
    
    if ((self.supportedNavigationTools & DZNWebViewControllerNavigationToolBackward) > 0 || self.supportsAllNavigationTools) {
        [items addObject:self.backwardBarItem];
    }
    
    if ((self.supportedNavigationTools & DZNWebViewControllerNavigationToolForward) > 0 || self.supportsAllNavigationTools) {
        
        if (items.count > 0) {
            [items addObject:fixedSpace];
        }
        
        [items addObject:self.forwardBarItem];
    }
    
    if (items.count > 0) {
        [items addObject:flexibleSpace];
    }
    
    if ((self.supportedNavigationTools & DZNWebViewControllerNavigationToolStopRefresh) > 0 || self.supportsAllNavigationTools) {
        [items addObject:self.refreshBarItem];
    }
    
    if (items.count > 0) {
        [items addObject:flexibleSpace];
    }

    if (self.loadingStyle == DZNWebViewControllerLoadingStyleActivityIndicator) {
        [items addObject:self.loadingBarItem];
    }
    
    return items;
}

- (BOOL)supportsAllNavigationTools
{
    return (_supportedNavigationTools == DZNWebViewControllerNavigationToolAll) ? YES : NO;
}

//- (NSURL *)URL
//{
//    return self.webView.URL;
//}

- (CGSize)HTMLWindowSize
{
    CGSize size = CGSizeZero;
//    size.width = [[self.webView stringByEvaluatingJavaScriptFromString:@"window.innerWidth"] floatValue];
//    size.height = [[self.webView stringByEvaluatingJavaScriptFromString:@"window.innerHeight"] floatValue];
    return size;
}

- (CGPoint)convertPointToHTMLSystem:(CGPoint)point
{
    CGSize viewSize = _webView.frame.size;
    CGSize windowSize = [self HTMLWindowSize];
    
    CGPoint scaledPoint = CGPointZero;
    CGFloat factor = windowSize.width / viewSize.width;
    
    scaledPoint.x = point.x * factor;
    scaledPoint.y = point.y * factor;
    
    return scaledPoint;
}

- (NSArray *)applicationActivitiesForItem:(id)item
{
    NSMutableArray *activities = [NSMutableArray new];
    
    if ([item isKindOfClass:[UIImage class]]) {
        return activities;
    }
    
    if ((_supportedActions & DZNWebViewControllerActionCopyLink) > 0 || self.supportsAllActions) {
        [activities addObject:[DZNPolyActivity activityWithType:DZNPolyActivityTypeLink]];
    }
    if ((_supportedActions & DZNWebViewControllerActionOpenSafari) > 0 || self.supportsAllActions) {
        [activities addObject:[DZNPolyActivity activityWithType:DZNPolyActivityTypeSafari]];
    }
    if ((_supportedActions & DZNWebViewControllerActionOpenChrome) > 0 || self.supportsAllActions) {
        [activities addObject:[DZNPolyActivity activityWithType:DZNPolyActivityTypeChrome]];
    }
    if ((_supportedActions & DZNWebViewControllerActionOpenOperaMini) > 0 || self.supportsAllActions) {
        [activities addObject:[DZNPolyActivity activityWithType:DZNPolyActivityTypeOpera]];
    }
    if ((_supportedActions & DZNWebViewControllerActionOpenDolphin) > 0 || self.supportsAllActions) {
        [activities addObject:[DZNPolyActivity activityWithType:DZNPolyActivityTypeDolphin]];
    }
    
    return activities;
}

- (NSArray *)excludedActivityTypesForItem:(id)item
{
    NSMutableArray *types = [NSMutableArray new];
    
    if (![item isKindOfClass:[UIImage class]]) {
        [types addObjectsFromArray:@[UIActivityTypeCopyToPasteboard,
                                     UIActivityTypeSaveToCameraRoll,
                                     UIActivityTypePostToFlickr,
                                     UIActivityTypePrint,
                                     UIActivityTypeAssignToContact]];
    }
    
    if (self.supportsAllActions) {
        return types;
    }
    
    if ((_supportedActions & DZNWebViewControllerActionShareLink) == 0) {
        [types addObjectsFromArray:@[UIActivityTypeMail, UIActivityTypeMessage,
                                     UIActivityTypePostToFacebook, UIActivityTypePostToTwitter,
                                     UIActivityTypePostToWeibo, UIActivityTypePostToTencentWeibo,
                                     UIActivityTypeAirDrop]];
    }
    if ((_supportedActions & DZNWebViewControllerActionReadLater) == 0 && [item isKindOfClass:[UIImage class]]) {
        [types addObject:UIActivityTypeAddToReadingList];
    }
    
    return types;
}

- (BOOL)supportsAllActions
{
    return (_supportedActions == DZNWebViewControllerActionAll) ? YES : NO;
}


#pragma mark - Setter methods

- (void)setURL:(NSURL *)URL
{
    if ([self.URL isEqual:URL]) {
        return;
    }
    
    if (self.isViewLoaded) {
        [self startRequestWithURL:URL];
    }
    
    _URL = URL;
}

- (void)setViewTitle:(NSString *)title
{
    UILabel *label = (UILabel *)self.navigationItem.titleView;
    
    if (!label || ![label isKindOfClass:[UILabel class]]) {
        label = [UILabel new];
        label.numberOfLines = 2;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:13.0];
        self.navigationItem.titleView = label;
    }
    
    if (title) {
        label.text = title;
        [label sizeToFit];
        
        CGRect frame = label.frame;
        frame.size.height = CGRectGetHeight(self.navigationController.navigationBar.frame);
        label.frame = frame;
    }
}

// Sets the request errors with an alert view.
- (void)setLoadingError:(NSError *)error
{
    switch (error.code) {
        case NSURLErrorUnknown:
        case NSURLErrorCancelled:   return;
    }
    
    [self setActivityIndicatorsVisible:NO];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
    [alert show];
}

// Toggles the activity indicators on the status bar & footer view.
- (void)setActivityIndicatorsVisible:(BOOL)visible
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = visible;
    
    if (_loadingStyle != DZNWebViewControllerLoadingStyleActivityIndicator) {
        return;
    }
    
    if (self.activityIndicatorView.isAnimating == visible) {
        return;
    }
    
    if (visible) [_activityIndicatorView startAnimating];
    else [_activityIndicatorView stopAnimating];
}


#pragma mark - DZNWebViewController methods

- (void)startRequestWithURL:(NSURL *)URL
{
    if ([URL isFileURL]) {
        NSData *data = [[NSData alloc] initWithContentsOfURL:URL];
        NSString *HTMLString = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
        
        [self.webView loadHTMLString:HTMLString baseURL:nil];
    }
    else {
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:URL];
        [self.webView loadRequest:request];
    }
}

- (void)goBackward:(id)sender
{
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }
}

- (void)goForward:(id)sender
{
    if ([self.webView canGoForward]) {
        [self.webView goForward];
    }
}

- (UITableViewController *)historyControllerForTool:(DZNWebViewControllerNavigationTools)tool
{
    UITableViewController *controller = [UITableViewController new];
    controller.title = NSLocalizedStringFromTable(@"History", @"DZNWebViewController", nil);
    controller.tableView.delegate = self;
    controller.tableView.dataSource = self;
    controller.tableView.tag = tool;
    controller.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissHistoryController)];
    
    return controller;
}

- (void)dismissHistoryController
{
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)showBackwardHistory:(UIGestureRecognizer *)sender
{
    if (sender.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    if (self.webView.backForwardList.backList.count == 0) {
        return;
    }
    
    UIViewController *viewController = [self historyControllerForTool:DZNWebViewControllerNavigationToolBackward];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:navigationController animated:YES completion:NULL];
}

- (void)showForwardHistory:(UIGestureRecognizer *)sender
{
    if (sender.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    if (self.webView.backForwardList.forwardList.count == 0) {
        return;
    }
    
    UIViewController *viewController = [self historyControllerForTool:DZNWebViewControllerNavigationToolForward];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:navigationController animated:YES completion:NULL];
}

- (void)updateToolbarItemsIfNeeded
{
    [self setViewTitle:self.webView.title];
    
    self.backwardBarItem.enabled = [self.webView canGoBack];
    self.forwardBarItem.enabled = [self.webView canGoForward];
    
    [self setActivityIndicatorsVisible:[self.webView isLoading]];
    
    NSString *iconName = @"dzn_icn_toolbar_stop";
    SEL action = @selector(stopLoading);
    
    if (![self.webView isLoading]) {
        iconName = @"dzn_icn_toolbar_refresh";
        action = @selector(reload);
    }
    
    [self.refreshBarItem setImage:[UIImage imageNamed:iconName]];
    self.refreshBarItem.target = self.webView;
    self.refreshBarItem.action = action;
    self.refreshBarItem.enabled = YES;
}

- (void)presentActivityController:(id)sender
{
    NSMutableDictionary *content = [[NSMutableDictionary alloc] initWithDictionary:@{@"type": kDZNWebViewControllerContentTypeLink}];
    
    if (self.webView.URL) [content setObject:self.webView.URL.absoluteString forKey:@"url"];
    if (self.webView.title) [content setObject:self.webView.title forKey:@"title"];
    
    [self presentActivityControllerWithContent:content];
}

- (void)presentActivityControllerWithContent:(NSDictionary *)content
{
    if (!content) {
        return;
    }
    
    NSString *type = [content objectForKey:@"type"];
    NSString *title = [content objectForKey:@"title"];
    NSString *url = [content objectForKey:@"url"];
    
    if ([type isEqualToString:kDZNWebViewControllerContentTypeLink]) {
        
        [self presentActivityControllerWithItem:url andTitle:title];
    }
    if ([type isEqualToString:kDZNWebViewControllerContentTypeImage]) {
        
        [self setActivityIndicatorsVisible:YES];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul);
        dispatch_async(queue, ^{
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
            UIImage *image = [UIImage imageWithData:data];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self presentActivityControllerWithItem:image andTitle:title];
                [self setActivityIndicatorsVisible:NO];
            });
        });
    }
}

- (void)presentActivityControllerWithItem:(id)item andTitle:(NSString *)title
{
    if (!item) {
        return;
    }
    
    _presentingActivities = YES;
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[title, item] applicationActivities:[self applicationActivitiesForItem:item]];
    
    controller.excludedActivityTypes = [self excludedActivityTypesForItem:item];
    
    if (title) {
        [controller setValue:title forKey:@"subject"];
    }
    
    [self presentViewController:controller animated:YES completion:nil];
    
    controller.completionHandler = ^(NSString *activityType, BOOL completed) {
        _presentingActivities = NO;
    };
}

//- (void)handleLongPressGesture:(UIGestureRecognizer *)gesture
//{
//    if (gesture.state == UIGestureRecognizerStateBegan && self.allowContextualMenu)
//    {
//        [self injectJavaScript];
//        
//        CGPoint point = [self convertPointToHTMLSystem:[gesture locationInView:_webView]];
//        
//        // Gets the URL link at the touch location
//        NSString *function = [NSString stringWithFormat:@"script.getElement(%d,%d);", (int)point.x, (int)point.y];
//        NSString *result = [_webView stringByEvaluatingJavaScriptFromString:function];
//        NSData *data = [result dataUsingEncoding:NSStringEncodingConversionAllowLossy|NSStringEncodingConversionExternalRepresentation];
//        
//        if (!data) {
//            return;
//        }
//        
//        NSMutableDictionary *content = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil]];
//        
//        if (content.allValues.count > 0) {
//            [content setObject:[NSValue valueWithCGPoint:point] forKey:@"location"];
//            [self presentActivityControllerWithContent:content];
//        }
//    }
//}
//
//- (void)injectJavaScript
//{
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"inpector-script" ofType:@"js"];
//    NSString *script = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//    
//    [self.webView stringByEvaluatingJavaScriptFromString:script];
//}

- (void)clearProgressViewAnimated:(BOOL)animated
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


#pragma mark - DZNNavigationDelegate methods

//- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
//{
//    NSLog(@"%s",__FUNCTION__);
//}
//
//- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
//{
//    NSLog(@"%s",__FUNCTION__);
//}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"%s",__FUNCTION__);
    
    [self updateToolbarItemsIfNeeded];
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"%s",__FUNCTION__);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"%s",__FUNCTION__);
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    NSLog(@"%s",__FUNCTION__);
}

- (void)webView:(WKWebView *)webView didUpdateProgress:(CGFloat)progress
{
    if (self.progressView.alpha == 0 && progress > 0) {
        
        self.progressView.progress = 0;
        
        [UIView animateWithDuration:0.2 animations:^{
            self.progressView.alpha = 1.0;
        }];
    }
    else if (self.progressView.alpha == 1.0 && progress == 1.0)
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.progressView.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.progressView.progress = 0;
        }];
    }
    
    [self.progressView setProgress:progress animated:YES];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    NSLog(@"%s",__FUNCTION__);
    
    [self updateToolbarItemsIfNeeded];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"%s",__FUNCTION__);
    
    [self updateToolbarItemsIfNeeded];
    [self setLoadingError:error];
}

//- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandle
//{
//    NSLog(@"%s",__FUNCTION__);
//}


#pragma mark - WKUIDelegate methods

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    
    return nil;
}

//- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)())completionHandler
//{
//    NSLog(@"%s",__FUNCTION__);
//}
//
//- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler
//{
//    NSLog(@"%s",__FUNCTION__);
//}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *result))completionHandler
{
    NSLog(@"%s",__FUNCTION__);
}


#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == DZNWebViewControllerNavigationToolBackward) {
        return self.webView.backForwardList.backList.count;
    }
    if (tableView.tag == DZNWebViewControllerNavigationToolForward) {
        return self.webView.backForwardList.forwardList.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    WKBackForwardListItem *item = nil;
    
    if (tableView.tag == DZNWebViewControllerNavigationToolBackward) {
        item = [self.webView.backForwardList.backList objectAtIndex:indexPath.row];
    }
    if (tableView.tag == DZNWebViewControllerNavigationToolForward) {
        item = [self.webView.backForwardList.forwardList objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = [item.URL absoluteString];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}


#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WKBackForwardListItem *item = nil;
    
    if (tableView.tag == DZNWebViewControllerNavigationToolBackward) {
        item = [self.webView.backForwardList.backList objectAtIndex:indexPath.row];
    }
    if (tableView.tag == DZNWebViewControllerNavigationToolForward) {
        item = [self.webView.backForwardList.forwardList objectAtIndex:indexPath.row];
    }
    
    [self.webView goToBackForwardListItem:item];
    
    [self dismissHistoryController];
}


#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([gestureRecognizer isKindOfClass:[DZNLongPressGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    Class class = [DZNLongPressGestureRecognizer class];
    if ([gestureRecognizer isKindOfClass:class] || [otherGestureRecognizer isKindOfClass:class]) {
        return NO;
    }
    
    return YES;
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
    
    _webView.navDelegate = nil;
    _webView.UIDelegate = nil;
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
