//
//  UIImage+SystemIcon.m
//  Sample
//
//  Created by Ignacio on 10/16/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//

#import "UIImage+SystemGlyph.h"

@implementation UIImage (SystemGlyph)

+ (UIImage *)pointerGlyphForState:(UIControlState)state
{
    //Create a UIBezierPath for a Triangle
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(30.0, 30.0), NO, 0);
    
    //// Color Declarations
    UIColor *color = [UIApplication sharedApplication].keyWindow.tintColor;
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(22, 4.5)];
    [bezierPath addLineToPoint: CGPointMake(2, 13.67)];
    [bezierPath addLineToPoint: CGPointMake(12.4, 13.67)];
    [bezierPath addLineToPoint: CGPointMake(12.4, 24.5)];
    [bezierPath addLineToPoint: CGPointMake(22, 4.5)];
    [bezierPath closePath];
    [color setStroke];
    bezierPath.lineWidth = 1;
    [bezierPath stroke];
    
    if (state == UIControlStateHighlighted || state == UIControlStateSelected) {
        [color setFill];
        [bezierPath fill];
    }
    
    //Create a UIImage using the current context.
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


+ (UIImage *)arrowLeftGlyph
{
    return [UIImage arrowLeftGlyphForState:UIControlStateNormal];
}

+ (UIImage *)arrowLeftGlyphForState:(UIControlState)state
{
    //Create a UIBezierPath for a Triangle
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(21.0, 21.0), NO, 0);
    
    //// Color Declarations
    UIColor *color = [UIApplication sharedApplication].keyWindow.tintColor;
    if (state == UIControlStateDisabled) {
        color = [color colorWithAlphaComponent:0.3];
    }
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(16.02, 1.41)];
    [bezierPath addLineToPoint: CGPointMake(6.92, 10.51)];
    [bezierPath addLineToPoint: CGPointMake(16.02, 19.61)];
    [bezierPath addLineToPoint: CGPointMake(14.61, 21.02)];
    [bezierPath addLineToPoint: CGPointMake(4, 10.51)];
    [bezierPath addLineToPoint: CGPointMake(14.61, 0)];
    [bezierPath addLineToPoint: CGPointMake(16.02, 1.41)];
    [bezierPath closePath];
    [color setFill];
    [bezierPath fill];
    
    //Create a UIImage using the current context.
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)arrowRightGlyph
{
    return [UIImage arrowRightGlyphForState:UIControlStateNormal];
}

+ (UIImage *)arrowRightGlyphForState:(UIControlState)state
{
    //Create a UIBezierPath for a Triangle
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(21.0, 21.0), NO, 0);
    
    //// Color Declarations
    UIColor *color = [UIApplication sharedApplication].keyWindow.tintColor;
    if (state == UIControlStateDisabled) {
        color = [color colorWithAlphaComponent:0.3];
    }
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(5, 19.59)];
    [bezierPath addLineToPoint: CGPointMake(14.08, 10.5)];
    [bezierPath addLineToPoint: CGPointMake(5, 1.41)];
    [bezierPath addLineToPoint: CGPointMake(6.41, 0)];
    [bezierPath addLineToPoint: CGPointMake(17, 10.5)];
    [bezierPath addLineToPoint: CGPointMake(6.41, 21)];
    [bezierPath addLineToPoint: CGPointMake(5, 19.59)];
    [bezierPath closePath];
    [color setFill];
    [bezierPath fill];
    
    //Create a UIImage using the current context.
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)crossGlyph
{
    //Create a UIBezierPath for a Triangle
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(30.0, 30.0), NO, 0);
    
    //// Color Declarations
    UIColor *color = [UIApplication sharedApplication].keyWindow.tintColor;
    
    //// Rectangle Drawing
    UIBezierPath* rectangle3Path = [UIBezierPath bezierPath];
    [rectangle3Path moveToPoint: CGPointMake(17.68, 24.55)];
    [rectangle3Path addLineToPoint: CGPointMake(19.09, 23.13)];
    [rectangle3Path addLineToPoint: CGPointMake(1.41, 5.45)];
    [rectangle3Path addLineToPoint: CGPointMake(0, 6.87)];
    [rectangle3Path addLineToPoint: CGPointMake(17.68, 24.55)];
    [rectangle3Path closePath];
    [color setFill];
    [rectangle3Path fill];
    
    
    //// Rectangle 4 Drawing
    UIBezierPath* rectangle4Path = [UIBezierPath bezierPath];
    [rectangle4Path moveToPoint: CGPointMake(0, 23.13)];
    [rectangle4Path addLineToPoint: CGPointMake(1.41, 24.55)];
    [rectangle4Path addLineToPoint: CGPointMake(19.09, 6.87)];
    [rectangle4Path addLineToPoint: CGPointMake(17.68, 5.45)];
    [rectangle4Path addLineToPoint: CGPointMake(0, 23.13)];
    [rectangle4Path closePath];
    [color setFill];
    [rectangle4Path fill];

    //Create a UIImage using the current context.
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)checkGlyph
{
    //Create a UIBezierPath for a Triangle
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(30.0, 30.0), NO, 0);
    
    //// Color Declarations
    UIColor *color = [UIApplication sharedApplication].keyWindow.tintColor;
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPath];
    [rectanglePath moveToPoint: CGPointMake(9, 22.13)];
    [rectanglePath addLineToPoint: CGPointMake(10.41, 23.55)];
    [rectanglePath addLineToPoint: CGPointMake(28.09, 5.87)];
    [rectanglePath addLineToPoint: CGPointMake(26.68, 4.45)];
    [rectanglePath addLineToPoint: CGPointMake(9, 22.13)];
    [rectanglePath closePath];
    [color setFill];
    [rectanglePath fill];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(1.92, 13.51)];
    [bezier2Path addLineToPoint: CGPointMake(11.16, 22.75)];
    [bezier2Path addLineToPoint: CGPointMake(9.75, 24.16)];
    [bezier2Path addLineToPoint: CGPointMake(0, 15)];
    [bezier2Path addLineToPoint: CGPointMake(1.92, 13.51)];
    [bezier2Path closePath];
    [color setFill];
    [bezier2Path fill];
    
    //Create a UIImage using the current context.
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
