//
//  UIImage+Sharetribe.m
//  Sharetribe
//
//  Created by Janne Käki on 4/14/13.
//  Copyright (c) 2013 Janne Käki. All rights reserved.
//

#import "UIImage+Sharetribe.h"

#import <CoreText/CoreText.h>

@implementation UIImage (Sharetribe)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 10, 10);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(c, color.CGColor);
    CGContextFillRect(c, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageWithIconNamed:(NSString *)name pointSize:(CGFloat)pointSize color:(UIColor *)color
{
    return [self imageWithIconNamed:name pointSize:pointSize color:color insets:UIEdgeInsetsZero];
}

+ (UIImage *)imageWithIconNamed:(NSString *)name pointSize:(CGFloat)pointSize color:(UIColor *)color insets:(UIEdgeInsets)insets
{
    UIFont *font = [UIFont fontWithName:@"SSPika" size:pointSize];

    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:name];
    [string setAttributes:@{NSFontAttributeName: font,
                            NSForegroundColorAttributeName: color,
                            (NSString *) kCTLigatureAttributeName: @(2)}
                    range:NSMakeRange(0, string.length)];
    
    CGSize size = string.size;
    size.width  += insets.left + insets.right;
    size.height += insets.top  + insets.bottom;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    [string drawAtPoint:CGPointMake(insets.left, insets.top)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();    
    
    return image;
}

@end
