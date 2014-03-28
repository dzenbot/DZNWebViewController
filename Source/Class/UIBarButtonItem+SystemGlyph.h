//
//  UIBarButtonItem+SystemGlyph.h
//  UIBarButtonItem-SystemGlyph
//
//  Created by Ignacio on 10/16/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UIBarButtonPrivateItem) {
    UIBarButtonSystemGlyphLocation,
    UIBarButtonSystemGlyphBackward,
    UIBarButtonSystemGlyphForward,
    UIBarButtonSystemGlyphAccept,
    UIBarButtonSystemGlyphClose
};

@interface UIBarButtonItem (SystemGlyph)

- (id)initWithBarButtonPrivateItem:(UIBarButtonPrivateItem)privateItem target:(id)target action:(SEL)action;

@end
