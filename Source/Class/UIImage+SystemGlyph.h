//
//  UIImage+SystemIcon.h
//  Sample
//
//  Created by Ignacio on 10/16/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (SystemGlyph)

+ (UIImage *)pointerGlyphForState:(UIControlState)state;

+ (UIImage *)arrowLeftGlyph;
+ (UIImage *)arrowLeftGlyphForState:(UIControlState)state;

+ (UIImage *)arrowRightGlyph;
+ (UIImage *)arrowRightGlyphForState:(UIControlState)state;

+ (UIImage *)crossGlyph;
+ (UIImage *)checkGlyph;

@end
