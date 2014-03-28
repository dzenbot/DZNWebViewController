//
//  DZNPolyActivity.m
//  Sample
//
//  Created by Ignacio on 3/28/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//

#import "DZNPolyActivity.h"

@implementation DZNPolyActivity
{
    DZNPolyActivityType _type;
	NSURL *_URL;
}

+ (instancetype)activityWithType:(DZNPolyActivityType)type
{
    return [[DZNPolyActivity alloc] initWithActivityType:type];
}

- (instancetype)initWithActivityType:(DZNPolyActivityType)type
{
    self = [super init];
    if (self) {
        _type = type;
    }
    return self;
}


#pragma mark - Getter methods

- (NSString *)activityType
{
    switch (_type) {
        case DZNPolyActivityTypeSafari:         return @"com.dzn.DZNWebViewController.activity.OpenInSafari";
        case DZNPolyActivityTypeChrome:         return @"com.dzn.DZNWebViewController.activity.OpenInChrome";
        case DZNPolyActivityTypeCopyLink:       return @"com.dzn.DZNWebViewController.activity.CopyLink";
    }
}

- (NSString *)activityTitle
{
    switch (_type) {
        case DZNPolyActivityTypeSafari:         return NSLocalizedString(@"Open in Safari", nil);
        case DZNPolyActivityTypeChrome:         return NSLocalizedString(@"Open in Chrome", nil);
        case DZNPolyActivityTypeCopyLink:       return NSLocalizedString(@"Copy Link", nil);
    }
}

- (UIImage *)activityImage
{
    switch (_type) {
        case DZNPolyActivityTypeSafari:         return [UIImage imageNamed:@"Safari7"];
        default:                                return nil;
    }
}

- (NSURL *)chromeURLWithURL:(NSURL *)URL
{
    // Replace the URL Scheme with the Chrome equivalent.
    NSString *chromeScheme = nil;
    if ([URL.scheme isEqualToString:@"http"]) chromeScheme = @"googlechrome";
    else if ([URL.scheme isEqualToString:@"https"]) chromeScheme = @"googlechromes";
    
    // Proceed only if a valid Google Chrome URI Scheme is available.
    if (chromeScheme) {
        NSString *absoluteString = [URL absoluteString];
        NSRange rangeForScheme = [absoluteString rangeOfString:@":"];
        NSString *urlNoScheme = [absoluteString substringFromIndex:rangeForScheme.location];
        return [NSURL URLWithString:[chromeScheme stringByAppendingString:urlNoScheme]];
    }
    
    return nil;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    if (_type == DZNPolyActivityTypeCopyLink) {
        return [UIPasteboard generalPasteboard] ? YES : NO;
    }
        
	for (UIActivity *item in activityItems) {
        
		if ([item isKindOfClass:[NSURL class]]) {
            
			NSURL *activityURL = (NSURL *)item;
            if (_type == DZNPolyActivityTypeSafari) {
                return [[UIApplication sharedApplication] canOpenURL:activityURL];
            }
            if (_type == DZNPolyActivityTypeChrome) {
                return [[UIApplication sharedApplication] canOpenURL:[self chromeURLWithURL:activityURL]];
            }
		}
	}

	return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
	for (id activityItem in activityItems) {
		if ([activityItem isKindOfClass:[NSURL class]]) {
			_URL = activityItem;
		}
	}
}

- (void)performActivity
{
    BOOL completed = NO;
    
    switch (_type) {
        case DZNPolyActivityTypeSafari:
            completed = [[UIApplication sharedApplication] openURL:_URL];
            break;
        case DZNPolyActivityTypeChrome:
            completed = [[UIApplication sharedApplication] openURL:[self chromeURLWithURL:_URL]];
            break;
        case DZNPolyActivityTypeCopyLink:
            [[UIPasteboard generalPasteboard] setURL:_URL];
            completed = YES;
            break;
    }
    
	[self activityDidFinish:completed];
}

@end
