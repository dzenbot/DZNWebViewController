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

static char DZNWebViewControllerKVOContext = 0;

@interface DZNWebViewController ()

@property (nonatomic, strong) UIBarButtonItem *actionBarItem;
@property (nonatomic, strong) UIBarButtonItem *backwardBarItem;
@property (nonatomic, strong) UIBarButtonItem *forwardBarItem;
@property (nonatomic, strong) UIBarButtonItem *stateBarItem;
@property (nonatomic, strong) UIBarButtonItem *loadingBarItem;

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic, strong) UILongPressGestureRecognizer *backwardLongPress;
@property (nonatomic, strong) UILongPressGestureRecognizer *forwardLongPress;

@property (nonatomic, strong) UITapGestureRecognizer *barHideOnTap;

@property (nonatomic, weak) UINavigationBar *navigationBar;
@property (nonatomic, weak) UIView *navigationBarSuperView;

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
    self.loadingStyle = DZNWebLoadingStyleProgressView;
    self.supportedWebNavigationTools = DZNWebNavigationToolAll;
    self.supportedWebActions = DZNWebActionAll;
    self.hideBarsWithGestures = YES;
}


#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    
    self.view = self.webView;
    self.automaticallyAdjustsScrollViewInsets = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.supportedWebActions > 0) {
        _actionBarItem = [[UIBarButtonItem alloc] initWithImage:self.actionButtonImage landscapeImagePhone:self.actionButtonLandscapeImage style:0 target:self action:@selector(presentActivityController:)];
        [self.navigationItem setRightBarButtonItem:_actionBarItem];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [UIView performWithoutAnimation:^{
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self configureToolBar];
        });
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
    
    [self.webView stopLoading];
}


#pragma mark - Getter methods

- (DZNWebView *)webView
{
    if (!_webView)
    {
        DZNWebView *webView = [[DZNWebView alloc] initWithFrame:self.view.bounds configuration:[WKWebViewConfiguration new]];
        webView.backgroundColor = [UIColor whiteColor];
        webView.allowsBackForwardNavigationGestures = YES;
        webView.UIDelegate = self;
        webView.navDelegate = self;
        webView.scrollView.delegate = self;
        
        _webView = webView;
    }
    return _webView;
}

- (UIProgressView *)progressView
{
    if (!_progressView && self.loadingStyle == DZNWebLoadingStyleProgressView)
    {
        CGFloat height = 2.5f;
        CGSize size = self.navigationBar.bounds.size;
        CGRect frame = CGRectMake(0, size.height - height, size.width, height);
        
        UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:frame];
        progressView.trackTintColor = [UIColor clearColor];
        progressView.alpha = 0.0f;
        
        [self.navigationBar addSubview:progressView];
        
        _progressView = progressView;
    }
    return _progressView;
}

- (UIBarButtonItem *)backwardBarItem
{
    if (!_backwardBarItem)
    {
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
        _forwardBarItem = [[UIBarButtonItem alloc] initWithImage:self.forwardButtonImage landscapeImagePhone:nil style:0 target:self action:@selector(goForward:)];
        _forwardBarItem.landscapeImagePhone = nil;
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
    
    if ((self.supportedWebNavigationTools & DZNWebNavigationToolBackward) > 0 || self.supportsAllNavigationTools) {
        [items addObject:self.backwardBarItem];
    }
    
    if ((self.supportedWebNavigationTools & DZNWebNavigationToolForward) > 0 || self.supportsAllNavigationTools) {
        
        if (items.count > 0) {
            [items addObject:fixedSpace];
        }
        
        [items addObject:self.forwardBarItem];
    }
    
    if (items.count > 0) {
        [items addObject:flexibleSpace];
    }
    
    if ((self.supportedWebNavigationTools & DZNWebNavigationToolStopReload) > 0 || self.supportsAllNavigationTools) {
        [items addObject:self.stateBarItem];
    }
    
    if (items.count > 0) {
        [items addObject:flexibleSpace];
    }
    
    if (self.loadingStyle == DZNWebLoadingStyleActivityIndicator) {
        [items addObject:self.loadingBarItem];
    }
    
    return items;
}

- (BOOL)supportsAllNavigationTools
{
    return (_supportedWebNavigationTools == DZNWebNavigationToolAll) ? YES : NO;
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

- (UIImage *)forwardButtonImage
{
    if (!_forwardButtonImage) {
        return [UIImage imageNamed:@"dzn_icn_toolbar_forward"];
    }
    return _forwardButtonImage;
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
    
    if ((_supportedWebActions & DZNWebActionCopyLink) > 0 || self.supportsAllActions) {
        [activities addObject:[DZNPolyActivity activityWithType:DZNPolyActivityTypeLink]];
    }
    if ((_supportedWebActions & DZNWebActionOpenSafari) > 0 || self.supportsAllActions) {
        [activities addObject:[DZNPolyActivity activityWithType:DZNPolyActivityTypeSafari]];
    }
    if ((_supportedWebActions & DZNWebActionOpenChrome) > 0 || self.supportsAllActions) {
        [activities addObject:[DZNPolyActivity activityWithType:DZNPolyActivityTypeChrome]];
    }
    if ((_supportedWebActions & DZNWebActionOpenOperaMini) > 0 || self.supportsAllActions) {
        [activities addObject:[DZNPolyActivity activityWithType:DZNPolyActivityTypeOpera]];
    }
    if ((_supportedWebActions & DZNWebActionOpenDolphin) > 0 || self.supportsAllActions) {
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
    
    if ((_supportedWebActions & DZNsupportedWebActionshareLink) == 0) {
        [types addObjectsFromArray:@[UIActivityTypeMail, UIActivityTypeMessage,
                                     UIActivityTypePostToFacebook, UIActivityTypePostToTwitter,
                                     UIActivityTypePostToWeibo, UIActivityTypePostToTencentWeibo,
                                     UIActivityTypeAirDrop]];
    }
    if ((_supportedWebActions & DZNWebActionReadLater) == 0 && [item isKindOfClass:[UIImage class]]) {
        [types addObject:UIActivityTypeAddToReadingList];
    }
    
    return types;
}

- (BOOL)supportsAllActions
{
    return (_supportedWebActions == DZNWebActionAll) ? YES : NO;
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

- (void)setTitle:(NSString *)title
{
    NSString *url = self.webView.URL.absoluteString;
    
    if (title.length == 0 || url.length == 0) {
        return;
    }
    
    UILabel *label = (UILabel *)self.navigationItem.titleView;
    
    if (!label || ![label isKindOfClass:[UILabel class]]) {
        label = [UILabel new];
        label.numberOfLines = 2;
        label.textAlignment = NSTextAlignmentCenter;
        label.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.navigationItem.titleView = label;
    }
    
    UIFont *titleFont = [UIFont boldSystemFontOfSize:13.0];
    UIFont *urlFont = [UIFont systemFontOfSize:11.0];
    UIColor *textColor = [UIColor blackColor];
    
    if (self.navigationBar.titleTextAttributes) {
        titleFont = self.navigationBar.titleTextAttributes[NSFontAttributeName];
        urlFont = [UIFont fontWithName:titleFont.fontName size:titleFont.pointSize-2.0];
        textColor = self.navigationBar.titleTextAttributes[NSForegroundColorAttributeName];
    }
    
    NSString *text = [NSString stringWithFormat:@"%@\n%@", title, url];
    
    NSDictionary *attributes = @{NSFontAttributeName: titleFont, NSForegroundColorAttributeName: textColor};
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
    
    [attributedString addAttribute:NSFontAttributeName value:urlFont range:[text rangeOfString:url]];
    
    label.attributedText = attributedString;
    [label sizeToFit];
    
    CGRect frame = label.frame;
    frame.size.height = CGRectGetHeight(self.navigationController.navigationBar.frame);
    label.frame = frame;
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
    
    if (self.loadingStyle != DZNWebLoadingStyleActivityIndicator) {
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

- (UITableViewController *)historyControllerForTool:(DZNWebNavigationTools)tool
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
        [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
            
            // The bar button item's gestures are invalidated after using them, so we must re-assign them.
            [self configureBarItemsGestures];
        }];
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
    
    UIViewController *viewController = [self historyControllerForTool:DZNWebNavigationToolBackward];
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
    
    UIViewController *viewController = [self historyControllerForTool:DZNWebNavigationToolForward];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:navigationController animated:YES completion:NULL];
}

- (void)configureToolBar
{
    [self setToolbarItems:[self navigationToolItems]];
    
    self.navigationBar = self.navigationController.navigationBar;
    self.navigationBarSuperView = self.navigationBar.superview;
    
    self.navigationController.hidesBarsOnSwipe = self.hideBarsWithGestures;
    self.navigationController.hidesBarsWhenKeyboardAppears = self.hideBarsWithGestures;
    self.navigationController.hidesBarsWhenVerticallyCompact = self.hideBarsWithGestures;
    
    if (self.hideBarsWithGestures) {
        [self.navigationBar addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:&DZNWebViewControllerKVOContext];
        [self.navigationBar addObserver:self forKeyPath:@"center" options:NSKeyValueObservingOptionNew context:&DZNWebViewControllerKVOContext];
        [self.navigationBar addObserver:self forKeyPath:@"alpha" options:NSKeyValueObservingOptionNew context:&DZNWebViewControllerKVOContext];
    }
    
    if (self.navigationController.toolbarHidden && self.toolbarItems.count > 0) {
        [self.navigationController setToolbarHidden:NO];
    }
    else {
        return;
    }
    
    [self configureBarItemsGestures];
}

// Light hack for adding custom gesture recognizers to UIBarButtonItems
- (void)configureBarItemsGestures
{
    UIView *backwardButton= [self.backwardBarItem valueForKey:@"view"];
    if (backwardButton.gestureRecognizers.count == 0) {
        if (!_backwardLongPress) {
            _backwardLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showBackwardHistory:)];
        }
        [backwardButton addGestureRecognizer:self.backwardLongPress];
    }
    
    UIView *forwardBarButton= [self.forwardBarItem valueForKey:@"view"];
    if (forwardBarButton.gestureRecognizers.count == 0) {
        if (!_forwardLongPress) {
            _forwardLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showBackwardHistory:)];
        }
        [forwardBarButton addGestureRecognizer:self.forwardLongPress];
    }
}

- (void)updateToolbarItemsIfNeeded
{
    [self setActivityIndicatorsVisible:[self.webView isLoading]];

    self.backwardBarItem.enabled = [self.webView canGoBack];
    self.forwardBarItem.enabled = [self.webView canGoForward];
    
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


#pragma mark - DZNNavigationDelegate methods

- (void)webView:(DZNWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [self updateToolbarItemsIfNeeded];
}

- (void)webView:(DZNWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    [self setActivityIndicatorsVisible:[self.webView isLoading]];
}

- (void)webView:(DZNWebView *)webView didUpdateProgress:(CGFloat)progress
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

- (void)webView:(DZNWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self updateToolbarItemsIfNeeded];
    
    self.title = self.webView.title;
}

- (void)webView:(DZNWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self updateToolbarItemsIfNeeded];
    [self setLoadingError:error];
    
    self.title = nil;
}


#pragma mark - WKUIDelegate methods

- (DZNWebView *)webView:(DZNWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
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
    if (tableView.tag == DZNWebNavigationToolBackward) {
        return self.webView.backForwardList.backList.count;
    }
    if (tableView.tag == DZNWebNavigationToolForward) {
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
    
    if (tableView.tag == DZNWebNavigationToolBackward) {
        item = [self.webView.backForwardList.backList objectAtIndex:indexPath.row];
    }
    if (tableView.tag == DZNWebNavigationToolForward) {
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
    
    if (tableView.tag == DZNWebNavigationToolBackward) {
        item = [self.webView.backForwardList.backList objectAtIndex:indexPath.row];
    }
    if (tableView.tag == DZNWebNavigationToolForward) {
        item = [self.webView.backForwardList.forwardList objectAtIndex:indexPath.row];
    }
    
    [self.webView goToBackForwardListItem:item];
    
    [self dismissHistoryController];
}


#pragma mark - Key Value Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context != &DZNWebViewControllerKVOContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if ([object isEqual:self.navigationBar]) {
        
        // Skips for landscape orientation, since there is no status bar visible on iPhone landscape
        if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft ||
            [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
            return;
        }
        
        id new = change[NSKeyValueChangeNewKey];
        
        if ([keyPath isEqualToString:@"hidden"] && [new boolValue] && self.navigationBar.center.y >= -2.0) {
            
            self.navigationBar.hidden = NO;
            
            if (!self.navigationBar.superview) {
                [self.navigationBarSuperView addSubview:self.navigationBar];
            }
        }
        
        if ([keyPath isEqualToString:@"center"]) {
            
            CGPoint center = [new CGPointValue];
            
            if (center.y < -2.0) {
                center.y = -2.0;
                self.navigationBar.center = center;
                
                [UIView beginAnimations:@"DZNNavigationBarAnimation" context:nil];
                for (UIView *subview in self.navigationBar.subviews) {
                    if (subview != self.navigationBar.subviews[0]) {
                        subview.alpha = 0.0;
                    }
                }
                [UIView commitAnimations];
            }
        }
    }
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
    [self.navigationBar removeObserver:self forKeyPath:@"hidden" context:&DZNWebViewControllerKVOContext];
    [self.navigationBar removeObserver:self forKeyPath:@"center" context:&DZNWebViewControllerKVOContext];
    [self.navigationBar removeObserver:self forKeyPath:@"alpha" context:&DZNWebViewControllerKVOContext];
    
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

@end
