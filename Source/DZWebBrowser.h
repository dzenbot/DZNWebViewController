
//  DZWebBrowser.h
//  SimpleWebBrowser
//
//  Created by Ignacio Romero Zurbuchen on 5/25/12.
//  Copyright (c) 2011 DZen Interaktiv.
//  Licence: MIT-Licence
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

@interface DZWebBrowser : UIViewController <UIWebViewDelegate, UIScrollViewDelegate>
{
    IBOutlet UIWebView *webView;
    IBOutlet UIToolbar *toolBar;
    IBOutlet UIBarButtonItem *stopButton;
	IBOutlet UIBarButtonItem *backButton;
	IBOutlet UIBarButtonItem *forwardButton;
    IBOutlet UIBarButtonItem *actionButton;
	UIBarButtonItem *activityItem;
    
    NSMutableURLRequest *startingRequest;
    
    BOOL hasConnectivity;
    BOOL fromBanner;
}

@property (nonatomic, strong) Reachability *netReach;

@property(nonatomic, strong) NSURL *loadingURL;
@property(nonatomic, strong) NSURL *currentURL;
@property(nonatomic, strong) NSString *stringURL;

@property(nonatomic, strong) UIImage *navBarBkgdImage;
@property(nonatomic, strong) UIImage *toolBarBkgdImage;

- (id)initBrowserWithURL:(NSURL *)URL;

- (IBAction)backAction:(id)sender;
- (IBAction)forwardAction:(id)sender;
- (IBAction)shareAction:(id)sender;
- (IBAction)closeAction:(id)sender;

- (void)reachabilityChanged;
- (BOOL)networkReachable;

@end
