//
//  UIBarButtonItem+SystemGlyph.m
//  Sample
//
//  Created by Ignacio on 10/16/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//

#import "UIBarButtonItem+SystemGlyph.h"
#import "UIImage+SystemGlyph.h"

@implementation UIBarButtonItem (SystemGlyph)

- (id)initWithBarButtonPrivateItem:(UIBarButtonPrivateItem)privateItem target:(id)target action:(SEL)action
{
    UIButton *button = [UIBarButtonItem buttontWithBarButtonPrivateItem:privateItem];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

+ (UIButton *)buttontWithBarButtonPrivateItem:(UIBarButtonPrivateItem)privateItem
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    
    switch (privateItem) {
        case UIBarButtonSystemGlyphLocation:
            [button setImage:[UIImage pointerGlyphForState:UIControlStateNormal] forState:UIControlStateNormal];
            [button setImage:[UIImage pointerGlyphForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
            [button setImage:[UIImage pointerGlyphForState:UIControlStateSelected] forState:UIControlStateSelected];
            break;
            
        case UIBarButtonSystemGlyphBackward:
            [button setImage:[UIImage arrowLeftGlyph] forState:UIControlStateNormal];
            [button setImage:[UIImage arrowLeftGlyphForState:UIControlStateDisabled] forState:UIControlStateDisabled];
            break;
            
        case UIBarButtonSystemGlyphForward:
            [button setImage:[UIImage arrowRightGlyph] forState:UIControlStateNormal];
            [button setImage:[UIImage arrowRightGlyphForState:UIControlStateDisabled] forState:UIControlStateDisabled];
            break;
            
        case UIBarButtonSystemGlyphAccept:
            [button setImage:[UIImage checkGlyph] forState:UIControlStateNormal];
            break;
            
        case UIBarButtonSystemGlyphClose:
            [button setImage:[UIImage crossGlyph] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
    
    [button sizeToFit];
    
    return button;
}

@end
