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

@interface DZNWebViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIBarButtonItem *actionBarItem;
@property (nonatomic, strong) UIBarButtonItem *backwardBarItem;
@property (nonatomic, strong) UIBarButtonItem *forwardBarItem;
@property (nonatomic, strong) UIBarButtonItem *stateBarItem;
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
        _actionBarItem = [[UIBarButtonItem alloc] initWithImage:self.actionButtonImage landscapeImagePhone:self.actionButtonLandscapeImage style:0 target:self action:@selector(presentActivityController:)];
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
    }
    return _webView;
}

- (UIProgressView *)progressView
{
    if (!_progressView && self.loadingStyle == DZNWebViewControllerLoadingStyleProgressView)
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
//        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showBackwardHistory:)];
//        [button addGestureRecognizer:longPress];
        
        _backwardBarItem = [[UIBarButtonItem alloc] initWithImage:self.backwardButtonImage landscapeImagePhone:nil style:0 target:self action:@selector(goBackward:)];
        _backwardBarItem.accessibilityLabel = NSLocalizedStringFromTable(@"Backward", @"DZNWebViewController", @"Accessibility label button title");
        _backwardBarItem.enabled = NO;
    }
    return _backwardBarItem;
}

- (UIBarButtonItem *)forwardBarItem
{
    if (!_forwardBarItem)
    {
//        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showForwardHistory:)];
//        [button addGestureRecognizer:longPress];
        
        _forwardBarItem = [[UIBarButtonItem alloc] initWithImage:self.forwardButtonImage landscapeImagePhone:nil style:0 target:self action:@selector(goForward:)];
        _forwardBarItem.accessibilityLabel = NSLocalizedStringFromTable(@"Forward", @"DZNWebViewController", @"Accessibility label button title");
        _forwardBarItem.enabled = NO;
    }
    return _forwardBarItem;
}

- (UIBarButtonItem *)stateBarItem
{
    if (!_stateBarItem)
    {
        _stateBarItem = [UIBarButtonItem new];
        _stateBarItem.enabled = NO;
    }
    return _stateBarItem;
}

- (UIBarButtonItem *)loadingBarItem
{
    if (!_loadingBarItem)
    {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
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
        [items addObject:self.stateBarItem];
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

- (UIImage *)actionButtonImage
{
    if (!_actionButtonImage) {
        return [UIImage imageNamed:@"dzn_icn_toolbar_action"];
    }
    return _actionButtonImage;
}

- (UIImage *)actionButtonLandscapeImage
{
    if (!_actionButtonLandscapeImage) {
        return [UIImage imageNamed:@"dzn_icn_toolbar_action_landscape"];
    }
    return _actionButtonLandscapeImage;
}

- (UIImage *)backwardButtonImage
{
    if (!_backwardButtonImage) {
        return [UIImage imageNamed:@"dzn_icn_toolbar_backward"];
    }
    return _backwardButtonImage;
}

- (UIImage *)backwardButtonLandscapeImage
{
    if (!_backwardButtonLandscapeImage) {
        return [UIImage imageNamed:@"dzn_icn_toolbar_backward_landscape"];
    }
    return _backwardButtonLandscapeImage;
}

- (UIImage *)forwardButtonImage
{
    if (!_forwardButtonImage) {
        return [UIImage imageNamed:@"dzn_icn_toolbar_forward"];
    }
    return _forwardButtonImage;
}

- (UIImage *)forwardButtonLandscapeImage
{
    if (!_forwardButtonLandscapeImage) {
        return [UIImage imageNamed:@"dzn_icn_toolbar_forward_landscape"];
    }
    return _forwardButtonLandscapeImage;
}

- (UIImage *)reloadButtonImage
{
    if (!_reloadButtonImage) {
        return [UIImage imageNamed:@"dzn_icn_toolbar_refresh"];
    }
    return _reloadButtonImage;
}

- (UIImage *)stopButtonImage
{
    if (!_stopButtonImage) {
        return [UIImage imageNamed:@"dzn_icn_toolbar_stop"];
    }
    return _stopButtonImage;
}

- (UIImage *)stateButtonImage
{
    if ([self.webView isLoading]) {
        return self.stopButtonImage;
    }
    return self.reloadButtonImage;
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
    
    if (self.loadingStyle != DZNWebViewControllerLoadingStyleActivityIndicator) {
        return;
    }
    
    if (self.activityIndicatorView.isAnimating == visible) {
        return;
    }
    
    if (visible) {
        [self.activityIndicatorView startAnimating];
        self.activityIndicatorView.color = self.navigationController.toolbar.tintColor;
    }
    else [self.activityIndicatorView stopAnimating];
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
    if (!self.allowHistory || self.webView.backForwardList.backList.count == 0) {
        return;
    }
    
    if (sender.state != UIGestureRecognizerStateBegan) {
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
    
    self.stateBarItem.target = self.webView;
    self.stateBarItem.action = self.webView.isLoading ? @selector(stopLoading) : @selector(reload);
    self.stateBarItem.image = self.stateButtonImage;
    self.stateBarItem.landscapeImagePhone = nil;
    self.stateBarItem.accessibilityLabel = NSLocalizedStringFromTable(self.webView.isLoading ? @"Stop" : @"Reload", @"DZNWebViewController", @"Accessibility label button title");
    self.stateBarItem.enabled = YES;
}

- (void)presentActivityController:(id)sender
{
    if (!self.webView.URL.absoluteString) {
        return;
    }
    
    [self presentActivityControllerWithItem:self.webView.URL.absoluteString andTitle:self.webView.title];
}

- (void)presentActivityControllerWithItem:(id)item andTitle:(NSString *)title
{
    if (!item) {
        return;
    }
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[title, item] applicationActivities:[self applicationActivitiesForItem:item]];
    controller.excludedActivityTypes = [self excludedActivityTypesForItem:item];
    
    if (title) {
        [controller setValue:title forKey:@"subject"];
    }
    
    [self presentViewController:controller animated:YES completion:NULL];
}

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

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [self updateToolbarItemsIfNeeded];
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
    // Do something.
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    // Do something.
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    // Do something.
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
    [self updateToolbarItemsIfNeeded];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"%s",__FUNCTION__);
    
    [self updateToolbarItemsIfNeeded];
    [self setLoadingError:error];
}


#pragma mark - WKUIDelegate methods

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    
    return nil;
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
